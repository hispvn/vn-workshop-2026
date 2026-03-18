# Climate Tools Workshop

Workshop: Introduction to DHIS2 climate tools using `dhis2-python-client` and `dhis2eo`.

## Quick Start

```bash
# Install dependencies
uv sync

# Copy environment template
cp .env.example .env

# Run the first example
uv run python examples/dhis2/01_check_connection.py
```

## Examples

### DHIS2 Python Client (`examples/dhis2/`)

| Script | Description |
|--------|-------------|
| `01_check_connection.py` | Connect to DHIS2, print system info |
| `02_browse_org_units.py` | Browse org unit hierarchy |
| `03_plot_org_units.py` | Fetch + plot org units as GeoJSON |
| `04_list_users.py` | Get current user, list users |
| `05_search_data_elements.py` | Search data elements by name |
| `06_explore_data_sets.py` | Explore data sets and their structure |
| `07_query_analytics.py` | Run an analytics query |
| `08_push_data_value.py` | Write a data value and read it back |
| `09_get_data_values.py` | Fetch raw data values for a data set |
| `10_explore_categories.py` | Explore categories and disaggregation |
| `11_org_unit_tree.py` | Walk the org unit hierarchy tree |
| `12_analytics_to_dataframe.py` | Analytics query → pandas DataFrame |
| `13_plot_analytics.py` | Plot analytics data as bar charts |
| `14_create_metadata.py` | Create categories, data elements, and data set |

### Earth Observation — Download (`examples/dhis2eo/get_*.py`)

| Script | Description |
|--------|-------------|
| `get_chirps.py` | Download CHIRPS precipitation for an org unit |
| `get_era5.py` | Download ERA5-Land climate data for an org unit |
| `get_worldpop1.py` | Download WorldPop population (global1 version) |
| `get_worldpop2.py` | Download WorldPop population (global2 version) |

```bash
uv run python examples/dhis2eo/get_chirps.py --org-unit O6uvpzGd5pu
uv run python examples/dhis2eo/get_era5.py --org-unit O6uvpzGd5pu
uv run python examples/dhis2eo/get_worldpop2.py O6uvpzGd5pu --country-code SLE
```

### Earth Observation — Full Pipelines (`examples/dhis2eo/pipeline_*.py`)

End-to-end scripts that create metadata, download data, compute zonal statistics, and push into DHIS2. Use `--org-unit <UID>` for a single org unit or `--org-unit-level <N>` for all at a level:

| Script | Description |
|--------|-------------|
| `pipeline_chirps.py` | CHIRPS rainfall → monthly mean precipitation → DHIS2 |
| `pipeline_era5.py` | ERA5-Land → monthly temperature & precipitation → DHIS2 |
| `pipeline_worldpop.py` | WorldPop → population per org unit → DHIS2 |
| `query_climate_analytics.py` | Query pushed climate data via DHIS2 Analytics API |

```bash
# Import all data for all 13 districts (CHIRPS + ERA5 + WorldPop)
bash run_all_imports.sh

# Or run individual pipelines:
uv run python examples/dhis2eo/pipeline_chirps.py --org-unit-level 2
uv run python examples/dhis2eo/pipeline_era5.py --org-unit-level 2 \
    --variables total_precipitation 2m_temperature
uv run python examples/dhis2eo/pipeline_worldpop.py --org-unit-level 2 --country-code SLE

# Or a single district (Bo)
uv run python examples/dhis2eo/pipeline_chirps.py --org-unit O6uvpzGd5pu

# Query the pushed data
uv run python examples/dhis2eo/query_climate_analytics.py --org-unit-level 2
```

## Development

```bash
make lint      # Run linters
make format    # Auto-format code
make test      # Run tests
make docs-serve  # Serve docs locally
```
