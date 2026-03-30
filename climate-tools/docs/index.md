# Climate Tools Workshop

This workshop introduces two Python libraries for working with DHIS2 and earth observation data:

- **[dhis2-python-client](https://github.com/dhis2/dhis2-python-client)** — a typed Python client for the DHIS2 Web API
- **[dhis2eo](https://github.com/dhis2/dhis2eo)** — tools for downloading climate and population data and importing it into DHIS2

## What you'll learn

### Part A: DHIS2 Python Client

Learn to interact with DHIS2 programmatically — connecting to a server, browsing org units, querying analytics, and creating metadata. The guide covers reading data (org units, data elements, analytics), writing data (data values, bulk imports), creating metadata (categories, data elements, data sets), and understanding the org unit hierarchy.

[Go to the DHIS2 Client guide](guides/dhis2-client.md)

### Part B: Earth Observation — Downloading and Processing Data

Download satellite and climate data for DHIS2 org units using `dhis2eo`:

- **ERA5-Land** — hourly climate reanalysis from Copernicus (temperature, precipitation, wind, radiation)
- **CHIRPS** — daily rainfall estimates from the Climate Hazards Center
- **WorldPop** — gridded population estimates at 100m resolution, including age-sex disaggregation

The guide covers data sources, file formats (NetCDF and GeoTIFF), processing steps (cumulative-to-incremental, hourly-to-daily, unit conversion), working with xarray, polygon-based zonal statistics, and pushing results into DHIS2.

[Go to the Earth Observation guide](guides/dhis2eo.md)

### Part C: End-to-End Pipelines

The `pipeline_*.py` scripts go beyond downloading — they create DHIS2 metadata, compute zonal statistics, and push aggregate values into DHIS2. These are covered at the end of the Earth Observation guide.

## Getting started

Head to the [Setup guide](guides/setup.md) to install dependencies and verify your connection.
