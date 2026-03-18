"""Create a complete DHIS2 metadata setup: categories, data elements, and data set.

This example builds a realistic metadata structure from scratch:
  - Category options: Male, Female
  - Category: Sex (groups the options)
  - Category combo: Sex (assigns disaggregation to data elements)
  - Data elements: two health indicators disaggregated by sex
  - Data set: groups the data elements, assigns to level-2 org units, monthly

All objects use fixed UIDs so the script is idempotent — running it multiple
times updates existing objects rather than creating duplicates.

After running this script, the data set will appear in the DHIS2 Data Entry
app and be ready for data capture (the sharing settings grant public read/write).

Usage:
  uv run python examples/dhis2/14_create_metadata.py
"""

import json

import geopandas as gpd

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
    Sharing,
)

client = make_client()

# ---------------------------------------------------------------------------
# Step 1: Define category options, category, and category combo
# ---------------------------------------------------------------------------
# Category options are the individual choices (Male, Female).
# A category groups them (Sex).
# A category combo links the category to data elements so values can be
# disaggregated — each data value will have a "category option combo" like
# "Male" or "Female" in addition to the data element, org unit, and period.

print("--- Step 1: Defining categories ---")

co_male = CategoryOption(id="Uu8qJIFnph3", name="DEMO: Male", shortName="DEMO: Male")
co_female = CategoryOption(id="Vv9rKJGopq4", name="DEMO: Female", shortName="DEMO: Female")

cat_sex = Category(
    id="Ww0sLKHrqr5",
    name="DEMO: Sex",
    shortName="DEMO: Sex",
    dataDimensionType="DISAGGREGATION",
    categoryOptions=[IdRef(id=co_male.id), IdRef(id=co_female.id)],
)

cc_sex = CategoryCombo(
    id="Xx1tMLIsrs6",
    name="DEMO: Sex",
    dataDimensionType="DISAGGREGATION",
    categories=[IdRef(id=cat_sex.id)],
)

print(f"  Category combo: {cc_sex.name}")
print(f"    Category: {cat_sex.name}")
print(f"    Options: {co_male.name}, {co_female.name}")

# ---------------------------------------------------------------------------
# Step 2: Define data elements
# ---------------------------------------------------------------------------
# Each data element is linked to the sex category combo, meaning values
# must be reported separately for Male and Female.

print("\n--- Step 2: Defining data elements ---")

de_outpatient = DataElement(
    id="Yy2uNMJtst7",
    name="DEMO: Outpatient visits",
    shortName="DEMO: Outpatient visits",
    valueType="INTEGER",
    aggregationType="SUM",
    categoryCombo=IdRef(id=cc_sex.id),
)

de_malaria = DataElement(
    id="Zz3vONKutu8",
    name="DEMO: Malaria cases confirmed",
    shortName="DEMO: Malaria confirmed",
    valueType="INTEGER",
    aggregationType="SUM",
    categoryCombo=IdRef(id=cc_sex.id),
)

for de in [de_outpatient, de_malaria]:
    print(f"  {de.name} (disaggregated by {cc_sex.name})")

# ---------------------------------------------------------------------------
# Step 3: Fetch org units to assign to the data set
# ---------------------------------------------------------------------------
# Data sets must be assigned to org units — this controls which facilities
# or districts can report data for this data set.

print("\n--- Step 3: Fetching level-2 org units ---")

geojson = client.get_org_units_geojson(level=2)
org_units = gpd.read_file(json.dumps(geojson))
org_units: gpd.GeoDataFrame = org_units[org_units.geometry.notna()]  # type: ignore[assignment, no-redef]

print(f"  Found {len(org_units)} org unit(s)")
for _, ou in org_units.iterrows():
    print(f"    {ou['id']}  {ou['name']}")

# ---------------------------------------------------------------------------
# Step 4: Define the data set
# ---------------------------------------------------------------------------
# The data set groups our data elements and assigns them to org units.
# - periodType: Monthly means data is reported once per month
# - sharing: public rwrw---- means anyone can view and enter data

print("\n--- Step 4: Defining data set ---")

ds = DataSet(
    id="Aa4wPOLvuv9",
    name="DEMO: Health Facility Monthly Report",
    shortName="DEMO: HF Monthly",
    periodType=PeriodType.MONTHLY,
    dataSetElements=[
        DataSetElement(dataElement=de_outpatient),
        DataSetElement(dataElement=de_malaria),
    ],
    organisationUnits=[IdRef(id=uid) for uid in org_units["id"]],  # pyright: ignore[reportIndexIssue]
    sharing=Sharing(public="rwrw----"),
)

print(f"  {ds.name}")
print(f"    Period type: {ds.periodType}")
print(f"    Data elements: {len(ds.dataSetElements)}")
print(f"    Org units: {len(ds.organisationUnits)}")

# ---------------------------------------------------------------------------
# Step 5: Push metadata to DHIS2
# ---------------------------------------------------------------------------
# The /api/metadata endpoint with default MERGE strategy is idempotent:
# it creates objects if they don't exist, or updates them if they do.
# Order matters: category options before categories, categories before
# category combos, etc. The MetadataPayload handles this ordering.

print("\n--- Step 5: Pushing metadata to DHIS2 ---")

metadata = MetadataPayload(
    categoryOptions=[co_male, co_female],
    categories=[cat_sex],
    categoryCombos=[cc_sex],
    dataElements=[de_outpatient, de_malaria],
    dataSets=[ds],
)

result = client.post("/api/metadata", json=metadata.model_dump(exclude_none=True))
stats = result.get("stats", {})
print(f"  Created: {stats.get('created', 0)}")
print(f"  Updated: {stats.get('updated', 0)}")
print(f"  Ignored: {stats.get('ignored', 0)}")

# Trigger DHIS2 to generate categoryOptionCombos for any new category combos.
# Without this, the combos exist but have no option combos, and data entry fails.
print("  Generating categoryOptionCombos...")
client.post("/api/maintenance/categoryOptionComboUpdate", json={})

if stats.get("ignored", 0) > 0:
    # Print any error reports for debugging
    for report in result.get("typeReports", []):
        for obj_report in report.get("objectReports", []):
            for err in obj_report.get("errorReports", []):
                print(f"  ERROR: {err.get('message', '')}")

print("\nDone! The data set is now available in DHIS2 Data Entry.")
print(f"  Data set: {ds.name} ({ds.id})")
print("  Open Data Entry in DHIS2 and select this data set to enter values.")
