"""Fetch org units as GeoJSON, load into geopandas, and plot."""

import io
import json

import geopandas as gpd
import matplotlib.pyplot as plt

from climate_tools.config import make_client

client = make_client()

# Fetch GeoJSON for level 3 org units
geojson = client.get("/api/organisationUnits.geojson", params={"level": 3})

# Load into GeoDataFrame
gdf = gpd.read_file(io.StringIO(json.dumps(geojson)))
print(gdf[["name", "level", "geometry"]].head(10))

# Plot
gdf.plot(figsize=(8, 8), edgecolor="black", linewidth=0.5)
plt.axis("equal")
plt.title("Organisation Units (Level 3)")
plt.tight_layout()
plt.show()
