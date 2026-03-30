"""prefect-dhis2 — Prefect integration for DHIS2.

Exports:
    DHIS2Client: authenticated HTTP client from the dhis2-client package
    Dhis2Credentials: Prefect Block for storing DHIS2 connection details
    get_dhis2_credentials: load a credentials block by name from the server
"""

from dhis2_client import DHIS2Client

from prefect_dhis2.credentials import Dhis2Credentials
from prefect_dhis2.utils import get_dhis2_credentials

__all__ = [
    "DHIS2Client",
    "Dhis2Credentials",
    "get_dhis2_credentials",
]
