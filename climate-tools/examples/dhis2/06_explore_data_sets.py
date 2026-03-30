"""List data sets and inspect their structure."""

from climate_tools.config import make_client

client = make_client()

# List first 10 data sets
data_sets = client.get(
    "/api/dataSets.json",
    params={"fields": "id,displayName,periodType,dataSetElements[dataElement[id,displayName]]", "pageSize": 10},
)

print(f"Data sets (showing first 10 of {data_sets['pager']['total']}):\n")
for ds in data_sets["dataSets"]:
    n_elements = len(ds.get("dataSetElements", []))
    print(f"  {ds['id']} - {ds['displayName']}")
    print(f"    Period type: {ds['periodType']}, Data elements: {n_elements}")

    # Show first 3 data elements
    for dse in ds.get("dataSetElements", [])[:3]:
        de = dse["dataElement"]
        print(f"      - {de['id']} {de['displayName']}")
    if n_elements > 3:
        print(f"      ... and {n_elements - 3} more")
    print()
