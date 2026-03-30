"""Search and list data elements."""

from climate_tools.config import make_client
from climate_tools.schemas import DataElement

client = make_client()

# Search for data elements containing "malaria"
fields = "id,name,valueType,domainType"
des = [DataElement(**de) for de in client.get_data_elements(fields=fields, filter=["name:ilike:malaria"])]
print(f"Found {len(des)} data elements matching 'malaria':\n")
for de in des[:10]:
    print(f"  {de.id} - {de.name} ({de.valueType}, {de.domainType})")

if len(des) > 10:
    print(f"  ... and {len(des) - 10} more")
