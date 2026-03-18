"""End-to-end pipeline: WorldPop sex-disaggregated population into DHIS2.

This script downloads WorldPop *male* and *female* population rasters and
imports them into DHIS2 with a Sex category dimension, so that DHIS2 stores
separate values for male and female population per org unit and year.

WorldPop provides age-sex structure rasters under the AgeSex_structures
collection. This script uses the "total male" (T_M) and "total female" (T_F)
rasters from the R2025A release (2015–2030, 100m resolution).

Since the dhis2eo library only knows about total population URLs, we
monkey-patch the URL function to redirect downloads to the sex-specific
rasters while reusing all of dhis2eo's download/cache/netcdf logic.

DHIS2 metadata created:
  - 2 category options: DEMO: Male, DEMO: Female
  - 1 category: DEMO: Sex (contains above options)
  - 1 category combo: DEMO: Sex (uses above category)
  - 1 data element: DEMO: WorldPop population by sex (assigned to cat combo)
  - 1 data set: DEMO: Population by Sex

Usage:
  # Single org unit (Bo district)
  uv run python examples/dhis2eo/pipeline_worldpop_sex.py --org-unit O6uvpzGd5pu --country-code SLE

  # All districts (level 2) in Sierra Leone
  uv run python examples/dhis2eo/pipeline_worldpop_sex.py --org-unit-level 2 --country-code SLE

  # Multiple years
  uv run python examples/dhis2eo/pipeline_worldpop_sex.py --org-unit-level 2 --country-code SLE \
      --start 2020 --end 2022
"""

import argparse
import json
import sys

import geopandas as gpd
import xarray as xr
from dhis2eo.data.worldpop.pop_total import yearly
from earthkit import transforms

from climate_tools.config import make_client
from climate_tools.schemas import (
    Category,
    CategoryCombo,
    CategoryOption,
    DataElement,
    DataSet,
    DataSetElement,
    IdRef,
    MetadataPayload,
    PeriodType,
)

# ---------------------------------------------------------------------------
# Stable UIDs for DHIS2 metadata.
# Fixed UIDs make this script idempotent — safe to run repeatedly.
# ---------------------------------------------------------------------------
CO_MALE = "Uu8qJIFnph3"  # Category option: DEMO: Male
CO_FEMALE = "Vv9rKJGopq4"  # Category option: DEMO: Female
CAT_SEX = "Ww0sLKHrqr5"  # Category: DEMO: Sex
CC_SEX = "Xx1tMLIsrs6"  # Category combo: DEMO: Sex
DE_POP_SEX = "vX2eW8rJ5kC"  # Data element: DEMO: WorldPop population by sex
DS_POP_SEX = "tN3fY7uG4hD"  # Data set: DEMO: Population by Sex

# ---------------------------------------------------------------------------
# Monkey-patch helper for WorldPop sex-disaggregated URLs
# ---------------------------------------------------------------------------


def _sex_url(year: str, country_code: str, _version: str, sex: str) -> str:
    """Build a WorldPop AgeSex URL for total male (T_M) or total female (T_F)."""
    cc = country_code.lower()
    CC = country_code.upper()
    filename = f"{cc}_T_{sex}_{year}_CN_100m_R2025A_v1.tif"
    return (
        f"https://data.worldpop.org/GIS/AgeSex_structures/"
        f"Global_2015_2030/R2025A/{year}/{CC}/v1/100m/constrained/{filename}"
    )


# ---------------------------------------------------------------------------
# Parse command-line arguments
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(
    description="WorldPop sex-disaggregated pipeline: download male/female population, aggregate, push to DHIS2",
)
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("--org-unit", help="Single DHIS2 org unit UID (e.g. O6uvpzGd5pu)")
group.add_argument("--org-unit-level", type=int, help="Process all org units at this level (e.g. 2 for districts)")
parser.add_argument("--country-code", required=True, help="ISO3 country code (e.g. SLE for Sierra Leone)")
parser.add_argument("--start", default="2020", help="Start year (default: 2020)")
parser.add_argument("--end", default="2020", help="End year (default: 2020)")
parser.add_argument("--dirname", default="worldpop_data", help="Download directory (default: worldpop_data)")
args = parser.parse_args()

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
# We create category options, category, category combo, data element, and
# data set. The /api/metadata endpoint with default MERGE strategy
# creates-or-updates.

print("\n--- Step 2: Creating DHIS2 metadata ---")

co_male = CategoryOption(id=CO_MALE, name="DEMO: Male", shortName="DEMO: Male")
co_female = CategoryOption(id=CO_FEMALE, name="DEMO: Female", shortName="DEMO: Female")

cat_sex = Category(
    id=CAT_SEX,
    name="DEMO: Sex",
    shortName="DEMO: Sex",
    categoryOptions=[IdRef(id=CO_MALE), IdRef(id=CO_FEMALE)],
)

cc_sex = CategoryCombo(
    id=CC_SEX,
    name="DEMO: Sex",
    categories=[IdRef(id=CAT_SEX)],
)

de_pop_sex = DataElement(
    id=DE_POP_SEX,
    name="DEMO: WorldPop population by sex",
    shortName="DEMO: WorldPop pop sex",
    valueType="INTEGER",
    categoryCombo=IdRef(id=CC_SEX),
)

metadata = MetadataPayload(
    categoryOptions=[co_male, co_female],
    categories=[cat_sex],
    categoryCombos=[cc_sex],
    dataElements=[de_pop_sex],
    dataSets=[
        DataSet(
            id=DS_POP_SEX,
            name="DEMO: Population by Sex",
            shortName="DEMO: Pop by Sex",
            periodType=PeriodType.YEARLY,
            dataSetElements=[DataSetElement(dataElement=de_pop_sex)],
            organisationUnits=[IdRef(id=uid) for uid in org_units["id"]],  # pyright: ignore[reportIndexIssue]
        ),
    ],
)

result = client.post("/api/metadata", json=metadata.model_dump(exclude_none=True))
stats = result.get("stats", {})
print(f"  Metadata import: created={stats.get('created', 0)}, updated={stats.get('updated', 0)}")

# ---------------------------------------------------------------------------
# Step 2b: Resolve auto-generated categoryOptionCombos
# ---------------------------------------------------------------------------
# After syncing the category combo, DHIS2 auto-generates categoryOptionCombos
# (one per combination of options). We need their UIDs to tag data values.

print("  Generating categoryOptionCombos...")
client.post("/api/maintenance/categoryOptionComboUpdate", json={})

print("  Resolving categoryOptionCombo UIDs...")

cc_response = client.get(
    f"/api/categoryCombos/{CC_SEX}",
    params={"fields": "categoryOptionCombos[id,categoryOptions[id,name]]"},
)

coc_lookup: dict[str, str] = {}  # category option ID → categoryOptionCombo ID
for coc in cc_response.get("categoryOptionCombos", []):
    opts = coc.get("categoryOptions", [])
    if len(opts) == 1:
        coc_lookup[opts[0]["id"]] = coc["id"]

coc_male = coc_lookup.get(CO_MALE)
coc_female = coc_lookup.get(CO_FEMALE)

if not coc_male or not coc_female:
    print(f"  ERROR: Could not resolve COC UIDs. Got: {coc_lookup}")
    sys.exit(1)

print(f"  Male COC:   {coc_male}")
print(f"  Female COC: {coc_female}")

# ---------------------------------------------------------------------------
# Step 3: Download WorldPop data (monkey-patched for male & female)
# ---------------------------------------------------------------------------
print("\n--- Step 3: Downloading WorldPop sex-disaggregated data ---")

_original_url = yearly.url_country_for_year

# Download male rasters
yearly.url_country_for_year = lambda y, cc, v: _sex_url(y, cc, v, "M")
male_files = yearly.download(
    start=args.start,
    end=args.end,
    country_code=args.country_code,
    dirname=args.dirname,
    prefix=f"pop_{args.country_code.lower()}_male",
)
print(f"  Downloaded {len(male_files)} male file(s)")

# Download female rasters
yearly.url_country_for_year = lambda y, cc, v: _sex_url(y, cc, v, "F")
female_files = yearly.download(
    start=args.start,
    end=args.end,
    country_code=args.country_code,
    dirname=args.dirname,
    prefix=f"pop_{args.country_code.lower()}_female",
)
print(f"  Downloaded {len(female_files)} female file(s)")

# Restore original URL function
yearly.url_country_for_year = _original_url

# ---------------------------------------------------------------------------
# Step 4: Compute polygon-based zonal statistics for male & female
# ---------------------------------------------------------------------------
print("\n--- Step 4: Computing zonal statistics per org unit ---")

all_data_values: list[dict[str, str]] = []
id_to_name = dict(zip(org_units["id"], org_units["name"], strict=True))

for sex_label, files, coc_id, var_name in [
    ("Male", male_files, coc_male, "pop_total"),
    ("Female", female_files, coc_female, "pop_total"),
]:
    ds = xr.open_mfdataset(
        files,
        combine="nested",
        concat_dim="time",
        compat="override",
        coords="minimal",  # type: ignore[arg-type]  # pyright: ignore[reportArgumentType]
        data_vars="minimal",
    )

    ds_org_units = transforms.spatial.reduce(
        ds[var_name],
        org_units,  # pyright: ignore[reportArgumentType]
        mask_dim="id",
        how="sum",
        lat_key="y",
        lon_key="x",
    )

    df = ds_org_units.to_dataframe().reset_index()
    df["time"] = df["time"].dt.year.astype(str)
    df["value"] = df[var_name].astype(int)
    df = df.dropna(subset=[var_name])

    print(f"\n  {sex_label}: {len(df)} value(s) across {len(org_units)} org unit(s)")
    for ou_id, ou_df in df.groupby("id", sort=False):
        name = id_to_name.get(ou_id, ou_id)
        print(f"    {name} ({ou_id})")
        for _, row in ou_df.iterrows():
            print(f"      {row['time']}: {int(row['value']):,}")

    # Build data values with the correct categoryOptionCombo
    for _, row in df.iterrows():
        all_data_values.append(
            {
                "dataElement": DE_POP_SEX,
                "period": str(row["time"]),
                "orgUnit": str(row["id"]),
                "categoryOptionCombo": coc_id,
                "value": str(int(row["value"])),
            }
        )

# ---------------------------------------------------------------------------
# Step 5: Push data into DHIS2
# ---------------------------------------------------------------------------
print("\n--- Step 5: Pushing data to DHIS2 ---")

if not all_data_values:
    print("  No data to push.")
else:
    payload = {"dataValues": all_data_values}
    print(f"  Sending {len(all_data_values)} data value(s)...")

    result = client.post_data_value_set(payload)
    imported = result.get("response", {}).get("importCount", {})
    print(f"  Imported: {imported.get('imported', 0)}, Updated: {imported.get('updated', 0)}")

print("\nDone! Sex-disaggregated population data is now available in DHIS2.")
