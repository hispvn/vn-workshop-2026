"""Download WorldPop age-sex disaggregated population data and print values.

WorldPop provides age-sex structure rasters under the AgeSex_structures
collection (R2025A release, 2015-2030, 100m resolution). These rasters give
population counts broken down by sex and 5-year age group per grid cell.

Available datasets:
  - Total male / total female (all ages combined)
  - Age-sex specific: 20 age groups x 2 sexes = 40 rasters per country-year

Age groups: 0, 1-4, 5-9, 10-14, 15-19, ..., 85-89, 90+

This script monkey-patches dhis2eo's URL function to download from the
AgeSex_structures path instead of the total population path.

Usage:
  # All sex/age groups (default)
  uv run python examples/dhis2eo/get_worldpop_agesex.py --country-code SLE

  # All sex/age groups with zonal stats for a single org unit
  uv run python examples/dhis2eo/get_worldpop_agesex.py --country-code SLE --org-unit O6uvpzGd5pu

  # All sex/age groups with zonal stats for all org units at a level
  uv run python examples/dhis2eo/get_worldpop_agesex.py --country-code SLE --org-unit-level 2

  # Total male population only
  uv run python examples/dhis2eo/get_worldpop_agesex.py --country-code SLE --sex M

  # Males aged 25-29
  uv run python examples/dhis2eo/get_worldpop_agesex.py --country-code SLE --sex m --age 25

  # List available age groups
  uv run python examples/dhis2eo/get_worldpop_agesex.py --country-code SLE --list-groups
"""

import argparse
import json

import geopandas as gpd
import xarray as xr
from dhis2eo.data.worldpop.pop_total import yearly
from earthkit import transforms

from climate_tools.config import make_client

# ---------------------------------------------------------------------------
# WorldPop age-sex constants
# ---------------------------------------------------------------------------
# Age group codes as they appear in filenames (zero-padded)
AGE_GROUPS = [
    "00",
    "01",
    "05",
    "10",
    "15",
    "20",
    "25",
    "30",
    "35",
    "40",
    "45",
    "50",
    "55",
    "60",
    "65",
    "70",
    "75",
    "80",
    "85",
    "90",
]

AGE_LABELS = {
    "00": "0 (infants)",
    "01": "1-4",
    "05": "5-9",
    "10": "10-14",
    "15": "15-19",
    "20": "20-24",
    "25": "25-29",
    "30": "30-34",
    "35": "35-39",
    "40": "40-44",
    "45": "45-49",
    "50": "50-54",
    "55": "55-59",
    "60": "60-64",
    "65": "65-69",
    "70": "70-74",
    "75": "75-79",
    "80": "80-84",
    "85": "85-89",
    "90": "90+",
}

# All sex/age combinations: totals + age-specific for both sexes
ALL_DOWNLOADS: list[tuple[str, str | None]] = []
for _sex in ["M", "F"]:
    ALL_DOWNLOADS.append((_sex, None))  # total male/female
    for _age in AGE_GROUPS:
        ALL_DOWNLOADS.append((_sex, _age))


def _agesex_url(year: str, country_code: str, _version: str, sex: str, age: str | None) -> str:
    """Build a WorldPop AgeSex URL.

    For totals (no age group): filename uses T_M or T_F (uppercase sex).
    For age-specific: filename uses m_25 or f_10 (lowercase sex, age code).
    """
    cc = country_code.lower()
    CC = country_code.upper()
    if age is None:
        # Total male/female: {iso}_T_{SEX}_{year}_...
        filename = f"{cc}_T_{sex.upper()}_{year}_CN_100m_R2025A_v1.tif"
    else:
        # Age-specific: {iso}_{sex}_{age}_{year}_...
        filename = f"{cc}_{sex.lower()}_{age}_{year}_CN_100m_R2025A_v1.tif"
    return (
        f"https://data.worldpop.org/GIS/AgeSex_structures/"
        f"Global_2015_2030/R2025A/{year}/{CC}/v1/100m/constrained/{filename}"
    )


def _describe(sex: str, age: str | None) -> str:
    """Human-readable description for a sex/age combination."""
    sex_label = "male" if sex.upper() == "M" else "female"
    if age is not None:
        return f"{sex_label} aged {AGE_LABELS[age]}"
    return f"total {sex_label}"


def _prefix(country_code: str, sex: str, age: str | None) -> str:
    """File prefix for a country/sex/age combination."""
    cc = country_code.lower()
    sex_label = "male" if sex.upper() == "M" else "female"
    if age is not None:
        return f"pop_{cc}_{sex_label}_{age}"
    return f"pop_{cc}_{sex_label}"


# ---------------------------------------------------------------------------
# Parse command-line arguments
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(
    description="Download WorldPop age-sex disaggregated population data",
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog="Sex codes: M (male), F (female)\nAge groups: " + ", ".join(AGE_GROUPS),
)
parser.add_argument("--country-code", required=True, help="ISO3 country code (e.g. SLE)")
parser.add_argument(
    "--sex",
    choices=["M", "F", "m", "f"],
    help="Sex: M (male) or F (female). Omit to download all sex/age groups.",
)
parser.add_argument(
    "--age",
    choices=AGE_GROUPS,
    help="Age group code (e.g. 00, 01, 05, 10, ..., 90). Omit for total male/female.",
)
org_group = parser.add_mutually_exclusive_group()
org_group.add_argument("--org-unit", help="DHIS2 org unit UID — compute zonal population for this org unit")
org_group.add_argument("--org-unit-level", type=int, help="Compute zonal population for all org units at this level")
parser.add_argument("--start", default="2020", help="Start year (default: 2020)")
parser.add_argument("--end", default="2020", help="End year (default: 2020)")
parser.add_argument("--dirname", default="worldpop_data", help="Output directory (default: worldpop_data)")
parser.add_argument("--list-groups", action="store_true", help="List available age groups and exit")
args = parser.parse_args()

# -- List mode --
if args.list_groups:
    print("Available WorldPop age-sex datasets:")
    print()
    print("  Total (all ages):")
    print("    --sex M              Total male population")
    print("    --sex F              Total female population")
    print()
    print("  By age group (use with --sex M or --sex F):")
    for code, label in AGE_LABELS.items():
        print(f"    --sex M --age {code}    Male {label}")
    print()
    print(f"  Total: 2 summary + {len(AGE_GROUPS)} age groups x 2 sexes = {2 + len(AGE_GROUPS) * 2} rasters per year")
    raise SystemExit(0)

# -- Build list of (sex, age) combinations to download --
if args.sex:
    if args.age is not None:
        downloads = [(args.sex, args.age)]
    else:
        downloads = [(args.sex, None)]
else:
    # Default: download all sex/age combinations
    downloads = ALL_DOWNLOADS

# -- Optionally fetch org unit geometry for zonal stats --
org_units: gpd.GeoDataFrame | None = None
if args.org_unit or args.org_unit_level:
    client = make_client()
    if args.org_unit:
        ou_meta = client.get(f"/api/organisationUnits/{args.org_unit}", params={"fields": "id,level"})
        level = ou_meta["level"]
        geojson = client.get_org_units_geojson(level=level)
        _gdf = gpd.read_file(json.dumps(geojson))
        _gdf = _gdf[_gdf["id"] == args.org_unit]
    else:
        geojson = client.get_org_units_geojson(level=args.org_unit_level)
        _gdf = gpd.read_file(json.dumps(geojson))
    org_units = gpd.GeoDataFrame(_gdf[_gdf.geometry.notna()])
    if org_units.empty:
        print("ERROR: no org units found or none have geometry")
        raise SystemExit(1)
    print(f"Found {len(org_units)} org unit(s)")
    for _, ou in org_units.iterrows():
        print(f"  {ou['id']}  {ou['name']}")

# -- Download each combination --
_original_url = yearly.url_country_for_year

for sex, age in downloads:
    desc = _describe(sex, age)
    pfx = _prefix(args.country_code, sex, age)

    def _patched_url(y: str, cc: str, v: str, s: str = sex, a: str | None = age) -> str:
        return _agesex_url(y, cc, v, s, a)

    yearly.url_country_for_year = _patched_url  # type: ignore[assignment, no-redef]

    print(f"\nDownloading WorldPop {desc} for {args.country_code}...")
    files = yearly.download(
        start=args.start,
        end=args.end,
        country_code=args.country_code,
        dirname=args.dirname,
        prefix=pfx,
    )

    data = xr.open_mfdataset(
        files,
        combine="nested",
        concat_dim="time",
        compat="override",
        coords="minimal",  # type: ignore[arg-type]  # pyright: ignore[reportArgumentType]
        data_vars="minimal",
    )

    if org_units is not None:
        # Compute zonal population sum per org unit
        var_name = list(data.data_vars)[0]
        da = data[var_name]
        ds_zonal = transforms.spatial.reduce(da, org_units, mask_dim="id", how="sum", lat_key="y", lon_key="x")  # pyright: ignore[reportArgumentType]
        zonal_df = ds_zonal.to_dataframe().reset_index()
        zonal_df = zonal_df.dropna(subset=[var_name])
        id_to_name = dict(zip(org_units["id"], org_units["name"], strict=True))
        for _, row in zonal_df.iterrows():
            name = id_to_name.get(row["id"], row["id"])
            print(f"  {name}: {desc} = {int(row[var_name]):,}")
    else:
        print(f"  {desc}:")
        print(f"    Variables: {list(data.data_vars)}")
        print(f"    Dimensions: {dict(data.sizes)}")

yearly.url_country_for_year = _original_url
print("\nDone!")
