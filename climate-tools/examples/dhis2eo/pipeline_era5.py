"""End-to-end pipeline: ERA5-Land daily climate data into DHIS2.

This script demonstrates the full workflow for getting reanalysis climate data
into DHIS2 — from creating metadata, downloading hourly data, computing
daily aggregates, and pushing values into DHIS2.

ERA5-Land is produced by ECMWF via the Copernicus Climate Data Store. It provides
hourly estimates of land surface variables at ~9km resolution, globally, from 1950
to near-present. Common variables include:
  - total_precipitation          — hourly rainfall/snowfall (m)
  - 2m_temperature               — air temperature 2m above ground (K)
  - 2m_dewpoint_temperature      — dewpoint temp, proxy for humidity (K)
  - 10m_u/v_component_of_wind    — wind speed components at 10m (m/s)
  - surface_solar_radiation_downwards — incoming solar radiation (J/m²)
  - total_evaporation            — evaporation from land surface (m)

We aggregate hourly values into daily totals or means per org unit, convert
units to human-friendly forms (K→°C, m→mm, J/m²→MJ/m²), and push into DHIS2.

For accumulated variables (tp, ssrd, e), the pipeline first converts cumulative
forecast-step values to incremental differences before aggregation.

Data is downloaded once for all org units using their combined bounding box, then
polygon-based zonal statistics are computed using earthkit-transforms for accurate
spatial aggregation over each org unit's exact geometry.

Prerequisites:
  CDS API credentials in .env: ECMWF_DATASTORES_URL and ECMWF_DATASTORES_KEY
  Sign up at https://cds.climate.copernicus.eu/

Target org units:
  Use --org-unit to process a single org unit, or --org-unit-level to process
  all org units at a given hierarchy level (e.g. level 2 = districts in Sierra Leone).

The pipeline:
  1. Create metadata — data elements and data set in DHIS2 (idempotent, stable UIDs)
  2. Fetch org units as a GeoDataFrame from DHIS2
  3. Download ERA5-Land data once for all org units (using combined bounds)
  4. For each variable: cumulative→incremental → daily reduce → spatial reduce → unit conversion
  5. Push all values into DHIS2

Usage:
  # Single org unit (Bo district), all variables (default)
  uv run python examples/dhis2eo/pipeline_era5.py --org-unit O6uvpzGd5pu

  # All districts, subset of variables
  uv run python examples/dhis2eo/pipeline_era5.py --org-unit-level 2 \
      --variables total_precipitation 2m_temperature 2m_dewpoint_temperature
"""

import argparse
import json
import logging
import sys
from typing import Callable

import geopandas as gpd
import pandas as pd
import xarray as xr
from dhis2eo.data.cds.era5_land import hourly
from dhis2eo.integrations.pandas import dataframe_to_dhis2_json
from earthkit import transforms

from climate_tools.config import make_client
from climate_tools.schemas import DataElement, DataSet, DataSetElement, IdRef, MetadataPayload, PeriodType

# The dhis2eo library adds its own StreamHandler to its loggers (force_logging),
# so we only configure the ecmwf.datastores logger for CDS API progress messages.
# Using basicConfig here would duplicate every dhis2eo log line.
logging.getLogger("ecmwf.datastores").setLevel(logging.DEBUG)

# ---------------------------------------------------------------------------
# ERA5 variable registry.
#
# Maps each ERA5 CDS variable name to:
#   - nc_var:       variable name in the downloaded NetCDF file
#   - de_id:        stable DHIS2 data element UID
#   - de_name:      human-readable name (prefixed with DEMO:)
#   - short_name:   DHIS2 short name (max 50 chars)
#   - agg:          temporal aggregation method ("sum" or "mean")
#   - convert:      unit conversion function (applied after aggregation)
#   - unit:         display unit for logging
#   - dhis2_agg:    DHIS2 aggregationType for the data element
#
# To add a new variable: add an entry here and it will automatically get
# a data element, be included in the data set, and be processed.
# ---------------------------------------------------------------------------
VARIABLE_REGISTRY = {
    "total_precipitation": {
        "nc_var": "tp",
        "de_id": "fYr3iz0kVbA",
        "de_name": "DEMO: ERA5 daily total precipitation (mm)",
        "short_name": "DEMO: ERA5 precip mm",
        "agg": "sum",
        "is_cumulative": True,
        "convert": lambda v: v * 1000.0,  # meters → millimeters
        "unit": "mm",
        "dhis2_agg": "SUM",
    },
    "2m_temperature": {
        "nc_var": "t2m",
        "de_id": "gN2hQGaRpM7",
        "de_name": "DEMO: ERA5 daily mean 2m temperature (°C)",
        "short_name": "DEMO: ERA5 temp °C",
        "agg": "mean",
        "is_cumulative": False,
        "convert": lambda v: v - 273.15,  # Kelvin → Celsius
        "unit": "°C",
        "dhis2_agg": "AVERAGE",
    },
    "2m_dewpoint_temperature": {
        "nc_var": "d2m",
        "de_id": "jK4mRx7hVq2",
        "de_name": "DEMO: ERA5 daily mean 2m dewpoint temperature (°C)",
        "short_name": "DEMO: ERA5 dewpoint °C",
        "agg": "mean",
        "is_cumulative": False,
        "convert": lambda v: v - 273.15,  # Kelvin → Celsius
        "unit": "°C",
        "dhis2_agg": "AVERAGE",
    },
    "10m_u_component_of_wind": {
        "nc_var": "u10",
        "de_id": "kL5nSt8wUr3",
        "de_name": "DEMO: ERA5 daily mean 10m u-wind (m/s)",
        "short_name": "DEMO: ERA5 u-wind m/s",
        "agg": "mean",
        "is_cumulative": False,
        "convert": lambda v: v,  # already m/s
        "unit": "m/s",
        "dhis2_agg": "AVERAGE",
    },
    "10m_v_component_of_wind": {
        "nc_var": "v10",
        "de_id": "lM6oTu9xVs4",
        "de_name": "DEMO: ERA5 daily mean 10m v-wind (m/s)",
        "short_name": "DEMO: ERA5 v-wind m/s",
        "agg": "mean",
        "is_cumulative": False,
        "convert": lambda v: v,  # already m/s
        "unit": "m/s",
        "dhis2_agg": "AVERAGE",
    },
    "surface_solar_radiation_downwards": {
        "nc_var": "ssrd",
        "de_id": "mN7pUv0yWt5",
        "de_name": "DEMO: ERA5 daily total solar radiation (MJ/m²)",
        "short_name": "DEMO: ERA5 solar MJ/m2",
        "agg": "sum",
        "is_cumulative": True,
        "convert": lambda v: v / 1_000_000.0,  # J/m² → MJ/m²
        "unit": "MJ/m²",
        "dhis2_agg": "SUM",
    },
    "total_evaporation": {
        "nc_var": "e",
        "de_id": "nO8qWx1zXu6",
        "de_name": "DEMO: ERA5 daily total evaporation (mm)",
        "short_name": "DEMO: ERA5 evaporation mm",
        "agg": "sum",
        "is_cumulative": True,
        "convert": lambda v: abs(v) * 1000.0,  # meters → mm (negative = upward flux)
        "unit": "mm",
        "dhis2_agg": "SUM",
    },
}

DS_ERA5 = "bWx4RnGqLk3"  # Data set: DEMO: ERA5-Land Climate Data

# ---------------------------------------------------------------------------
# Parse command-line arguments
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(description="ERA5-Land pipeline: download, aggregate, push to DHIS2")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("--org-unit", help="Single DHIS2 org unit UID (e.g. O6uvpzGd5pu)")
group.add_argument("--org-unit-level", type=int, help="Process all org units at this level (e.g. 2 for districts)")
parser.add_argument("--start", default="2025-01-01", help="Start date, YYYY-MM-DD (default: 2025-01-01)")
parser.add_argument("--end", default="2025-01-01", help="End date, YYYY-MM-DD (default: 2025-01-01)")
# Default to all variables: the CDS API makes one request per month regardless of
# variable count, and the cached filename ({prefix}_{year}-{month}.nc) doesn't
# encode which variables are inside. Downloading everything avoids silent cache
# misses when later requesting additional variables.
parser.add_argument(
    "--variables",
    nargs="+",
    default=list(VARIABLE_REGISTRY.keys()),
    help=f"ERA5 variables to download (default: all). Supported: {', '.join(VARIABLE_REGISTRY.keys())}",
)
parser.add_argument("--dirname", default="era5_data", help="Download directory (default: era5_data)")
parser.add_argument("--prefix", default="era5", help="File prefix (default: era5)")
args = parser.parse_args()

# Validate requested variables against registry
for var in args.variables:
    if var not in VARIABLE_REGISTRY:
        print(f"ERROR: Unknown variable '{var}'. Supported: {', '.join(VARIABLE_REGISTRY.keys())}")
        sys.exit(1)

# Build the subset of registry entries we'll actually use
active_vars = {name: VARIABLE_REGISTRY[name] for name in args.variables}

# ---------------------------------------------------------------------------
# Step 0: Connect to DHIS2
# ---------------------------------------------------------------------------
client = make_client()
print(f"Connected to {client.base_url}")

# ---------------------------------------------------------------------------
# Step 1: Fetch org units as GeoDataFrame
# ---------------------------------------------------------------------------
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
# We create one data element per variable and a single data set grouping them.
# The /api/metadata endpoint with default MERGE strategy creates-or-updates by UID.

print("\n--- Step 2: Creating DHIS2 metadata ---")
print(f"  Variables: {', '.join(active_vars.keys())}")

data_elements = [
    DataElement(
        id=str(info["de_id"]),
        name=str(info["de_name"]),
        shortName=str(info["short_name"]),
        aggregationType=str(info["dhis2_agg"]),
    )
    for info in active_vars.values()
]

metadata = MetadataPayload(
    dataElements=data_elements,
    dataSets=[
        DataSet(
            id=DS_ERA5,
            name="DEMO: ERA5-Land Climate Data",
            shortName="DEMO: ERA5-Land",
            periodType=PeriodType.DAILY,
            dataSetElements=[DataSetElement(dataElement=de) for de in data_elements],
            organisationUnits=[IdRef(id=uid) for uid in org_units["id"]],  # pyright: ignore[reportIndexIssue]
        ),
    ],
)

result = client.post("/api/metadata", json=metadata.model_dump(exclude_none=True))
stats = result.get("stats", {})
print(f"  Metadata import: created={stats.get('created', 0)}, updated={stats.get('updated', 0)}")

# ---------------------------------------------------------------------------
# Step 3: Download ERA5-Land data (once for all org units)
# ---------------------------------------------------------------------------
# We download once using the combined bounding box of all org units,
# then use polygon-based zonal statistics in Step 4.

print("\n--- Step 3: Downloading ERA5-Land data ---")

west, south, east, north = org_units.total_bounds
bbox = (float(west), float(south), float(east), float(north))
print(f"  Bounding box: {bbox}")

files = hourly.download(
    start=args.start,
    end=args.end,
    bbox=bbox,
    dirname=args.dirname,
    prefix=args.prefix,
    variables=args.variables,
)
print(f"  Downloaded {len(files)} file(s)")

ds = xr.open_mfdataset(files, join="exact", compat="override")

# Drop auxiliary variables that may be present in ERA5 files
ds = ds.drop_vars([v for v in ["number", "expver"] if v in ds])

# ---------------------------------------------------------------------------
# Step 4: Compute zonal statistics per variable and org unit
# ---------------------------------------------------------------------------
# For each variable we:
#   1. Convert cumulative → incremental (for accumulated variables like tp, ssrd, e)
#   2. Aggregate hourly → daily (sum or mean, per registry)
#   3. Use transforms.spatial.reduce for polygon-based spatial mean per org unit
#   4. Apply unit conversion
#   5. Collect all records for bulk push

print("\n--- Step 4: Computing zonal statistics ---")

all_records = []
id_to_name = dict(zip(org_units["id"], org_units["name"], strict=True))

for var_name, info in active_vars.items():
    nc_var = str(info["nc_var"])
    if nc_var not in ds.data_vars:
        print(f"  WARNING: {nc_var} not found in downloaded data, skipping {var_name}")
        continue

    da = ds[nc_var]

    # Determine the time dimension name (ERA5 uses "valid_time")
    time_dim = "valid_time" if "valid_time" in da.dims else "time"

    # Convert cumulative forecast-step values to incremental differences
    if info["is_cumulative"]:
        ds_diffs = da.diff(dim=time_dim)
        da = xr.where(ds_diffs < 0, da.isel({time_dim: slice(1, None)}), ds_diffs)

    # Temporal aggregation: hourly → daily (sum or mean)
    daily_da = transforms.temporal.daily_reduce(
        da, how=str(info["agg"]), time_shift={"hours": 0}, remove_partial_periods=False
    )

    # Spatial aggregation: polygon-based mean per org unit
    ds_org = transforms.spatial.reduce(
        daily_da,
        org_units,  # pyright: ignore[reportArgumentType]
        mask_dim="id",
        how="mean",
    )

    # Convert to dataframe
    var_df = ds_org.to_dataframe().reset_index()
    var_df = var_df.dropna(subset=[nc_var])

    # Apply unit conversion
    convert_fn: Callable[[float], float] = info["convert"]  # type: ignore[assignment, no-redef]
    var_df["value"] = var_df[nc_var].apply(convert_fn)  # pyright: ignore[reportCallIssue]

    # Determine the time column name after daily_reduce
    time_col = time_dim if time_dim in var_df.columns else "time"

    print(f"\n  {var_name}:")
    for ou_id, ou_df in var_df.groupby("id", sort=False):
        name = id_to_name.get(ou_id, ou_id)
        print(f"    {name} ({ou_id})")
        for _, row in ou_df.iterrows():
            all_records.append(
                {
                    "orgUnit": str(row["id"]),
                    time_col: str(row[time_col]),
                    "value": str(row["value"]),
                    "dataElement": str(info["de_id"]),
                }
            )
            print(f"      {row[time_col]}: {row['value']:.2f} {info['unit']}")

print(f"\n  Total: {len(all_records)} value(s) across {len(org_units)} org unit(s)")

# ---------------------------------------------------------------------------
# Step 5: Push data into DHIS2
# ---------------------------------------------------------------------------
# We push one data element at a time using dataframe_to_dhis2_json.

print("\n--- Step 5: Pushing data to DHIS2 ---")

df = pd.DataFrame(all_records)

if df.empty:
    print("  No data to push.")
else:
    # Determine the time column name (ERA5 uses "valid_time")
    period_col = "valid_time" if "valid_time" in df.columns else "time"

    for de_id, de_group in df.groupby("dataElement"):
        de_name = next((str(i["de_name"]) for i in active_vars.values() if i["de_id"] == de_id), str(de_id))
        payload = dataframe_to_dhis2_json(
            de_group,
            data_element_id=de_id,
            org_unit_col="orgUnit",
            period_col=period_col,
            value_col="value",
        )
        print(f"  Sending {len(payload['dataValues'])} value(s) for {de_name}...")
        result = client.post_data_value_set(payload)
        imported = result.get("response", {}).get("importCount", {})
        print(f"  Imported: {imported.get('imported', 0)}, Updated: {imported.get('updated', 0)}")

print("\nDone! Data is now available in DHIS2.")
