# Setup Guide

## Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) package manager

### Install uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Project Setup

### 1. Clone the repository

```bash
git clone <repo-url>
cd climate-tools
```

### 2. Install dependencies

```bash
uv sync
```

### 3. Configure environment

Copy the environment template and edit if needed:

```bash
cp .env.example .env
```

The default values point to the DHIS2 Sierra Leone demo server:

```
DHIS2_BASE_URL=https://play.im.dhis2.org/dev/
DHIS2_USERNAME=admin
DHIS2_PASSWORD=district
```

### 4. Configure ERA5 credentials (optional)

The ERA5 pipeline requires a Copernicus Climate Data Store (CDS) API key.
If you only want to run CHIRPS and WorldPop examples, you can skip this step.

1. Sign up at <https://cds.climate.copernicus.eu/>
2. Go to your profile page to find your API key
3. Add to your `.env`:

```
ECMWF_DATASTORES_URL=https://cds.climate.copernicus.eu/api
ECMWF_DATASTORES_KEY=your-api-key-here
```

### 5. Run your first example

```bash
uv run python examples/dhis2/01_check_connection.py
```

You should see output like:

```
Connected to: DHIS 2 Demo - Sierra Leone
Version:      2.42.0
...
```

## Running Examples

Examples are organized in two directories:

```bash
# DHIS2 Python Client examples
uv run python examples/dhis2/01_check_connection.py
uv run python examples/dhis2/04_list_users.py
uv run python examples/dhis2/02_browse_org_units.py

# Earth Observation — download data
uv run python examples/dhis2eo/get_chirps.py --org-unit O6uvpzGd5pu
uv run python examples/dhis2eo/get_era5.py --org-unit O6uvpzGd5pu
uv run python examples/dhis2eo/get_worldpop2.py O6uvpzGd5pu --country-code SLE

# Earth Observation — full pipelines (create metadata + download + push to DHIS2)
uv run python examples/dhis2eo/pipeline_chirps.py --org-unit O6uvpzGd5pu
uv run python examples/dhis2eo/pipeline_era5.py --org-unit O6uvpzGd5pu
uv run python examples/dhis2eo/pipeline_worldpop.py --org-unit O6uvpzGd5pu --country-code SLE

# Run all pipelines for all 13 districts at once
bash run_all_imports.sh
```

## Troubleshooting

### Connection errors

- Check that your `.env` file has the correct URL, username, and password
- The play server resets nightly — metadata created by the pipelines will be gone the next day
- The play server may be temporarily unavailable — try again in a few minutes

### ERA5 errors

- `FileNotFoundError: ~/.ecmwfdatastoresrc` — you need to add CDS credentials to `.env` (see step 4 above)
- CDS API requests can take a few minutes to process — be patient

### Import errors

- Make sure you ran `uv sync` to install all dependencies
- Check that you're running from the project root directory

### Slow downloads

- CHIRPS data (CHC servers at UC Santa Barbara) can be slow from some regions
- ERA5 downloads go through the CDS API queue — first request may take a few minutes
- WorldPop downloads the full country file once, then caches it locally
