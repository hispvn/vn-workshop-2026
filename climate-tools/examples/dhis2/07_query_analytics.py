"""Run an analytics query: aggregate data for a data element across org units."""

from climate_tools.config import make_client
from climate_tools.schemas import AnalyticsResult

client = make_client()

# Query analytics for a data element across level-2 org units
# Uses "ANC 1st visit" (fbfJHSPpUQD) as an example
params = {
    "dimension": "dx:fbfJHSPpUQD,ou:LEVEL-2,pe:LAST_4_QUARTERS",
    "skipMeta": "true",
}

response = client.get("/api/analytics.json", params=params)
result = AnalyticsResult(**response)

print(f"Analytics query returned {len(result.rows)} rows")
print(f"Columns: {[h.name for h in result.headers]}\n")

print("First 10 rows:")
for row in result.rows[:10]:
    print(f"  {row}")
