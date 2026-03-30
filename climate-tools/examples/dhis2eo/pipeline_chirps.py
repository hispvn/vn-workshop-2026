"""End-to-end pipeline: CHIRPS daily precipitation into DHIS2.

This script demonstrates the full workflow for getting satellite rainfall data
into DHIS2 — from creating the necessary metadata, downloading the data,
computing zonal statistics, and pushing daily values into DHIS2.

CHIRPS (Climate Hazards Group InfraRed Precipitation with Station data) provides
daily rainfall estimates at ~5km resolution, combining satellite imagery with
ground station data. It covers 50°S–50°N and is widely used for drought monitoring
and food security analysis in tropical regions.

Daily precipitation values (mm/day) are computed per org unit using polygon-based
zonal statistics and imported directly into DHIS2 — no temporal aggregation is
applied, preserving the native daily resolution.

The pipeline:
  1. Create metadata — a data element and data set in DHIS2 (idempotent, uses stable UIDs)
  2. Fetch org units as a GeoDataFrame from DHIS2
  3. Download CHIRPS data once for all org units (using combined bounds)
  4. Compute daily mean precipitation per org unit using polygon-based zonal statistics
  5. Push all values into DHIS2 as aggregate data

Target org units:
  Use --org-unit to process a single org unit, or --org-unit-level to process
  all org units at a given hierarchy level (e.g. level 2 = districts in Sierra Leone).

Usage:
  # Single org unit (Bo district)
  uv run python examples/dhis2eo/pipeline_chirps.py --country-code SLE --org-unit O6uvpzGd5pu

  # All districts (level 2) in Sierra Leone
  uv run python examples/dhis2eo/pipeline_chirps.py --country-code SLE --org-unit-level 2

  # Custom date range
  uv run python examples/dhis2eo/pipeline_chirps.py --country-code SLE --org-unit-level 2 --start 2024-01-01 --end 2024-01-31
"""

import argparse
import json
import sys

import geopandas as gpd
import xarray as xr
from dhis2eo.data.chc.chirps3 import daily
from dhis2eo.integrations.pandas import dataframe_to_dhis2_json
from earthkit import transforms

from climate_tools.config import make_client, post_data_value_set_batched
from climate_tools.schemas import DataElement, DataSet, DataSetElement, IdRef, MetadataPayload, PeriodType

# ---------------------------------------------------------------------------
# Stable UIDs for DHIS2 metadata.
# Using fixed UIDs means this script is idempotent — running it multiple times
# will update existing objects rather than creating duplicates.
# ---------------------------------------------------------------------------
DE_CHIRPS_PRECIP = "cWsMKdoG1Hk"  # Data element: DEMO: CHIRPS daily precipitation (mm/day)
DS_CLIMATE = "aPqsx2MwYkT"  # Data set: DEMO: Climate - Earth Observation

# ---------------------------------------------------------------------------
# Parse command-line arguments
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(description="CHIRPS precipitation pipeline: download, aggregate, push to DHIS2")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("--org-unit", help="Single DHIS2 org unit UID (e.g. O6uvpzGd5pu)")
group.add_argument("--org-unit-level", type=int, help="Process all org units at this level (e.g. 2 for districts)")
parser.add_argument("--start", default="2024-01-01", help="Start date, YYYY-MM-DD (default: 2024-01-01)")
parser.add_argument("--end", default="2024-01-31", help="End date, YYYY-MM-DD (default: 2024-01-31)")
parser.add_argument("--country-code", required=True, help="ISO3 country code (e.g. SLE)")
parser.add_argument("--dirname", default="chirps_data", help="Download directory (default: chirps_data)")
parser.add_argument("--prefix", default=None, help="File prefix (default: chirps_{country_code})")
args = parser.parse_args()

if args.prefix is None:
    args.prefix = f"chirps_{args.country_code.lower()}"

# ---------------------------------------------------------------------------
# Step 0: Connect to DHIS2
# ---------------------------------------------------------------------------
# Credentials are loaded from .env (DHIS2_BASE_URL, DHIS2_USERNAME, DHIS2_PASSWORD).
# The default points to the Sierra Leone demo database at play.im.dhis2.org.
client = make_client()
print(f"Connected to {client.base_url}")

# ---------------------------------------------------------------------------
# Step 1: Fetch org units as GeoDataFrame
# ---------------------------------------------------------------------------
# Org unit geometries are fetched as GeoJSON and loaded into a GeoDataFrame.
# The combined bounds of all org units are used as the download bounding box,
# and the "id" column is used as the mask dimension for zonal statistics.

print("\n--- Step 1: Fetching org units ---")

if args.org_unit:
    # The GeoJSON endpoint only supports filtering by level, not by ID.
    # Workaround: look up the org unit's level, fetch all at that level, then filter.
    # This downloads more data than needed — fine for demos, not ideal for production.
    ou_meta = client.get(f"/api/organisationUnits/{args.org_unit}", params={"fields": "id,level"})
    level = ou_meta["level"]
    print("  WARNING: GeoJSON endpoint does not support filtering by ID.")
    print(f"  Fetching all org units at level {level} and filtering client-side.")
    geojson = client.get_org_units_geojson(level=level)
else:
    geojson = client.get_org_units_geojson(level=args.org_unit_level)

org_units = gpd.read_file(json.dumps(geojson))
org_units: gpd.GeoDataFrame = org_units[org_units.geometry.notna()]  # type: ignore[assignment, no-redef]

if args.org_unit:
    org_units: gpd.GeoDataFrame = org_units[org_units["id"] == args.org_unit]  # type: ignore[assignment, no-redef]

if org_units.empty:
    print("  No org units found. Check your --org-unit or --org-unit-level argument.")
    sys.exit(1)

print(f"  Found {len(org_units)} org unit(s) with geometry")
for _, ou in org_units.iterrows():
    print(f"    {ou['id']}  {ou['name']}")

# ---------------------------------------------------------------------------
# Step 2: Create metadata (idempotent)
# ---------------------------------------------------------------------------
# In DHIS2, data values are stored against a data element + org unit + period.
# We need to create:
#   - A data element to hold "daily precipitation"
#   - A data set that groups our climate data elements and assigns org units
#
# We use client.post() to the /api/metadata endpoint, which supports
# "MERGE" import strategy — it creates objects if they don't exist,
# or updates them if they do (matched by UID).

print("\n--- Step 2: Creating DHIS2 metadata ---")

de_precip = DataElement(
    id=DE_CHIRPS_PRECIP,
    name="DEMO: CHIRPS daily precipitation (mm/day)",
    shortName="DEMO: CHIRPS precip mm/day",
    aggregationType="AVERAGE",
)

metadata = MetadataPayload(
    dataElements=[de_precip],
    dataSets=[
        DataSet(
            id=DS_CLIMATE,
            name="DEMO: Climate - Earth Observation",
            shortName="DEMO: Climate EO",
            periodType=PeriodType.DAILY,
            dataSetElements=[DataSetElement(dataElement=de_precip)],
            organisationUnits=[IdRef(id=uid) for uid in org_units["id"]],  # pyright: ignore[reportIndexIssue]
        ),
    ],
)

result = client.post("/api/metadata", json=metadata.model_dump(exclude_none=True))
stats = result.get("stats", {})
print(f"  Metadata import: created={stats.get('created', 0)}, updated={stats.get('updated', 0)}")

# ---------------------------------------------------------------------------
# Step 3: Download CHIRPS data and compute zonal statistics
# ---------------------------------------------------------------------------
# We download once for all org units using their combined bounding box, then
# use transforms.spatial.reduce to compute polygon-based spatial mean per
# org unit — this masks to the exact polygon boundary rather than the
# bounding box, giving more accurate results for irregular shapes.
# Daily data is passed through without temporal aggregation.

print("\n--- Step 3: Downloading data and computing zonal statistics ---")

west, south, east, north = org_units.total_bounds
bbox = (float(west), float(south), float(east), float(north))
print(f"  Bounding box: {bbox}")

files = daily.download(
    start=args.start,
    end=args.end,
    bbox=bbox,
    dirname=args.dirname,
    prefix=args.prefix,
)
print(f"  Downloaded {len(files)} file(s)")

# Open downloaded NetCDF files as a single xarray Dataset
ds = xr.open_mfdataset(files, combine="nested", concat_dim="time")

# Spatial aggregation: polygon-based mean per org unit (daily data, no temporal resampling)
ds_org_units = transforms.spatial.reduce(
    ds["precip"],
    org_units,  # pyright: ignore[reportArgumentType]
    mask_dim="id",
    how="mean",
    lat_key="y",
    lon_key="x",
)

df = ds_org_units.to_dataframe().reset_index()
df = df.dropna(subset=["precip"])

# Build a lookup from org unit ID to name for display
id_to_name = dict(zip(org_units["id"], org_units["name"], strict=True))

print(f"\n  Total: {len(df)} value(s) across {len(org_units)} org unit(s)")

for ou_id, ou_df in df.groupby("id", sort=False):
    name = id_to_name.get(ou_id, ou_id)
    print(f"\n  {name} ({ou_id})")
    for _, row in ou_df.iterrows():
        print(f"    {row['time']}: {row['precip']:.2f} mm/day")

# ---------------------------------------------------------------------------
# Step 4: Push data into DHIS2
# ---------------------------------------------------------------------------
# Convert the DataFrame to the DHIS2 dataValueSets JSON format using
# dhis2eo's helper, then POST it to the DHIS2 API.

print("\n--- Step 4: Pushing data to DHIS2 ---")

if df.empty:
    print("  No data to push.")
else:
    payload = dataframe_to_dhis2_json(
        df,
        data_element_id=DE_CHIRPS_PRECIP,
        org_unit_col="id",
        period_col="time",
        value_col="precip",
    )
    print(f"  Sending {len(payload['dataValues'])} data value(s)...")

    result = post_data_value_set_batched(client, payload)
    imported = result.get("response", {}).get("importCount", {})
    print(f"  Imported: {imported.get('imported', 0)}, Updated: {imported.get('updated', 0)}")

print("\nDone! Data is now available in DHIS2.")
