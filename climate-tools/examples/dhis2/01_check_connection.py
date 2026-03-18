"""Connect to DHIS2 and print system info."""

from climate_tools.config import make_client

client = make_client()

info = client.get_system_info()
print(f"Connected to: {info['systemName']}")
print(f"Version:      {info['version']}")
print(f"Revision:     {info['revision']}")
print(f"Server date:  {info['serverDate']}")
