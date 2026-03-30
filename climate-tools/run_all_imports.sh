#!/usr/bin/env bash
# ==========================================================================
# Import all earth observation data for Sierra Leone districts (level 2).
#
# This script runs all three pipelines for all 13 districts, populating
# DHIS2 with climate and population data. It's designed to be run once
# to set up a complete demo dataset.
#
# What gets imported:
#   - CHIRPS: daily mean precipitation (mm/day)
#   - ERA5:   daily total precipitation (mm), mean temperature (°C),
#             soil moisture, evaporation, wind speed
#   - WorldPop: yearly population estimates
#
# Prerequisites:
#   - .env configured with DHIS2 credentials
#   - .env configured with ECMWF_DATASTORES_URL and ECMWF_DATASTORES_KEY
#
# Usage:
#   bash run_all_imports.sh
# ==========================================================================
set -euo pipefail

LEVEL=2           # Districts in Sierra Leone
COUNTRY=SLE       # ISO3 code for Sierra Leone

echo "============================================"
echo "Importing EO data for all level $LEVEL org units"
echo "Country: $COUNTRY"
echo "============================================"

# --------------------------------------------------------------------------
# 1. ERA5-Land — daily climate variables
# --------------------------------------------------------------------------
# ERA5-Land provides many land surface variables. We import the most useful
# ones for health and climate analysis:
#
#   total_precipitation     — daily rainfall total (m → mm)
#   2m_temperature          — air temperature at 2m above ground (K → °C)
#   2m_dewpoint_temperature — dewpoint temperature, proxy for humidity (K → °C)
#   10m_u_component_of_wind — east-west wind component at 10m (m/s)
#   10m_v_component_of_wind — north-south wind component at 10m (m/s)
#   surface_solar_radiation_downwards — incoming solar radiation (J/m²)
#   total_evaporation       — total evaporation from land surface (m → mm)
#
# Note: each variable × day × district is a separate CDS API request,
# so this step can take a while. Start with fewer months if testing.
echo ""
echo "=== ERA5-Land: climate variables (Jan–Mar 2025) ==="
uv run python examples/dhis2eo/pipeline_era5.py \
    --org-unit-level "$LEVEL" \
    --start 2025-01-01 --end 2025-03-01 \
    --variables \
        total_precipitation \
        2m_temperature \
        2m_dewpoint_temperature \
        10m_u_component_of_wind \
        10m_v_component_of_wind \
        surface_solar_radiation_downwards \
        total_evaporation

# --------------------------------------------------------------------------
# 2. WorldPop — yearly population estimates
# --------------------------------------------------------------------------
# WorldPop global2 covers 2015–2030. The country file is downloaded once
# and clipped for each district, so this is fast even for many org units.
echo ""
echo "=== WorldPop: population estimates (2020–2025) ==="
uv run python examples/dhis2eo/pipeline_worldpop.py \
    --org-unit-level "$LEVEL" \
    --country-code "$COUNTRY" \
    --start 2020 --end 2025

# --------------------------------------------------------------------------
# 3. WorldPop — sex-disaggregated population estimates
# --------------------------------------------------------------------------
# WorldPop AgeSex_structures provides separate male and female population
# rasters. This pipeline creates a Sex category dimension in DHIS2 so that
# male and female counts are stored as disaggregated values.
echo ""
echo "=== WorldPop: population by sex (2020–2025) ==="
uv run python examples/dhis2eo/pipeline_worldpop_sex.py \
    --org-unit-level "$LEVEL" \
    --country-code "$COUNTRY" \
    --start 2020 --end 2025

# --------------------------------------------------------------------------
# 4. CHIRPS — daily mean precipitation
# --------------------------------------------------------------------------
# CHIRPS data is available from 1981, but we import a recent one-month window.
# Each district gets one value per day.
# Note: CHIRPS servers (CHC, UC Santa Barbara) can be slow from some regions.
echo ""
echo "=== CHIRPS: daily precipitation (Jun 2024) ==="
uv run python examples/dhis2eo/pipeline_chirps.py \
    --org-unit-level "$LEVEL" \
    --start 2024-06-01 --end 2024-06-30

# --------------------------------------------------------------------------
# Done
# --------------------------------------------------------------------------
echo ""
echo "============================================"
echo "All imports complete!"
echo ""
echo "Verify in DHIS2:"
echo "  Data Entry → select a district → select a DEMO: data set → select period"
echo ""
echo "To query via API:"
echo "  uv run python examples/dhis2eo/query_climate_analytics.py --org-unit-level $LEVEL"
echo "============================================"
