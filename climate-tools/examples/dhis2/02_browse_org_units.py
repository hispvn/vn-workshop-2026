"""Browse organisation unit hierarchy."""

from itertools import islice

from climate_tools.config import make_client
from climate_tools.schemas import OrgUnit

client = make_client()

# Total count
ous = [OrgUnit(**ou) for ou in client.get_organisation_units(fields="id,name")]
print(f"Total organisation units: {len(ous)}")

# Level 2 org units
print("\nOrg units at level 2 (first 10):")
for ou in islice(
    (OrgUnit(**ou) for ou in client.get_organisation_units(level=2, fields="id,name", order="name:asc")),
    10,
):
    print(f"  {ou.id} - {ou.name}")

# Level 3 org units
print("\nOrg units at level 3 (first 10):")
for ou in islice(
    (OrgUnit(**ou) for ou in client.get_organisation_units(level=3, fields="id,name", order="name:asc")),
    10,
):
    print(f"  {ou.id} - {ou.name}")
