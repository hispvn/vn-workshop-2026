"""Download WorldPop population data (global2 version) and print values.

WorldPop provides gridded population estimates — modelled counts of how many people
live in each grid cell, based on census data, satellite imagery, and other covariates.
These datasets are essential for health planning, resource allocation, and computing
population-weighted indicators in DHIS2.

This script uses the "global2" version (2015-2030, 100m resolution), which is the
newer constrained dataset. For the older version (2000-2020, ~1km resolution), see
get_worldpop1.py.

Unlike CHIRPS and ERA5, WorldPop data is downloaded per country (not per bounding box),
so you must provide an ISO3 country code (e.g. SLE for Sierra Leone).

This script:
  1. Downloads the WorldPop GeoTIFF for the given country and year(s)
  2. Opens it as an xarray Dataset and prints a summary

Usage:
  uv run python examples/dhis2eo/get_worldpop2.py --country-code SLE
  uv run python examples/dhis2eo/get_worldpop2.py --country-code SLE --start 2020 --end 2025
"""

import argparse

import xarray as xr
from dhis2eo.data.worldpop.pop_total import yearly

# -- Parse command-line arguments --
parser = argparse.ArgumentParser(description="Download WorldPop population data (global2)")
parser.add_argument("--country-code", required=True, help="ISO3 country code (e.g. SLE)")
parser.add_argument("--start", default="2020", help="Start year (default: 2020)")
parser.add_argument("--end", default="2020", help="End year (default: 2020)")
parser.add_argument("--dirname", default="worldpop_data", help="Output directory (default: worldpop_data)")
parser.add_argument("--prefix", default=None, help="File prefix (default: pop_{country_code})")
args = parser.parse_args()

if args.prefix is None:
    args.prefix = f"pop_{args.country_code.lower()}"

# -- Download WorldPop data --
print(f"Downloading WorldPop global2 data for {args.country_code}...")
files = yearly.download(
    start=args.start,
    end=args.end,
    country_code=args.country_code,
    dirname=args.dirname,
    prefix=args.prefix,
)

# -- Open and inspect the data --
data = xr.open_mfdataset(
    files,
    combine="nested",
    concat_dim="time",
    compat="override",
    coords="minimal",  # type: ignore[arg-type]  # pyright: ignore[reportArgumentType]
    data_vars="minimal",
)
print("\nWorldPop population data (global2):")
print(f"  Variables: {list(data.data_vars)}")
print(f"  Dimensions: {dict(data.sizes)}")
print(data)
