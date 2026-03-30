"""Push a single data value into DHIS2 and read it back.

DHIS2 stores aggregate data as individual data values, each identified by:
  - data element (what is being measured)
  - org unit (where)
  - period (when)
  - category option combo (disaggregation, e.g. age/sex — default if none)

This script writes a single value using the data value API, then reads it
back to confirm. This is the simplest way to push data — for bulk imports,
see the pipeline examples which use post_data_value_set().

Usage:
  uv run python examples/dhis2/08_push_data_value.py
"""

from climate_tools.config import make_client

client = make_client()

# -- Write a data value --
# Using "ANC 1st visit" (fbfJHSPpUQD) as an example data element,
# Bo district (O6uvpzGd5pu), January 2024.
# "co" is the category option combo — use the default (no disaggregation).
DE = "fbfJHSPpUQD"  # ANC 1st visit
OU = "O6uvpzGd5pu"  # Bo
PE = "202401"  # January 2024
CO = "HllvX50cXC0"  # default category option combo
VALUE = "42"

print(f"Writing: dataElement={DE}, orgUnit={OU}, period={PE}, value={VALUE}")
client.set_data_value(de=DE, pe=PE, ou=OU, co=CO, value=VALUE)
print("  Done.")

# -- Read it back --
print("\nReading back:")
result = client.get_data_value(de=DE, pe=PE, ou=OU)
print(f"  Value: {result}")
