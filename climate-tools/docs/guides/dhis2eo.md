# Earth Observation Data

The [`dhis2eo`](https://github.com/dhis2/dhis2eo) library provides a unified Python interface for downloading earth observation data from multiple sources — climate reanalysis, rainfall estimates, and population models. Each data source has a consistent API: you call a `download()` function with a time range and location, and get back a list of NetCDF file paths that you can open with `xarray`.

This guide covers the three data sources available in `dhis2eo`, explains what each one is and why it matters for health, and walks through the Python code step by step.

## Data Sources

### ERA5-Land (Copernicus Climate Data Store)

ERA5-Land is a climate reanalysis dataset produced by the European Centre for Medium-Range Weather Forecasts (ECMWF). "Reanalysis" means it combines historical weather observations (from weather stations, satellites, radiosondes, buoys) with a numerical weather model to produce a physically consistent, gap-free record of atmospheric and land-surface conditions.

**Key characteristics:**

- **Temporal coverage:** 1950 to near-present (typically 5 days behind real time)
- **Temporal resolution:** Hourly
- **Spatial resolution:** ~9 km (0.1 degree grid)
- **Coverage:** Global land areas
- **Variables:** Temperature, precipitation, soil moisture, evaporation, wind, solar radiation, snow cover, and many more (~50 variables total)

ERA5-Land is particularly useful for health applications because it provides consistent, gap-free climate data even in regions with sparse weather station networks. Common use cases include:

- Linking temperature and humidity to disease transmission (malaria, dengue)
- Tracking drought conditions via soil moisture and precipitation anomalies
- Computing heat stress indicators for early warning systems

**Data access:** ERA5-Land is distributed through the [Copernicus Climate Data Store (CDS)](https://cds.climate.copernicus.eu/). The CDS is a free service run by the European Union's Copernicus programme. You need to create an account and obtain an API key to download data programmatically.

### CHIRPS (Climate Hazards Group)

CHIRPS (Climate Hazards Group InfraRed Precipitation with Station data) is a rainfall dataset produced by the Climate Hazards Center at UC Santa Barbara. It blends satellite-based precipitation estimates with ground station observations to produce daily and monthly rainfall grids.

**Key characteristics:**

- **Temporal coverage:** 1981 to near-present
- **Temporal resolution:** Daily (also available as monthly, pentadal, and dekadal)
- **Spatial resolution:** ~5 km (0.05 degrees)
- **Coverage:** 50 S to 50 N (tropical and subtropical regions)
- **Variables:** Precipitation only (mm/day)

CHIRPS is the go-to rainfall dataset for food security and drought monitoring in tropical regions. It is widely used by:

- Famine Early Warning Systems Network (FEWS NET)
- National meteorological agencies in data-sparse regions
- Agricultural and health programmes that need long-term rainfall records

Compared to ERA5, CHIRPS has higher spatial resolution (5 km vs 9 km) and a longer record (1981 vs 1950), but only provides precipitation — not temperature or other variables. In practice, many projects use both: CHIRPS for rainfall and ERA5 for temperature.

**Data access:** CHIRPS data is freely available from the [Climate Hazards Center](https://www.chc.ucsb.edu/data/chirps) at UC Santa Barbara. No API key is required — `dhis2eo` downloads directly from their public servers.

### WorldPop

WorldPop produces gridded population estimates — modelled counts of how many people live in each grid cell. These models combine census data with satellite imagery (settlement patterns, building footprints, land use) and other covariates to distribute population counts from census zones onto a regular grid.

**Key characteristics:**

| Version | Resolution | Years | Method |
|---|---|---|---|
| `global1` | ~1 km | 2000-2020 | UN-adjusted, unconstrained |
| `global2` (default) | 100 m | 2015-2030 | Constrained to built-up areas |

- **Coverage:** Global (downloaded per country using ISO3 country codes)
- **Variables:** Total population count per grid cell

"Constrained" (global2) means population is only placed in grid cells that contain buildings, based on satellite-derived building footprint data. This produces more realistic distributions — no population in forests, water bodies, or empty land. "Unconstrained" (global1) spreads population more evenly based on statistical models.

Population data is essential for computing population-weighted health indicators in DHIS2 — for example, converting raw case counts into incidence rates (cases per 1,000 population).

**Data access:** WorldPop data is freely available from [worldpop.org](https://www.worldpop.org/). No API key required.

### Comparing the data sources

| | CHIRPS | ERA5-Land | WorldPop |
|---|---|---|---|
| **What it measures** | Rainfall | Weather (temperature, rainfall, wind, radiation, humidity, evaporation) | Population |
| **How it's made** | Satellite imagery + weather stations | Physics-based weather model + observations | Census data + satellite building detection |
| **Resolution** | ~5 km | ~9 km | 100 m |
| **Time step** | Daily | Hourly (aggregated to daily in pipelines) | Yearly |
| **Coverage** | Tropics (50°S–50°N) | Global | Global (per country) |
| **Record** | 1981–present | 1950–present | 2015–2030 |
| **API key needed** | No | Yes (Copernicus CDS) | No |

**Overlap:** Precipitation is the only variable available from both CHIRPS and ERA5. CHIRPS has higher spatial resolution (5 km vs 9 km) and is observation-based, making it generally preferred for rainfall in tropical regions. ERA5 is the only source for temperature, wind, solar radiation, and other climate variables. WorldPop has no overlap with the climate sources — it measures people, not weather.

**Typical combinations for health applications:**

- **Malaria risk** → ERA5 temperature + CHIRPS rainfall + WorldPop population
- **Drought monitoring** → CHIRPS rainfall anomalies
- **Heat stress early warning** → ERA5 temperature + humidity
- **Disease incidence rates** → case counts ÷ WorldPop population
- **Agricultural planning** → CHIRPS rainfall + ERA5 solar radiation + evaporation

## File formats: NetCDF and GeoTIFF

Earth observation data is distributed in two main raster formats. Both store gridded data (values on a regular latitude/longitude grid), but they are designed for different use cases.

### NetCDF (.nc)

NetCDF (Network Common Data Form) is the standard format for multidimensional scientific data — especially climate and weather data. A single NetCDF file can hold multiple variables (e.g. temperature, precipitation, wind) across multiple time steps, all sharing the same spatial grid.

**Structure:** dimensions + variables + metadata, similar to a dictionary of labelled arrays.

```
Dimensions:  (time: 31, latitude: 12, longitude: 10)
Variables:
    t2m      (time, latitude, longitude)  — 2m temperature in Kelvin
    tp       (time, latitude, longitude)  — total precipitation in metres
```

**Used by:** ERA5-Land and CHIRPS in `dhis2eo`. Both `hourly.download()` and `daily.download()` return `.nc` files that you open with `xr.open_mfdataset()`.

**Key properties:**

- Supports multiple variables and time steps in one file
- Self-describing — variable names, units, and coordinate reference system are stored inside
- Optimised for time series access (read all time steps for one location efficiently)
- Opened with `xarray` in Python: `xr.open_dataset("file.nc")`

### GeoTIFF (.tif)

GeoTIFF is a raster image format with embedded geospatial metadata (coordinate system, extent, resolution). It is the standard format for single-snapshot spatial data — satellite imagery, elevation models, and population grids.

**Structure:** one or more bands (layers) in a single 2D grid, like a georeferenced image.

**Used by:** WorldPop in `dhis2eo`. Each `.tif` file contains population counts for one country and year. `dhis2eo` converts these to NetCDF internally so that `xr.open_mfdataset()` works uniformly across all data sources.

**Key properties:**

- Single time step per file (one year of population, one satellite scene)
- Widely supported by GIS tools (QGIS, ArcGIS, Google Earth Engine)
- Efficient for spatial queries (read a spatial subset quickly)
- Opened with `rasterio` or `xarray` + `rioxarray`: `xr.open_dataset("file.tif", engine="rasterio")`

### Which format does each source use?

| Data source | Native format | Coordinate names | Opened with |
|---|---|---|---|
| ERA5-Land | NetCDF | `valid_time`, `latitude`, `longitude` | `xr.open_mfdataset()` |
| CHIRPS | NetCDF | `time`, `y`, `x` | `xr.open_mfdataset()` |
| WorldPop | GeoTIFF (→ NetCDF) | `time`, `y`, `x` | `xr.open_mfdataset()` with `combine="nested"` |

!!! tip "You don't need to worry about the format"
    `dhis2eo` handles format differences internally. All three `download()` functions return file paths that work with `xr.open_mfdataset()`, giving you a consistent xarray interface regardless of whether the source data is NetCDF or GeoTIFF.

## Getting the bounding box from DHIS2

The CHIRPS and ERA5 download functions require a bounding box — a rectangle defined by (west, south, east, north) coordinates. The recommended approach is to fetch org units as a GeoDataFrame and use their combined bounds:

```python
import json

import geopandas as gpd
from climate_tools.config import make_client

client = make_client()

# Fetch org units as GeoJSON and load into a GeoDataFrame
geojson = client.get_org_units_geojson(level=2)
org_units = gpd.read_file(json.dumps(geojson))

# Combined bounding box for all org units — (west, south, east, north)
bbox = tuple(org_units.total_bounds)
print(f"Combined bbox: {bbox}")
```

`org_units.total_bounds` returns the minimum bounding rectangle that encloses all org unit geometries as `(minx, miny, maxx, maxy)` — which corresponds to `(west, south, east, north)`. This lets you download data once for all org units, then use polygon-based zonal statistics to aggregate per org unit.

For a single org unit, filter by ID:

```python
geojson = client.get_org_units_geojson(filter="id:eq:O6uvpzGd5pu")
org_units = gpd.read_file(json.dumps(geojson))
bbox = tuple(org_units.total_bounds)
```

## Downloading CHIRPS data

```python
from dhis2eo.data.chc.chirps3 import daily

files = daily.download(
    start="2024-01",
    end="2024-01",
    bbox=bbox,
    dirname="chirps_data",
    prefix="chirps",
)
```

**Parameters:**

- **`start`**, **`end`** — date range as strings (e.g. `"2024-01"`, `"2023-06"`)
- **`bbox`** — bounding box tuple from shapely: `(west, south, east, north)`
- **`dirname`** — directory to save downloaded files (created if it doesn't exist)
- **`prefix`** — filename prefix for the downloaded NetCDF files

**Returns:** a list of file paths (one NetCDF file per month).

### Opening the data with xarray

```python
import xarray as xr

data = xr.open_mfdataset(files, combine="nested", concat_dim="time")
print(f"Variables: {list(data.data_vars)}")
print(f"Dimensions: {dict(data.sizes)}")
print(data)
```

`xr.open_mfdataset()` combines multiple NetCDF files into a single Dataset. The result has dimensions `(time, y, x)` with daily precipitation values in mm/day.

## Downloading ERA5-Land data

ERA5-Land downloads go through the CDS API, which queues requests server-side. The first call may take a few minutes while the data is extracted.

!!! tip "CDS API progress logging"
    The example scripts enable debug logging for `ecmwf.datastores` so you can see request status updates ("Request ID is ...", "status has been updated to ...") while waiting for the CDS API. To enable this in your own scripts:

    ```python
    import logging
    logging.basicConfig(level=logging.INFO)
    logging.getLogger("ecmwf.datastores").setLevel(logging.DEBUG)
    ```

!!! note "All variables are downloaded by default"
    The CDS API makes one request per month regardless of how many variables you ask for, and the cached filename (`{source}_{country_code}_{year}-{month}.nc`, e.g. `era5_sle_2025-01.nc`) does not encode which variables are inside. If you first download one variable and later request more, the cached single-variable file would be silently reused and the extra variables would be missing. Since the size difference is negligible (~1 MB for all 7 variables vs ~125 KB for one, per month per bounding box), both scripts default to downloading all variables. You can still pass `--variables` to request a subset.

```python
from dhis2eo.data.cds.era5_land import hourly

files = hourly.download(
    start="2025-01-01",
    end="2025-03-01",
    bbox=bbox,
    dirname="era5_data",
    prefix="era5",
    variables=["total_precipitation", "2m_temperature"],  # or omit for all
)
```

**Parameters:**

- **`start`**, **`end`** — date range as strings (e.g. `"2025-01-01"`)
- **`bbox`** — bounding box tuple: `(west, south, east, north)`
- **`dirname`** — output directory
- **`prefix`** — filename prefix
- **`variables`** — list of CDS variable names to download

**Common variables:**

| CDS variable name | Description | Unit |
|---|---|---|
| `total_precipitation` | Total precipitation | m (convert to mm by multiplying by 1000) |
| `2m_temperature` | Air temperature at 2m height | K (subtract 273.15 for Celsius) |
| `2m_dewpoint_temperature` | Dewpoint temperature at 2m | K |
| `10m_u_component_of_wind` | East-west wind at 10m | m/s |
| `10m_v_component_of_wind` | North-south wind at 10m | m/s |
| `surface_solar_radiation_downwards` | Incoming solar radiation | J/m^2 |
| `total_evaporation` | Total evaporation | m |

!!! note "All 50 ERA5-Land variables are supported"
    The table above lists the most commonly used variables. The pipeline supports all 50 ERA5-Land variables, organized into categories: temperature (9), wind (2), pressure (1), precipitation & evaporation (7), runoff (3), snow (8), radiation (4), heat fluxes (2), soil moisture (4), vegetation & surface (4), and lake (6). Pass any valid CDS variable name to `--variables` — if a variable has a registered unit conversion and aggregation method, it will be processed automatically; otherwise it is imported with default settings.

!!! warning "CDS API key required"
    You need a Copernicus CDS account and API key. Sign up at [cds.climate.copernicus.eu](https://cds.climate.copernicus.eu/) and add your key to `.env`:

    ```
    ECMWF_DATASTORES_URL=https://cds.climate.copernicus.eu/api
    ECMWF_DATASTORES_KEY=your-api-key-here
    ```

### Opening ERA5 data

```python
data = xr.open_mfdataset(files, combine="nested", concat_dim="time")
print(f"Variables: {list(data.data_vars)}")
print(f"Dimensions: {dict(data.sizes)}")
print(f"Coordinates: {list(data.coords)}")
print(data)
```

ERA5 data has dimensions `(valid_time, latitude, longitude)` with hourly values.

### Processing ERA5 data: hourly to daily

ERA5 provides hourly data, but most DHIS2 use cases need daily values. The processing pipeline has three steps:

**1. Cumulative → incremental (accumulated variables only)**

Some ERA5 variables (`total_precipitation`, `surface_solar_radiation_downwards`, `total_evaporation`) are stored as cumulative sums within each forecast cycle, not as hourly amounts. To get the actual hourly value, compute the difference between consecutive time steps:

```python
import xarray as xr

da = data["tp"]  # cumulative precipitation
time_dim = "valid_time"

# Compute hourly differences
ds_diffs = da.diff(dim=time_dim)

# At forecast cycle boundaries, the cumulative resets — the diff goes negative.
# In those cases, use the raw value (which is already the first hour's accumulation).
da_incremental = xr.where(
    ds_diffs < 0,
    da.isel({time_dim: slice(1, None)}),
    ds_diffs,
)
```

Non-cumulative variables (temperature, wind, dewpoint) represent instantaneous values and don't need this step.

**2. Hourly → daily aggregation**

Use `earthkit-transforms` to aggregate hourly values into daily:

```python
from earthkit import transforms

daily_da = transforms.temporal.daily_reduce(
    da_incremental,
    how="sum",              # "sum" for precipitation, "mean" for temperature
    time_shift={"hours": 0},
    remove_partial_periods=False,
)
```

**3. Unit conversion**

ERA5 uses SI units internally. Convert to human-friendly units after aggregation:

| Variable | ERA5 unit | Convert to | Formula |
|---|---|---|---|
| `total_precipitation` | metres | mm | × 1000 |
| `2m_temperature` | Kelvin | °C | − 273.15 |
| `2m_dewpoint_temperature` | Kelvin | °C | − 273.15 |
| `surface_solar_radiation_downwards` | J/m² | MJ/m² | ÷ 1,000,000 |
| `total_evaporation` | metres (negative) | mm | abs() × 1000 |
| `10m_u/v_component_of_wind` | m/s | m/s | no conversion |

The `get_era5.py` and `pipeline_era5.py` scripts handle all three steps automatically.

### Caching

Both CHIRPS and ERA5 downloads are cached locally — if the output file already exists, the download is skipped. This means:

- **Re-running is fast** — only new months are downloaded
- **Cache invalidation is manual** — if you need to re-download, delete the cached files from the output directory
- **ERA5 cache limitation** — the filename (`{source}_{country_code}_{year}-{month}.nc`, e.g. `era5_sle_2025-01.nc`) doesn't encode which variables are inside. If you first download one variable, the cached file is reused even when you later request more. This is why the scripts default to downloading all variables.

## Downloading WorldPop data

WorldPop data is downloaded per country (not per bounding box), using ISO3 country codes:

```python
from dhis2eo.data.worldpop.pop_total import yearly

# global2 (default) — newer, 100m resolution, constrained
files = yearly.download(
    start="2020",
    end="2025",
    country_code="SLE",
    dirname="worldpop_data",
    prefix="pop",
)
```

**Parameters:**

- **`start`**, **`end`** — year range as strings
- **`country_code`** — ISO3 country code (e.g. `"SLE"` for Sierra Leone, `"VNM"` for Vietnam)
- **`dirname`** — output directory
- **`prefix`** — filename prefix
- **`version`** — optional, `"global1"` for the older 1km dataset (default is `"global2"`)

For the older 1km dataset:

```python
files = yearly.download(
    start="2020",
    end="2020",
    country_code="SLE",
    dirname="worldpop_data",
    prefix="pop",
    version="global1",
)
```

### Opening WorldPop data

WorldPop files from different years may have slightly different spatial grids (different number of pixels), so we use `combine="nested"` instead of the default:

```python
data = xr.open_mfdataset(
    files,
    combine="nested",
    concat_dim="time",
    compat="override",
    coords="minimal",
    data_vars="minimal",
)
print(f"Variables: {list(data.data_vars)}")
print(f"Dimensions: {dict(data.sizes)}")
print(data)
```

The data has dimensions `(time, y, x)` with population count per grid cell.

### WorldPop age-sex disaggregated data

Beyond total population, WorldPop provides age-sex structure rasters — population counts broken down by sex and 5-year age group. These use the `AgeSex_structures` collection (R2025A release, 100m resolution, 2015-2030).

Available datasets per country per year:

- **2 totals**: total male, total female
- **40 age-specific**: 20 age groups × 2 sexes

Age groups: 0, 1-4, 5-9, 10-14, ..., 85-89, 90+

The `get_worldpop2_agesex.py` script downloads these by monkey-patching the URL function in `dhis2eo`:

```bash
# All sex/age combinations
uv run python examples/dhis2eo/get_worldpop2_agesex.py --country-code SLE

# Total male only
uv run python examples/dhis2eo/get_worldpop2_agesex.py --country-code SLE --sex M

# Males aged 25-29
uv run python examples/dhis2eo/get_worldpop2_agesex.py --country-code SLE --sex M --age 25

# With zonal stats per org unit
uv run python examples/dhis2eo/get_worldpop2_agesex.py --country-code SLE --org-unit-level 2
```

The `pipeline_worldpop2_sex.py` script goes further — it creates DHIS2 data elements with a sex category combo (Male/Female disaggregation) and imports population by sex into DHIS2.

## Pydantic schemas for DHIS2 metadata

The pipeline scripts use Pydantic models from `climate_tools.schemas` to construct DHIS2 metadata payloads with type safety. These models mirror the DHIS2 API's JSON structure:

```python
from climate_tools.schemas import (
    DataElement, DataSet, DataSetElement,
    IdRef, MetadataPayload, PeriodType,
)

# Create a data element
de = DataElement(
    id="cWsMKdoG1Hk",
    name="DEMO: CHIRPS daily precipitation (mm/day)",
    shortName="DEMO: CHIRPS precip mm/day",
    aggregationType="AVERAGE",
)

# Create a data set grouping the element and assigning org units
metadata = MetadataPayload(
    dataElements=[de],
    dataSets=[
        DataSet(
            id="aPqsx2MwYkT",
            name="DEMO: Climate - Earth Observation",
            shortName="DEMO: Climate EO",
            periodType=PeriodType.DAILY,
            dataSetElements=[DataSetElement(dataElement=de)],
            organisationUnits=[IdRef(id="O6uvpzGd5pu")],
        ),
    ],
)

# POST to DHIS2 — creates or updates by UID (idempotent)
result = client.post("/api/metadata", json=metadata.model_dump(exclude_none=True))
```

Key models:

| Model | Purpose |
|---|---|
| `DataElement` | A single data element (name, value type, aggregation type) |
| `DataSet` | Groups data elements, assigns org units, defines period type |
| `DataSetElement` | Links a data element to a data set |
| `IdRef` | Minimal UID reference (used for org unit assignments) |
| `MetadataPayload` | Top-level payload for `/api/metadata` |
| `PeriodType` | Enum: `Daily`, `Weekly`, `Monthly`, `Quarterly`, `Yearly` |

Using fixed UIDs makes scripts idempotent — the DHIS2 metadata endpoint's default MERGE strategy creates objects if they don't exist or updates them if they do.

!!! tip "`openFuturePeriods` for forecast data"
    Set `openFuturePeriods` on a `DataSet` to allow entering data for future periods. For example, the WorldPop pipeline sets `openFuturePeriods=10` because WorldPop provides population projections through 2030. Without this, DHIS2 would reject data values for periods beyond the current date.

## Working with xarray

All downloaded data is opened with `xarray`, which provides labelled multi-dimensional arrays — like numpy arrays with named dimensions and coordinates.

### Key concepts

```python
import xarray as xr

# Open multiple files as a single dataset
ds = xr.open_mfdataset(files, combine="nested", concat_dim="time")

# Dataset = collection of DataArrays (like a dict of labelled arrays)
print(ds)                    # overview of all variables and dimensions
print(ds.data_vars)          # list of variable names
print(ds.dims)               # dimension names and sizes
print(ds.coords)             # coordinate arrays (time, lat, lon)

# Access a single variable as a DataArray
da = ds["precip"]            # shape: (time, y, x)
print(da.shape)
print(da.values)             # underlying numpy array
```

### Common operations

```python
# Select a time step
da_day1 = da.sel(time="2024-01-01")

# Slice a region
da_subset = da.sel(y=slice(8, 9), x=slice(-12, -11))

# Compute statistics
da.mean(dim="time")          # temporal mean (one map)
da.mean(dim=["y", "x"])      # spatial mean (one time series)

# Drop auxiliary variables from ERA5
ds = ds.drop_vars([v for v in ["number", "expver"] if v in ds])
```

### Why `open_mfdataset`?

Each download function returns multiple files (one per month/year). `xr.open_mfdataset()` opens all files and concatenates them along the time dimension into a single dataset. The `combine="nested"` and `concat_dim="time"` parameters explicitly control how files are combined, avoiding issues when files have slightly different coordinate values.

## Polygon-based zonal statistics

The pipeline scripts use `earthkit-transforms` for polygon-based spatial aggregation. Instead of clipping rasters to bounding boxes (which overestimates for irregular shapes), `transforms.spatial.reduce` masks each org unit's exact polygon geometry:

```python
from earthkit import transforms

# ds_daily is an xarray DataArray with dims (time, y, x)
# org_units is a GeoDataFrame with "id" and "geometry" columns

ds_org_units = transforms.spatial.reduce(
    ds_daily, org_units, mask_dim="id", how="mean",
    lat_key="y", lon_key="x",
)
```

**Parameters:**

- **`ds_daily`** — xarray DataArray with spatial coordinates
- **`org_units`** — GeoDataFrame with polygon geometries
- **`mask_dim`** — column from the GeoDataFrame to use as the output dimension (typically `"id"`)
- **`how`** — aggregation method: `"mean"` for averages (precipitation, temperature), `"sum"` for totals (population)
- **`lat_key`** / **`lon_key`** — coordinate names in the DataArray (e.g. `"y"`/`"x"` for CHIRPS/WorldPop, auto-detected for ERA5)

The result is a DataArray with dimensions `(time, id)` — one value per org unit per time step. Convert to a DataFrame for DHIS2:

```python
df = ds_org_units.to_dataframe().reset_index()
# Columns: time, id, <value_column>
```

## Pushing data into DHIS2

After computing zonal statistics, the final step is converting the DataFrame to DHIS2's `dataValueSets` JSON format and posting it.

### Converting a DataFrame to DHIS2 format

The `dhis2eo` library provides `dataframe_to_dhis2_json()` to convert a pandas DataFrame into the format expected by the DHIS2 `dataValueSets` endpoint:

```python
from dhis2eo.integrations.pandas import dataframe_to_dhis2_json

# df has columns: id (org unit), time (period), precip (value)
payload = dataframe_to_dhis2_json(
    df,
    data_element_id="cWsMKdoG1Hk",    # which data element to store as
    org_unit_col="id",                  # column containing org unit UIDs
    period_col="time",                  # column containing dates/periods
    value_col="precip",                 # column containing the numeric values
)
```

The result is a dictionary like:

```json
{
    "dataValues": [
        {"dataElement": "cWsMKdoG1Hk", "orgUnit": "O6uvpzGd5pu", "period": "20240101", "value": "3.42"},
        {"dataElement": "cWsMKdoG1Hk", "orgUnit": "O6uvpzGd5pu", "period": "20240102", "value": "0.15"},
        ...
    ]
}
```

### Posting to DHIS2

```python
result = client.post_data_value_set(payload)
imported = result.get("response", {}).get("importCount", {})
print(f"Imported: {imported.get('imported', 0)}, Updated: {imported.get('updated', 0)}")
```

The import is idempotent — posting the same values again updates rather than duplicates them (matched by data element + org unit + period + category option combo).

### Period formats

DHIS2 expects periods in specific formats depending on the period type:

| Period type | Format | Example |
|---|---|---|
| Daily | `YYYYMMDD` | `20240115` |
| Weekly | `YYYYWn` | `2024W3` |
| Monthly | `YYYYMM` | `202401` |
| Quarterly | `YYYYQn` | `2024Q1` |
| Yearly | `YYYY` | `2024` |

The `dataframe_to_dhis2_json()` function converts datetime columns to the appropriate format automatically.

## End-to-end pipelines

The `pipeline_*.py` scripts in `examples/dhis2eo/` go beyond downloading — they create DHIS2 metadata (using Pydantic schemas), compute polygon-based zonal statistics (using `transforms.spatial.reduce`), and push aggregate values into DHIS2. Each pipeline follows the same pattern:

1. **Fetch org units** as a GeoDataFrame from DHIS2
2. **Create metadata** — data elements and data sets (idempotent, uses stable UIDs and Pydantic schemas)
3. **Download data** — fetch raster files using the combined bounding box of all org units
4. **Compute zonal statistics** — `transforms.spatial.reduce` for polygon-based aggregation per org unit
5. **Push to DHIS2** — `dataframe_to_dhis2_json()` converts the DataFrame to `dataValueSets` format

### CHIRPS pipeline

Downloads daily rainfall once for all org units, computes daily mean precipitation (mm/day) per org unit using polygon-based spatial mean and imports daily values directly:

```bash
# Single district (Bo)
uv run python examples/dhis2eo/pipeline_chirps.py --org-unit O6uvpzGd5pu --country-code SLE

# All 13 districts in Sierra Leone
uv run python examples/dhis2eo/pipeline_chirps.py --org-unit-level 2 --country-code SLE

# Custom date range
uv run python examples/dhis2eo/pipeline_chirps.py --org-unit-level 2 --country-code SLE --start 2024-06-01 --end 2024-06-30
```

### ERA5 pipeline

Downloads hourly data once for all org units, converts cumulative variables to incremental values, aggregates to daily values with unit conversion and polygon-based spatial mean:

```bash
# Default (all 7 variables)
uv run python examples/dhis2eo/pipeline_era5.py --org-unit O6uvpzGd5pu --country-code SLE

# Subset of variables
uv run python examples/dhis2eo/pipeline_era5.py --org-unit-level 2 --country-code SLE \
    --variables 2m_temperature total_precipitation
```

The pipeline handles cumulative-to-incremental conversion for accumulated variables (precipitation, solar radiation, evaporation) and unit conversions automatically (Kelvin to Celsius, metres to millimetres, Joules to Megajoules).

### WorldPop pipeline

Downloads country-level population rasters, computes total population per org unit using polygon-based zonal sum:

```bash
# Single district
uv run python examples/dhis2eo/pipeline_worldpop2.py --org-unit O6uvpzGd5pu --country-code SLE

# All districts, multiple years
uv run python examples/dhis2eo/pipeline_worldpop2.py --org-unit-level 2 --country-code SLE \
    --start 2020 --end 2025
```

WorldPop downloads the full country file once and caches it locally, so processing multiple org units is fast.

### Running all pipelines

To populate all data at once:

```bash
bash run_all_imports.sh
```

This imports ERA5 (7 variables, 3 months), WorldPop (6 years), and CHIRPS (6 months) for all 13 Sierra Leone districts.

### Visualizing NetCDF files

The `nc-to-png` tool converts NetCDF variables and time steps into PNG heatmaps for quick visual inspection:

```bash
# All variables and time steps (up to 10 by default)
./tools/nc-to-png data/era5_sle_2025-01.nc

# Specific variable, custom output directory
./tools/nc-to-png data/chirps_sle_2024-06.nc --variable precip --output-dir plots/

# Limit number of time steps
./tools/nc-to-png data/era5_sle_2025-01.nc --variable t2m --max-steps 5
```

### Querying the results

After running the pipelines, query the data back from DHIS2:

```bash
uv run python examples/dhis2eo/query_climate_analytics.py --org-unit O6uvpzGd5pu
uv run python examples/dhis2eo/query_climate_analytics.py --org-unit-level 2
```

!!! note "Analytics tables"
    The Analytics API reads from pre-computed tables. After pushing new data, DHIS2 may need to rebuild its analytics tables before the data appears. On the play server this happens automatically; on a production server, trigger it via **Maintenance > Analytics Tables**.
