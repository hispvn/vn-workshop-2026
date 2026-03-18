"""Query analytics data from DHIS2 and plot as a bar chart.

Builds on example 12 — queries ANC data across all districts for the last
4 quarters, then plots a grouped bar chart comparing ANC 1st visit vs
ANC 4th or more visits per district.

Usage:
  uv run python examples/dhis2/13_plot_analytics.py
"""

import matplotlib.pyplot as plt
import pandas as pd

from climate_tools.config import make_client

client = make_client()

# -- Query analytics --
data_elements = "fbfJHSPpUQD;hfdmMSPBgLG"

print("Querying analytics: ANC 1st visit & ANC 4th+ visits, all districts, last 4 quarters...")

response = client.get(
    "/api/analytics.json",
    params={
        "dimension": f"dx:{data_elements},ou:LEVEL-2,pe:LAST_4_QUARTERS",
        "skipMeta": "false",
    },
)

# -- Parse into DataFrame --
headers = [h["name"] for h in response["headers"]]
df = pd.DataFrame(response["rows"], columns=headers)  # pyright: ignore[reportArgumentType]
df["value"] = pd.to_numeric(df["value"])

# Map UIDs to names
meta_items = response.get("metaData", {}).get("items", {})
uid_to_name = {uid: info.get("name", uid) for uid, info in meta_items.items()}
df["Data element"] = df["dx"].map(uid_to_name)  # pyright: ignore[reportArgumentType]
df["Org unit"] = df["ou"].map(uid_to_name)  # pyright: ignore[reportArgumentType]
df["Period"] = df["pe"].map(uid_to_name)  # pyright: ignore[reportArgumentType]

# -- Plot 1: Grouped bar chart for the latest quarter --
latest_period = df["Period"].iloc[-1]
latest = df[df["Period"] == latest_period]

pivot = latest.pivot_table(
    index="Org unit",
    columns="Data element",
    values="value",
    aggfunc="sum",
).sort_values("ANC 1st visit", ascending=True)

fig, ax = plt.subplots(figsize=(10, 6))
pivot.plot(kind="barh", ax=ax)
ax.set_xlabel("Count")
ax.set_ylabel("")
ax.set_title(f"ANC visits by district ({latest_period})")
ax.legend(loc="lower right")
plt.tight_layout()

# -- Plot 2: Time series for all districts stacked --
fig2, axes = plt.subplots(1, 2, figsize=(14, 6), sharey=True)

for i, de_name in enumerate(df["Data element"].unique()):
    de_df = df[df["Data element"] == de_name]
    pivot_ts = de_df.pivot_table(index="Period", columns="Org unit", values="value", aggfunc="sum")
    pivot_ts.plot(kind="bar", stacked=True, ax=axes[i], legend=(i == 1))
    axes[i].set_title(de_name)
    axes[i].set_xlabel("")
    axes[i].tick_params(axis="x", rotation=45)

if axes[1].get_legend():
    axes[1].legend(bbox_to_anchor=(1.05, 1), loc="upper left", fontsize="small")

plt.suptitle("ANC visits by quarter and district", y=1.02)
plt.tight_layout()
plt.show()
