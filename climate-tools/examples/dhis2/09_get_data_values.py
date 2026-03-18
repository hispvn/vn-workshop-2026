"""Fetch a set of data values from DHIS2 and display as a table.

While the Analytics API returns pre-aggregated data, the dataValueSets API
returns raw data values as they were submitted — useful for verifying imports,
debugging, and exporting raw data.

This script fetches data values for a data element across all level-2 org
units for a given period and prints them in a readable table.

Usage:
  uv run python examples/dhis2/09_get_data_values.py
"""

from climate_tools.config import make_client

client = make_client()

# Fetch raw data values for "ANC 1st visit" across all districts, Jan 2024
params = {
    "dataSet": "Nyh6laLdBEJ",  # ANC data set (contains fbfJHSPpUQD)
    "orgUnit": "O6uvpzGd5pu",  # Bo district
    "period": "202401",
    "fields": "dataElement,orgUnit,period,value,lastUpdated",
}

print("Fetching data values for Bo district, January 2024...")
print("  Data set: Nyh6laLdBEJ (ANC)")
print("  Org unit: O6uvpzGd5pu (Bo)")
print("  Period:   202401\n")

response = client.get_data_value_set(params)
values = response.get("dataValues", [])

print(f"Found {len(values)} data value(s):\n")

# Build org unit name lookup
ou_names: dict[str, str] = {}

# Print as a simple table
print(f"  {'Data Element':<15} {'Period':<10} {'Value':>10}  {'Last Updated'}")
print(f"  {'-' * 15} {'-' * 10} {'-' * 10}  {'-' * 20}")
for dv in values[:20]:
    print(f"  {dv['dataElement']:<15} {dv['period']:<10} {dv['value']:>10}  {dv.get('lastUpdated', '')[:19]}")

if len(values) > 20:
    print(f"\n  ... and {len(values) - 20} more")
