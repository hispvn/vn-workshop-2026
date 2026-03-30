"""Query analytics data and convert to a pandas DataFrame for analysis.

The Analytics API is the main way to read aggregated data from DHIS2. It
returns data in a rows/columns format that maps naturally to a DataFrame.

This script queries multiple data elements across org units and time periods,
converts the result to a pandas DataFrame with human-readable names, and
shows how to pivot and summarise the data.

Usage:
  uv run python examples/dhis2/12_analytics_to_dataframe.py
"""

import pandas as pd

from climate_tools.config import make_client

client = make_client()

# -- Query: ANC 1st visit + ANC 4th or more visits, all districts, last 4 quarters --
# fbfJHSPpUQD = ANC 1st visit
# hfdmMSPBgLG = ANC 4th or more visits
data_elements = "fbfJHSPpUQD;hfdmMSPBgLG"

print("Querying analytics: ANC 1st visit & ANC 4th+ visits, all districts, last 4 quarters...\n")

response = client.get(
    "/api/analytics.json",
    params={
        "dimension": f"dx:{data_elements},ou:LEVEL-2,pe:LAST_4_QUARTERS",
        "skipMeta": "false",
    },
)

# -- Parse into DataFrame --
# Analytics returns columns like "dx", "ou", "pe", "value"
headers = [h["name"] for h in response["headers"]]
df = pd.DataFrame(response["rows"], columns=headers)  # pyright: ignore[reportArgumentType]
df["value"] = pd.to_numeric(df["value"])

# -- Map UIDs to human-readable names using response metadata --
meta_items = response.get("metaData", {}).get("items", {})
uid_to_name = {uid: info.get("name", uid) for uid, info in meta_items.items()}

df["Data element"] = df["dx"].map(uid_to_name)  # pyright: ignore[reportArgumentType]
df["Org unit"] = df["ou"].map(uid_to_name)  # pyright: ignore[reportArgumentType]
df["Period"] = df["pe"].map(uid_to_name)  # pyright: ignore[reportArgumentType]

print(f"Results: {len(df)} rows\n")
print(df[["Data element", "Org unit", "Period", "value"]].to_string(index=False))

# -- Pivot: org units as rows, data elements as columns --
print("\n\nPivot table (latest quarter):\n")
latest_period = df["Period"].iloc[-1] if not df.empty else ""
latest = df[df["Period"] == latest_period]

if not latest.empty:
    pivot = latest.pivot_table(
        index="Org unit",
        columns="Data element",
        values="value",
        aggfunc="sum",
    )
    print(pivot.to_string())
