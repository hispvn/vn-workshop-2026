"""Shared configuration: load .env and create a DHIS2Client."""

import os

from dhis2_client import DHIS2Client
from dotenv import load_dotenv

load_dotenv()


def make_client() -> DHIS2Client:
    """Create a DHIS2Client from environment variables (or defaults to play server)."""
    return DHIS2Client(
        base_url=os.getenv("DHIS2_BASE_URL", "https://play.im.dhis2.org/dev/"),
        username=os.getenv("DHIS2_USERNAME", "admin"),
        password=os.getenv("DHIS2_PASSWORD", "district"),
    )
