# DHIS2 Python Client

The [`dhis2-python-client`](https://github.com/dhis2/dhis2-python-client) library provides a typed Python interface to the DHIS2 Web API. Instead of constructing HTTP requests manually, you work with Python objects and methods that handle authentication, pagination, and JSON parsing.

This guide walks through the core concepts with self-contained code examples. Each section builds on the previous one.

## Connecting to DHIS2

Every interaction starts with a `DHIS2Client` instance. You need three things: the server URL, a username, and a password.

```python
from dhis2_client import DHIS2Client

client = DHIS2Client(
    base_url="https://play.im.dhis2.org/dev/",
    username="admin",
    password="district",
)
```

In this workshop, we use a helper function that reads these values from a `.env` file so you don't have to repeat them:

```python
from climate_tools.config import make_client

client = make_client()
```

!!! tip "The play server"
    The DHIS2 play server (`play.im.dhis2.org/dev`) is a public demo instance running Sierra Leone sample data. It resets nightly, so any data you push will disappear the next day. This makes it safe to experiment with.

### System info

Once connected, verify the connection by requesting system information:

```python
info = client.get_system_info()
print(f"Connected to: {info['systemName']}")
print(f"Version:      {info['version']}")
print(f"Revision:     {info['revision']}")
print(f"Server date:  {info['serverDate']}")
```

This calls the `/api/system/info` endpoint and returns a dictionary with server metadata.

## Users

### Current user

The `get_current_user()` method returns the authenticated user's profile. The `fields` parameter controls which properties are included in the response — this is a core DHIS2 API concept that applies to almost every endpoint.

```python
me = client.get_current_user(fields="id,username,firstName,surname")
print(f"Logged in as: {me['firstName']} {me['surname']} ({me['username']})")
```

### Listing users

For endpoints without a dedicated method, use the generic `client.get()` which maps directly to an HTTP GET request. The response is the parsed JSON body:

```python
users = client.get(
    "/api/users.json",
    params={"fields": "id,displayName", "pageSize": 10},
)

print(f"First 10 users (of {users['pager']['total']}):")
for user in users["users"]:
    print(f"  {user['id']} - {user['displayName']}")
```

The `pager` key in the response tells you the total count and pagination info — DHIS2 paginates all list endpoints by default.

## Organisation Units

Organisation units are the geographic and administrative structure in DHIS2. They form a hierarchy — for Sierra Leone, level 1 is the country, level 2 is districts, level 3 is chiefdoms, and so on.

The client has a dedicated `get_organisation_units()` method that handles pagination automatically and yields results as a generator:

```python
from itertools import islice

# Count all org units
ous = list(client.get_organisation_units())
print(f"Total organisation units: {len(ous)}")

# Level 2 = districts
print("\nDistricts (level 2):")
for ou in islice(
    client.get_organisation_units(level=2, fields="id,name", order="name:asc"),
    10,
):
    print(f"  {ou['id']} - {ou['name']}")

# Level 3 = chiefdoms
print("\nChiefdoms (level 3, first 10):")
for ou in islice(
    client.get_organisation_units(level=3, fields="id,name", order="name:asc"),
    10,
):
    print(f"  {ou['id']} - {ou['name']}")
```

### Filtering

DHIS2 supports server-side filtering on most list endpoints. Filters use the syntax `property:operator:value`:

```python
# Org units whose name contains "Bo"
for ou in client.get_organisation_units(
    fields="id,name,level",
    filter=["name:ilike:Bo"],
):
    print(f"  {ou['id']} - {ou['name']} (level {ou['level']})")
```

Common operators: `eq` (equals), `ilike` (case-insensitive contains), `gt`/`lt` (greater/less than), `in` (value in list).

### GeoJSON and plotting

Org units with geometry can be fetched as GeoJSON — useful for mapping and spatial analysis:

```python
import io
import json

import geopandas as gpd
import matplotlib.pyplot as plt

# Fetch GeoJSON for all level-3 org units
geojson = client.get("/api/organisationUnits.geojson", params={"level": 3})

# Load into a GeoDataFrame
gdf = gpd.read_file(io.StringIO(json.dumps(geojson)))
print(gdf[["name", "level", "geometry"]].head(10))

# Plot the boundaries
gdf.plot(figsize=(8, 8))
plt.axis("equal")
plt.title("Organisation Units (Level 3)")
plt.tight_layout()
plt.show()
```

!!! warning "GeoJSON endpoint limitations"
    The `/api/organisationUnits.geojson` endpoint only supports filtering by `level` — it does not support the `filter` parameter used by other DHIS2 endpoints (e.g. `filter=id:eq:O6uvpzGd5pu`). To get GeoJSON for a single org unit, you need to fetch all org units at that level and filter client-side. The pipeline scripts handle this automatically, but it downloads more data than necessary.

### Single org unit geometry

For a single org unit, request the `geometry` field directly and use `shapely` to work with it:

```python
from shapely.geometry import shape

ou = client.get(
    f"/api/organisationUnits/O6uvpzGd5pu",
    params={"fields": "id,name,geometry"},
)
geometry = shape(ou["geometry"])
bbox = geometry.bounds  # (west, south, east, north)
print(f"{ou['name']}: bbox = {bbox}")
```

The earth observation pipeline scripts use the GeoDataFrame approach instead (fetching via `get_org_units_geojson()` and using `org_units.total_bounds`) — see the [Earth Observation guide](dhis2eo.md).

## Data Elements

Data elements are the building blocks of data collection in DHIS2. Each one represents a single piece of information to be collected — for example "ANC 1st visit" or "Malaria cases confirmed".

The client provides `get_data_elements()` with the same generator pattern as org units:

```python
# Search for data elements containing "malaria"
fields = "id,displayName,valueType,domainType"
des = list(client.get_data_elements(fields=fields, filter=["name:ilike:malaria"]))

print(f"Found {len(des)} data elements matching 'malaria':\n")
for de in des[:10]:
    print(f"  {de['id']} - {de['displayName']} ({de['valueType']}, {de['domainType']})")
```

Key properties:

- **`valueType`** — the data type: `NUMBER`, `INTEGER_POSITIVE`, `TEXT`, `BOOLEAN`, etc.
- **`domainType`** — either `AGGREGATE` (summary data) or `TRACKER` (individual-level data)

## Data Sets

Data sets group data elements together and define how often data is collected (the period type). Think of a data set as a "form" that health workers fill in at a facility.

```python
data_sets = client.get(
    "/api/dataSets.json",
    params={
        "fields": "id,displayName,periodType,dataSetElements[dataElement[id,displayName]]",
        "pageSize": 10,
    },
)

for ds in data_sets["dataSets"]:
    n_elements = len(ds.get("dataSetElements", []))
    print(f"{ds['displayName']}")
    print(f"  Period type: {ds['periodType']}, Data elements: {n_elements}")

    for dse in ds.get("dataSetElements", [])[:3]:
        de = dse["dataElement"]
        print(f"    - {de['displayName']}")
    if n_elements > 3:
        print(f"    ... and {n_elements - 3} more")
```

Common period types: `Monthly`, `Quarterly`, `Yearly`, `Weekly`.

## Analytics

The Analytics API is how you retrieve aggregated data from DHIS2. Unlike the raw data value endpoints, analytics returns pre-computed, cross-tabulated results across any combination of dimensions (data elements, org units, time periods).

```python
params = {
    "dimension": "dx:fbfJHSPpUQD,ou:LEVEL-2,pe:LAST_4_QUARTERS",
    "skipMeta": "true",
}

result = client.get("/api/analytics.json", params=params)

headers = result.get("headers", [])
rows = result.get("rows", [])

print(f"Analytics query returned {len(rows)} rows")
print(f"Columns: {[h['name'] for h in headers]}\n")

for row in rows[:10]:
    print(f"  {row}")
```

The `dimension` parameter uses DHIS2's dimension syntax:

- **`dx:`** — data dimension (data element UIDs)
- **`ou:`** — organisation unit dimension (`LEVEL-2` = all districts, or specific UIDs)
- **`pe:`** — period dimension (`LAST_4_QUARTERS`, `2024`, `202401`, etc.)

!!! note "Analytics tables"
    The Analytics API reads from pre-computed tables. After pushing new data, DHIS2 needs to rebuild its analytics tables before the data appears. On the play server this happens automatically; on a production server, an admin triggers it via **Maintenance > Analytics Tables**.

## Categories and Disaggregation

Categories let you disaggregate data — for example, reporting malaria cases separately for males and females, or by age group. The hierarchy is:

- **Category option** — a single choice (e.g. "Male", "Female")
- **Category** — groups options (e.g. "Sex" = Male + Female)
- **Category combo** — combines one or more categories (e.g. "Sex × Age group")

When a data element has a category combo, each data value must also specify a **category option combo** — the specific combination of options (e.g. "Male, 0-4 years").

### Exploring existing categories

```python
response = client.get(
    "/api/categoryCombos.json",
    params={
        "fields": "id,displayName,categories[id,displayName,categoryOptions[id,displayName]]",
        "pageSize": 10,
    },
)

for combo in response["categoryCombos"]:
    print(f"{combo['displayName']} ({combo['id']})")
    for cat in combo.get("categories", []):
        options = [o["displayName"] for o in cat.get("categoryOptions", [])]
        print(f"  {cat['displayName']}: {', '.join(options)}")
```

### The default category combo

Every data element has a category combo. If you don't assign one explicitly, DHIS2 uses the "default" combo, which has a single category ("default") with a single option ("default"). This means there's always exactly one category option combo per data value — even when there's no disaggregation.

The default category option combo UID is `HllvX50cXC0` on most DHIS2 instances. You'll need this when writing individual data values via `set_data_value()`.

## Data Values — Writing and Reading

Data values are the core of DHIS2 — each one represents a single measurement identified by: data element (what), org unit (where), period (when), and category option combo (disaggregation).

### Writing a single value

```python
client.set_data_value(
    de="fbfJHSPpUQD",   # data element UID
    pe="202401",          # period (January 2024)
    ou="O6uvpzGd5pu",    # org unit UID (Bo district)
    co="HllvX50cXC0",    # category option combo (default)
    value="42",
)
```

The `co` parameter is required — use `HllvX50cXC0` for the default (no disaggregation).

### Reading a single value

```python
result = client.get_data_value(
    de="fbfJHSPpUQD",
    pe="202401",
    ou="O6uvpzGd5pu",
)
print(result)
```

### Bulk import with data value sets

For importing many values at once (which is what the pipelines do), use `post_data_value_set()`:

```python
payload = {
    "dataValues": [
        {
            "dataElement": "fbfJHSPpUQD",
            "period": "202401",
            "orgUnit": "O6uvpzGd5pu",
            "value": "42",
        },
        {
            "dataElement": "fbfJHSPpUQD",
            "period": "202402",
            "orgUnit": "O6uvpzGd5pu",
            "value": "55",
        },
    ]
}

result = client.post_data_value_set(payload)
imported = result.get("response", {}).get("importCount", {})
print(f"Imported: {imported.get('imported', 0)}, Updated: {imported.get('updated', 0)}")
```

### Reading back a set of values

To fetch raw (non-aggregated) values for a data set, org unit, and period:

```python
params = {
    "dataSet": "Nyh6laLdBEJ",    # data set UID
    "orgUnit": "O6uvpzGd5pu",    # org unit
    "period": "202401",           # period
}

response = client.get_data_value_set(params)
for dv in response.get("dataValues", []):
    print(f"  {dv['dataElement']}  {dv['period']}  {dv['value']}")
```

!!! tip "Data values vs analytics"
    `get_data_value_set()` returns raw values as submitted. The Analytics API (`/api/analytics`) returns pre-aggregated data across dimensions. Use data value sets for debugging and verification; use analytics for reporting and analysis.

## Creating Metadata

The `/api/metadata` endpoint lets you create or update multiple DHIS2 objects in a single request. The default MERGE import strategy is idempotent — objects are created if they don't exist, or updated if they do (matched by UID).

### Using Pydantic schemas

The `climate_tools.schemas` module provides typed models for building metadata payloads:

```python
from climate_tools.schemas import (
    Category, CategoryCombo, CategoryOption,
    DataElement, DataSet, DataSetElement,
    IdRef, MetadataPayload, PeriodType, Sharing,
)

# 1. Category options
co_male = CategoryOption(id="Uu8qJIFnph3", name="DEMO: Male", shortName="DEMO: Male")
co_female = CategoryOption(id="Vv9rKJGopq4", name="DEMO: Female", shortName="DEMO: Female")

# 2. Category grouping the options
cat_sex = Category(
    id="Ww0sLKHrqr5",
    name="DEMO: Sex",
    categoryOptions=[IdRef(id=co_male.id), IdRef(id=co_female.id)],
)

# 3. Category combo
cc_sex = CategoryCombo(
    id="Xx1tMLIsrs6",
    name="DEMO: Sex",
    categories=[IdRef(id=cat_sex.id)],
)

# 4. Data element with disaggregation
de = DataElement(
    id="Yy2uNMJtst7",
    name="DEMO: Outpatient visits",
    shortName="DEMO: Outpatient visits",
    valueType="INTEGER",
    aggregationType="SUM",
    categoryCombo=IdRef(id=cc_sex.id),
)

# 5. Data set assigned to org units
ds = DataSet(
    id="Aa4wPOLvuv9",
    name="DEMO: Health Facility Monthly Report",
    shortName="DEMO: HF Monthly",
    periodType=PeriodType.MONTHLY,
    dataSetElements=[DataSetElement(dataElement=de)],
    organisationUnits=[IdRef(id="O6uvpzGd5pu")],
    sharing=Sharing(public="rwrw----"),
)

# 6. Push everything at once
metadata = MetadataPayload(
    categoryOptions=[co_male, co_female],
    categories=[cat_sex],
    categoryCombos=[cc_sex],
    dataElements=[de],
    dataSets=[ds],
)

result = client.post("/api/metadata", json=metadata.model_dump(exclude_none=True))
stats = result.get("stats", {})
print(f"Created: {stats.get('created', 0)}, Updated: {stats.get('updated', 0)}")
```

!!! warning "Order matters"
    Category options must be created before categories, categories before category combos, and data elements before data sets. The `MetadataPayload` fields are ordered correctly — as long as you populate them in the right order, DHIS2 will process them correctly.

### Stable UIDs for idempotent scripts

Use fixed UIDs (11-character alphanumeric strings) so that running the same script twice updates existing objects rather than creating duplicates. DHIS2 UIDs must start with a letter and be exactly 11 characters — you can generate them at [dhis2.org/uid](https://play.im.dhis2.org/dev/api/system/id) or use any 11-character alphanumeric string starting with a letter.

### Sharing and data capture

The `sharing` field on a data set controls who can view and enter data:

- `"rwrw----"` — public read/write for both metadata and data (anyone can enter data)
- `"rw------"` — public metadata read/write, no data access
- `"--------"` — no public access (must be granted explicitly)

For the data set to appear in the Data Entry app, the current user needs data write access and the data set must be assigned to the user's org unit scope.

## Organisation Unit Hierarchy

The org unit tree is central to DHIS2 — it determines where data can be entered and how it rolls up for reporting.

### Walking the tree

Fetch the tree structure using nested `children` fields:

```python
# Get root org unit
roots = list(client.get_organisation_units(level=1, fields="id,name"))
root = roots[0]

# Fetch 3 levels deep
tree = client.get(
    f"/api/organisationUnits/{root['id']}",
    params={
        "fields": "id,name,level,children[id,name,level,children[id,name,level]]",
    },
)

def print_tree(node, indent=0):
    n_children = len(node.get("children", []))
    suffix = f" ({n_children} children)" if n_children else ""
    print(f"{'  ' * indent}L{node.get('level', '?')}  {node['name']}{suffix}")
    for child in sorted(node.get("children", []), key=lambda c: c["name"]):
        print_tree(child, indent + 1)

print_tree(tree)
```

### Summary by level

```python
for level in range(1, 5):
    ous = list(client.get_organisation_units(level=level, fields="id"))
    if not ous:
        break
    print(f"Level {level}: {len(ous)} org unit(s)")
```

Typical hierarchy for Sierra Leone: Level 1 (1 country) → Level 2 (13 districts) → Level 3 (chiefdoms) → Level 4 (facilities).

## The generic HTTP methods

The client provides `get()`, `post()`, `put()`, `patch()`, and `delete()` methods that map directly to HTTP verbs. These give you access to any DHIS2 API endpoint:

```python
# GET — read data
response = client.get("/api/some/endpoint", params={"key": "value"})

# POST — create or bulk operations
result = client.post("/api/metadata", json=payload)

# PUT — full update
client.put(f"/api/dataElements/{uid}", json=updated_element)

# DELETE — remove
client.delete(f"/api/dataElements/{uid}")
```

The dedicated methods (`get_organisation_units()`, `get_data_elements()`, etc.) add convenience like automatic pagination, but the generic methods give you access to the full DHIS2 API.

### Pagination

DHIS2 paginates list endpoints by default (50 items per page). The dedicated methods handle this automatically. For generic `get()` calls, you can either:

- Set `pageSize` large enough: `params={"pageSize": 1000}`
- Use `client.fetch_all()` which collects all pages:

```python
all_items = client.fetch_all(
    "/api/dataElements.json",
    params={"fields": "id,name"},
    item_key="dataElements",
)
print(f"Total: {len(all_items)} data elements")
```

Or use `client.list_paged()` as a generator for memory-efficient iteration:

```python
for item in client.list_paged(
    "/api/dataElements.json",
    params={"fields": "id,name"},
    item_key="dataElements",
):
    print(item["name"])
```

## What's next

Now that you can read and write data, create metadata, and understand the DHIS2 data model, the [Earth Observation guide](dhis2eo.md) shows how to download climate and population data and push it back into DHIS2 using automated pipelines.
