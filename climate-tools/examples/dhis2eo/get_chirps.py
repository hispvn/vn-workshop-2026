"""Download CHIRPS v3 daily precipitation for DHIS2 org unit(s) and print values.

CHIRPS (Climate Hazards Group InfraRed Precipitation with Station data) provides
daily rainfall estimates at ~5km resolution, combining satellite imagery with
ground station data. It covers 50 S-50 N and is widely used for drought monitoring
and food security analysis in tropical regions.

This script:
  1. Connects to DHIS2 and fetches org unit geometries
  2. Downloads CHIRPS daily precipitation for the combined bounding box
  3. Computes zonal statistics (mean precipitation per org unit)
  4. Prints per-org-unit daily precipitation values

Usage:
  # Single org unit
  uv run python examples/dhis2eo/get_chirps.py --country-code SLE --org-unit O6uvpzGd5pu

  # All org units at level 2 (districts)
  uv run python examples/dhis2eo/get_chirps.py --country-code SLE --org-unit-level 2

  # Custom date range
  uv run python examples/dhis2eo/get_chirps.py --country-code SLE --org-unit O6uvpzGd5pu --start 2023-06 --end 2023-08
"""

import argparse
import json

import geopandas as gpd
import xarray as xr
from dhis2eo.data.chc.chirps3 import daily
from earthkit import transforms

from climate_tools.config import make_client

# -- Parse command-line arguments --
parser = argparse.ArgumentParser(description="Download CHIRPS precipitation for DHIS2 org unit(s)")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("--org-unit", help="Single DHIS2 org unit UID (e.g. O6uvpzGd5pu)")
group.add_argument("--org-unit-level", type=int, help="All org units at this level (e.g. 2 for districts)")
parser.add_argument("--start", default="2024-01", help="Start month (default: 2024-01)")
parser.add_argument("--end", default="2024-01", help="End month (default: 2024-01)")
parser.add_argument("--country-code", required=True, help="ISO3 country code (e.g. SLE)")
parser.add_argument("--dirname", default="chirps_data", help="Output directory (default: chirps_data)")
parser.add_argument("--prefix", default=None, help="File prefix (default: chirps_{country_code})")
args = parser.parse_args()

if args.prefix is None:
    args.prefix = f"chirps_{args.country_code.lower()}"

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

# -- Download CHIRPS data --
west, south, east, north = org_units.total_bounds
bbox = (float(west), float(south), float(east), float(north))
print(f"\nDownloading CHIRPS data (bbox {bbox})...")
files = daily.download(
    start=args.start,
    end=args.end,
    bbox=bbox,
    dirname=args.dirname,
    prefix=args.prefix,
)

# -- Open and compute zonal statistics --
data = xr.open_mfdataset(files, combine="nested", concat_dim="time")

ds_org_units = transforms.spatial.reduce(
    data["precip"],
    org_units,  # pyright: ignore[reportArgumentType]
    mask_dim="id",
    how="mean",
    lat_key="y",
    lon_key="x",
)

df = ds_org_units.to_dataframe().reset_index()
df = df.dropna(subset=["precip"])

id_to_name = dict(zip(org_units["id"], org_units["name"], strict=True))

print(f"\nCHIRPS daily precipitation ({len(df)} values):")
for ou_id, ou_df in df.groupby("id", sort=False):
    name = id_to_name.get(ou_id, ou_id)
    print(f"\n  {name} ({ou_id})")
    for _, row in ou_df.iterrows():
        print(f"    {row['time']}: {row['precip']:.2f} mm/day")
