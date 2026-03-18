"""Download ERA5-Land climate data for DHIS2 org unit(s), aggregate to daily, and print values.

ERA5-Land is a climate reanalysis dataset produced by ECMWF (European Centre for
Medium-Range Weather Forecasts) via the Copernicus Climate Data Store. It provides
hourly estimates of land surface variables at ~9km resolution, globally, from 1950
to near-present. Common variables include temperature, precipitation, soil moisture,
and evaporation.

Prerequisites:
  You need a CDS API key. Sign up at https://cds.climate.copernicus.eu/ and add
  your key to .env as ECMWF_DATASTORES_URL and ECMWF_DATASTORES_KEY.

This script:
  1. Connects to DHIS2 and fetches org unit geometries
  2. Downloads ERA5-Land hourly data for the combined bounding box
  3. Converts cumulative variables to incremental, aggregates hourly → daily
  4. Computes zonal statistics (mean per org unit) for each variable
  5. Applies unit conversion (K→°C, m→mm, J/m²→MJ/m²) and prints per-org-unit values

Usage:
  # Single org unit
  uv run python examples/dhis2eo/get_era5.py --org-unit O6uvpzGd5pu

  # All org units at level 2 (districts)
  uv run python examples/dhis2eo/get_era5.py --org-unit-level 2

  # Subset of variables
  uv run python examples/dhis2eo/get_era5.py --org-unit O6uvpzGd5pu --variables 2m_temperature total_precipitation
"""

import argparse
import json
import logging

import geopandas as gpd
import xarray as xr
from dhis2eo.data.cds.era5_land import hourly
from earthkit import transforms

from climate_tools.config import make_client

# The dhis2eo library adds its own StreamHandler to its loggers (force_logging),
# so we only configure the ecmwf.datastores logger for CDS API progress messages.
# Using basicConfig here would duplicate every dhis2eo log line.
logging.getLogger("ecmwf.datastores").setLevel(logging.DEBUG)

ALL_VARIABLES = [
    "total_precipitation",
    "2m_temperature",
    "2m_dewpoint_temperature",
    "10m_u_component_of_wind",
    "10m_v_component_of_wind",
    "surface_solar_radiation_downwards",
    "total_evaporation",
]

# Variable metadata: NetCDF name, temporal aggregation, cumulative flag, unit conversion, display unit
VARIABLE_INFO = {
    "total_precipitation": {
        "nc_var": "tp",
        "agg": "sum",
        "is_cumulative": True,
        "convert": lambda v: v * 1000.0,
        "unit": "mm",
    },
    "2m_temperature": {
        "nc_var": "t2m",
        "agg": "mean",
        "is_cumulative": False,
        "convert": lambda v: v - 273.15,
        "unit": "°C",
    },
    "2m_dewpoint_temperature": {
        "nc_var": "d2m",
        "agg": "mean",
        "is_cumulative": False,
        "convert": lambda v: v - 273.15,
        "unit": "°C",
    },
    "10m_u_component_of_wind": {
        "nc_var": "u10",
        "agg": "mean",
        "is_cumulative": False,
        "convert": lambda v: v,
        "unit": "m/s",
    },
    "10m_v_component_of_wind": {
        "nc_var": "v10",
        "agg": "mean",
        "is_cumulative": False,
        "convert": lambda v: v,
        "unit": "m/s",
    },
    "surface_solar_radiation_downwards": {
        "nc_var": "ssrd",
        "agg": "sum",
        "is_cumulative": True,
        "convert": lambda v: v / 1_000_000.0,
        "unit": "MJ/m²",
    },
    "total_evaporation": {
        "nc_var": "e",
        "agg": "sum",
        "is_cumulative": True,
        "convert": lambda v: abs(v) * 1000.0,
        "unit": "mm",
    },
}

# -- Parse command-line arguments --
parser = argparse.ArgumentParser(description="Download ERA5-Land climate data for DHIS2 org unit(s)")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("--org-unit", help="Single DHIS2 org unit UID (e.g. O6uvpzGd5pu)")
group.add_argument("--org-unit-level", type=int, help="All org units at this level (e.g. 2 for districts)")
parser.add_argument("--start", default="2025-01-01", help="Start date (default: 2025-01-01)")
parser.add_argument("--end", default="2025-01-01", help="End date (default: 2025-01-01)")
# Default to all variables: the CDS API makes one request per month regardless of
# variable count, and the cached filename doesn't encode which variables are inside.
# Downloading everything avoids cache misses when adding variables later (~1 MB vs
# ~125 KB per month — negligible).
parser.add_argument(
    "--variables",
    nargs="+",
    default=ALL_VARIABLES,
    help='Variables to download, or "all" for all supported variables (default: all)',
)
parser.add_argument("--dirname", default="era5_data", help="Output directory (default: era5_data)")
parser.add_argument("--prefix", default="era5", help="File prefix (default: era5)")
args = parser.parse_args()

if args.variables == ["all"]:
    args.variables = ALL_VARIABLES

# -- Connect to DHIS2 --
client = make_client()

# -- Fetch org units as GeoDataFrame --
if args.org_unit:
    ou_meta = client.get(f"/api/organisationUnits/{args.org_unit}", params={"fields": "id,level"})
    level = ou_meta["level"]
    geojson = client.get_org_units_geojson(level=level)
    org_units = gpd.read_file(json.dumps(geojson))
    org_units: gpd.GeoDataFrame = org_units[org_units["id"] == args.org_unit]  # type: ignore[assignment, no-redef]
else:
    geojson = client.get_org_units_geojson(level=args.org_unit_level)
    org_units = gpd.read_file(json.dumps(geojson))
org_units: gpd.GeoDataFrame = org_units[org_units.geometry.notna()]  # type: ignore[assignment, no-redef]

print(f"Found {len(org_units)} org unit(s)")
for _, ou in org_units.iterrows():
    print(f"  {ou['id']}  {ou['name']}")

# -- Download ERA5-Land data --
west, south, east, north = org_units.total_bounds
bbox = (float(west), float(south), float(east), float(north))
print(f"\nDownloading ERA5-Land data (bbox {bbox})...")
files = hourly.download(
    start=args.start,
    end=args.end,
    bbox=bbox,
    dirname=args.dirname,
    prefix=args.prefix,
    variables=args.variables,
)

# -- Open and compute daily zonal statistics --
data = xr.open_mfdataset(files, join="exact", compat="override")

# Drop auxiliary variables that may be present in ERA5 files
data = data.drop_vars([v for v in ["number", "expver"] if v in data])

id_to_name = dict(zip(org_units["id"], org_units["name"], strict=True))

print("\nERA5-Land daily climate data:")
for var_name in args.variables:
    info = VARIABLE_INFO.get(var_name)
    if info is None:
        continue
    nc_var = info["nc_var"]
    if nc_var not in data.data_vars:
        print(f"  WARNING: {nc_var} not found in downloaded data, skipping {var_name}")
        continue

    da = data[nc_var]
    time_dim = "valid_time" if "valid_time" in da.dims else "time"

    # Cumulative forecast-step values → incremental differences
    if info["is_cumulative"]:
        ds_diffs = da.diff(dim=time_dim)
        da = xr.where(ds_diffs < 0, da.isel({time_dim: slice(1, None)}), ds_diffs)

    # Hourly → daily aggregation (sum or mean)
    daily_da = transforms.temporal.daily_reduce(
        da, how=str(info["agg"]), time_shift={"hours": 0}, remove_partial_periods=False
    )

    # Spatial aggregation: polygon-based mean per org unit
    ds_org_units = transforms.spatial.reduce(
        daily_da,
        org_units,  # pyright: ignore[reportArgumentType]
        mask_dim="id",
        how="mean",
    )

    df = ds_org_units.to_dataframe().reset_index()
    df = df.dropna(subset=[nc_var])

    # Apply unit conversion
    convert_fn = info["convert"]
    assert callable(convert_fn)
    df["value"] = df[nc_var].apply(convert_fn)

    time_col = time_dim if time_dim in df.columns else "time"

    print(f"\n  {var_name} ({info['unit']}):")
    for ou_id, ou_df in df.groupby("id", sort=False):
        name = id_to_name.get(ou_id, ou_id)
        print(f"    {name} ({ou_id})")
        for _, row in ou_df.iterrows():
            print(f"      {row[time_col]}: {row['value']:.4f} {info['unit']}")
