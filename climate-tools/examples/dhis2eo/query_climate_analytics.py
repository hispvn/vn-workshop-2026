"""Query DHIS2 analytics for the climate data pushed by the pipeline scripts.

After running the pipeline scripts (pipeline_chirps.py, pipeline_era5.py,
pipeline_worldpop.py), the data is stored in DHIS2 as aggregate data values.
This script shows how to query that data back using the DHIS2 Analytics API.

The Analytics API is DHIS2's main reporting engine. It aggregates data values
across dimensions like data elements (dx), organisation units (ou), and
periods (pe). This is how dashboards, charts, and reports get their data.

Target org units:
  Use --org-unit for a single org unit, or --org-unit-level for all at a level
  (e.g. level 2 = all 13 districts in Sierra Leone).

Usage:
  # Single org unit
  uv run python examples/dhis2eo/query_climate_analytics.py --org-unit O6uvpzGd5pu

  # All districts
  uv run python examples/dhis2eo/query_climate_analytics.py --org-unit-level 2

  # Specific periods
  uv run python examples/dhis2eo/query_climate_analytics.py --org-unit-level 2 --periods 202401 202501
"""

import argparse

from climate_tools.config import make_client

# ---------------------------------------------------------------------------
# These UIDs must match the ones used in the pipeline scripts.
# ---------------------------------------------------------------------------
DE_CHIRPS_PRECIP = "cWsMKdoG1Hk"  # DEMO: CHIRPS daily precipitation (mm/day)
DE_ERA5_PRECIP = "fYr3iz0kVbA"  # DEMO: ERA5 daily total precipitation (mm)
DE_ERA5_TEMP = "gN2hQGaRpM7"  # DEMO: ERA5 daily mean 2m temperature (°C)
DE_WORLDPOP_POP = "hTgzX3mFrS9"  # DEMO: WorldPop estimated population

# ---------------------------------------------------------------------------
# Parse command-line arguments
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(description="Query climate analytics from DHIS2")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("--org-unit", help="Single DHIS2 org unit UID (e.g. O6uvpzGd5pu)")
group.add_argument("--org-unit-level", type=int, help="Query all org units at this level (e.g. 2 for districts)")
parser.add_argument(
    "--periods",
    nargs="+",
    default=["LAST_12_MONTHS"],
    help="Period(s) to query (default: LAST_12_MONTHS). Examples: 202401, 2024, LAST_4_QUARTERS",
)
args = parser.parse_args()

# ---------------------------------------------------------------------------
# Connect to DHIS2
# ---------------------------------------------------------------------------
# Credentials are loaded from .env (DHIS2_BASE_URL, DHIS2_USERNAME, DHIS2_PASSWORD).
client = make_client()
print(f"Connected to {client.base_url}")

# ---------------------------------------------------------------------------
# Build the org unit dimension string
# ---------------------------------------------------------------------------
# The analytics API accepts org units as:
#   ou:<uid>           — a single org unit
#   ou:LEVEL-2         — all org units at level 2
#   ou:<uid1>;<uid2>   — multiple specific org units
if args.org_unit:
    ou_dimension = args.org_unit
else:
    ou_dimension = f"LEVEL-{args.org_unit_level}"

# ---------------------------------------------------------------------------
# Query 1: Daily climate data (CHIRPS + ERA5)
# ---------------------------------------------------------------------------
# The analytics API uses a "dimension" parameter with the format:
#   dx:<dataElement1>;<dataElement2>  — what data to fetch
#   ou:<orgUnit> or ou:LEVEL-N        — where (which org units)
#   pe:<period1>;<period2>            — when (which time periods)
#
# We query all three daily climate data elements.

print("\n--- Daily climate data (CHIRPS + ERA5) ---")

climate_des = f"{DE_CHIRPS_PRECIP};{DE_ERA5_PRECIP};{DE_ERA5_TEMP}"
periods = ";".join(args.periods)

result = client.get(
    "/api/analytics.json",
    params={
        "dimension": f"dx:{climate_des},ou:{ou_dimension},pe:{periods}",
    },
)

# The response contains:
#   - headers: column definitions (dataElement, orgUnit, period, value)
#   - rows: data values as arrays matching the header order
#   - metaData.items: lookup table for UIDs → human-readable names
rows = result.get("rows", [])
meta = result.get("metaData", {}).get("items", {})

if rows:
    print(f"  {len(rows)} row(s) returned\n")
    for row in rows:
        de_id, ou_id, period, value = row[0], row[1], row[2], row[3]
        de_name = meta.get(de_id, {}).get("name", de_id)
        ou_name = meta.get(ou_id, {}).get("name", ou_id)
        print(f"  {ou_name:20s}  {period}  {de_name}: {value}")
else:
    print("  No data found. Have you run the pipeline scripts first?")
    print("  Note: DHIS2 analytics tables may need to be rebuilt after importing new data.")

# ---------------------------------------------------------------------------
# Query 2: Yearly population data (WorldPop)
# ---------------------------------------------------------------------------
print("\n--- Yearly population data (WorldPop) ---")

result = client.get(
    "/api/analytics.json",
    params={
        "dimension": f"dx:{DE_WORLDPOP_POP},ou:{ou_dimension},pe:LAST_5_YEARS",
    },
)

rows = result.get("rows", [])
meta = result.get("metaData", {}).get("items", {})

if rows:
    print(f"  {len(rows)} row(s) returned\n")
    for row in rows:
        de_id, ou_id, period, value = row[0], row[1], row[2], row[3]
        de_name = meta.get(de_id, {}).get("name", de_id)
        ou_name = meta.get(ou_id, {}).get("name", ou_id)
        print(f"  {ou_name:20s}  {period}  {de_name}: {value}")
else:
    print("  No data found. Have you run pipeline_worldpop.py first?")

print("\nDone!")
