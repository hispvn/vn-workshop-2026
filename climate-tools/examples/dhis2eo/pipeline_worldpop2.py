"""End-to-end pipeline: WorldPop population estimates into DHIS2.

This script demonstrates the full workflow for getting gridded population data
into DHIS2 — from creating metadata, downloading population rasters, computing
zonal statistics (total population per org unit), and pushing values into DHIS2.

WorldPop provides modelled population counts per grid cell, based on census data,
satellite imagery, and other covariates. These estimates are essential for:
  - Computing population denominators for health indicators
  - Estimating catchment area populations for facilities
  - Population-weighted averaging of climate variables

This script uses the "global2" version (2015–2030, 100m resolution).

The country raster is downloaded once, then polygon-based zonal statistics are
computed using earthkit-transforms. This masks each org unit's exact polygon
geometry rather than its bounding box, giving more accurate population totals
for irregularly shaped areas.

Target org units:
  Use --org-unit to process a single org unit, or --org-unit-level to process
  all org units at a given hierarchy level (e.g. level 2 = districts in Sierra Leone).

The pipeline:
  1. Create metadata — a data element and data set in DHIS2 (idempotent, stable UIDs)
  2. Fetch org units as a GeoDataFrame from DHIS2
  3. Download WorldPop raster for the country (once, shared across org units)
  4. Compute polygon-based zonal statistics using transforms.spatial.reduce
  5. Push all yearly population values into DHIS2

Usage:
  # Single org unit (Bo district)
  uv run python examples/dhis2eo/pipeline_worldpop.py --org-unit O6uvpzGd5pu --country-code SLE

  # All districts (level 2) in Sierra Leone
  uv run python examples/dhis2eo/pipeline_worldpop.py --org-unit-level 2 --country-code SLE

  # Multiple years
  uv run python examples/dhis2eo/pipeline_worldpop.py --org-unit-level 2 --country-code SLE \
      --start 2020 --end 2022
"""

import argparse
import json
import sys

import geopandas as gpd
import xarray as xr
from dhis2eo.data.worldpop.pop_total import yearly
from dhis2eo.integrations.pandas import dataframe_to_dhis2_json
from earthkit import transforms

from climate_tools.config import make_client
from climate_tools.schemas import DataElement, DataSet, DataSetElement, IdRef, MetadataPayload, PeriodType

# ---------------------------------------------------------------------------
# Stable UIDs for DHIS2 metadata.
# Fixed UIDs make this script idempotent — safe to run repeatedly.
# ---------------------------------------------------------------------------
DE_WORLDPOP_POP = "hTgzX3mFrS9"  # Data element: DEMO: WorldPop estimated population
DS_POPULATION = "kR2jYbePnNf"  # Data set: DEMO: Population Estimates

# ---------------------------------------------------------------------------
# Parse command-line arguments
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(description="WorldPop pipeline: download, aggregate, push to DHIS2")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("--org-unit", help="Single DHIS2 org unit UID (e.g. O6uvpzGd5pu)")
group.add_argument("--org-unit-level", type=int, help="Process all org units at this level (e.g. 2 for districts)")
parser.add_argument("--country-code", required=True, help="ISO3 country code (e.g. SLE for Sierra Leone)")
parser.add_argument("--start", default="2020", help="Start year (default: 2020)")
parser.add_argument("--end", default="2020", help="End year (default: 2020)")
parser.add_argument("--dirname", default="worldpop_data", help="Download directory (default: worldpop_data)")
parser.add_argument("--prefix", default=None, help="File prefix (default: pop_{country_code})")
args = parser.parse_args()

if args.prefix is None:
    args.prefix = f"pop_{args.country_code.lower()}"

# ---------------------------------------------------------------------------
# Step 0: Connect to DHIS2
# ---------------------------------------------------------------------------
client = make_client()
print(f"Connected to {client.base_url}")

# ---------------------------------------------------------------------------
# Step 1: Fetch org units as GeoDataFrame
# ---------------------------------------------------------------------------
# Org unit geometries are fetched as GeoJSON and loaded into a GeoDataFrame.
# The "id" column is used later as the mask dimension for zonal statistics.

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
# We create a data element for population count and a yearly data set.
# The /api/metadata endpoint with default MERGE strategy creates-or-updates.

print("\n--- Step 2: Creating DHIS2 metadata ---")

de_pop = DataElement(
    id=DE_WORLDPOP_POP,
    name="DEMO: WorldPop estimated population",
    shortName="DEMO: WorldPop pop",
    valueType="INTEGER",
)

metadata = MetadataPayload(
    dataElements=[de_pop],
    dataSets=[
        DataSet(
            id=DS_POPULATION,
            name="DEMO: Population Estimates",
            shortName="DEMO: Pop Estimates",
            periodType=PeriodType.YEARLY,
            dataSetElements=[DataSetElement(dataElement=de_pop)],
            organisationUnits=[IdRef(id=uid) for uid in org_units["id"]],  # pyright: ignore[reportIndexIssue]
        ),
    ],
)

result = client.post("/api/metadata", json=metadata.model_dump(exclude_none=True))
stats = result.get("stats", {})
print(f"  Metadata import: created={stats.get('created', 0)}, updated={stats.get('updated', 0)}")

# ---------------------------------------------------------------------------
# Step 3: Download WorldPop data (once for the whole country)
# ---------------------------------------------------------------------------
# WorldPop data is downloaded per country as GeoTIFF files, one per year.
# The dhis2eo library converts them to NetCDF for easy processing with xarray.
# We download once, then use polygon masking in Step 4.

print("\n--- Step 3: Downloading WorldPop data ---")

files = yearly.download(
    start=args.start,
    end=args.end,
    country_code=args.country_code,
    dirname=args.dirname,
    prefix=args.prefix,
)
print(f"  Downloaded {len(files)} file(s) for {args.country_code}")

# Open the country-wide raster as an xarray Dataset
ds = xr.open_mfdataset(
    files,
    combine="nested",
    concat_dim="time",
    compat="override",
    coords="minimal",  # type: ignore[arg-type]  # pyright: ignore[reportArgumentType]
    data_vars="minimal",
)

# ---------------------------------------------------------------------------
# Step 4: Compute polygon-based zonal statistics
# ---------------------------------------------------------------------------
# transforms.spatial.reduce masks the raster to each org unit's exact polygon
# boundary and sums the population grid cells within it. This is more accurate
# than bounding-box clipping for irregularly shaped org units.

print("\n--- Step 4: Computing zonal statistics per org unit ---")

ds_org_units = transforms.spatial.reduce(
    ds["pop_total"],
    org_units,  # pyright: ignore[reportArgumentType]
    mask_dim="id",
    how="sum",
    lat_key="y",
    lon_key="x",
)

df = ds_org_units.to_dataframe().reset_index()
df["time"] = df["time"].dt.year.astype(str)
df["value"] = df["pop_total"].astype(int)
df = df.dropna(subset=["pop_total"])

# Build a lookup from org unit ID to name for display
id_to_name = dict(zip(org_units["id"], org_units["name"], strict=True))

print(f"  Total: {len(df)} value(s) across {len(org_units)} org unit(s)")

for ou_id, ou_df in df.groupby("id", sort=False):
    name = id_to_name.get(ou_id, ou_id)
    print(f"\n  {name} ({ou_id})")
    for _, row in ou_df.iterrows():
        print(f"    {row['time']}: {int(row['value']):,} people")

# ---------------------------------------------------------------------------
# Step 5: Push data into DHIS2
# ---------------------------------------------------------------------------
# Convert the DataFrame to the DHIS2 dataValueSets JSON format and POST it.

print("\n--- Step 5: Pushing data to DHIS2 ---")

if df.empty:
    print("  No data to push.")
else:
    payload = dataframe_to_dhis2_json(
        df,
        data_element_id=DE_WORLDPOP_POP,
        org_unit_col="id",
        period_col="time",
        value_col="value",
    )
    print(f"  Sending {len(payload['dataValues'])} data value(s)...")

    result = client.post_data_value_set(payload)
    imported = result.get("response", {}).get("importCount", {})
    print(f"  Imported: {imported.get('imported', 0)}, Updated: {imported.get('updated', 0)}")

print("\nDone! Population data is now available in DHIS2.")
