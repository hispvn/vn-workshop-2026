"""DHIS2 credentials block.

This module defines a Prefect Block for storing DHIS2 connection details.
The actual API client comes from the ``dhis2-client`` package
(https://github.com/dhis2/dhis2-python-client).

The Block pattern is Prefect's equivalent of Airflow Connections:
define once, reuse across any flow.

Lifecycle:
    1. Register the block type:  ``make block-register``
    2. Save an instance:         ``make block-create``
    3. Load in a flow:           ``Dhis2Credentials.load("dhis2")``
"""

from __future__ import annotations

from dhis2_client import DHIS2Client
from prefect.blocks.core import Block
from pydantic import Field, SecretStr


class Dhis2Credentials(Block):
    """Credentials block for a DHIS2 instance.

    Stores connection details (URL, username, password) and returns an
    authenticated ``DHIS2Client`` via ``get_client()``.

    Default values point to the DHIS2 play server — a public demo instance.
    """

    # -- Block metadata (shown in the Prefect UI) --
    _block_type_name = "dhis2-credentials"
    _block_type_slug = "dhis2-credentials"
    _logo_url = "https://avatars.githubusercontent.com/u/1089987?s=200&v=4"  # type: ignore[assignment]
    _description = "Credentials block for connecting to a DHIS2 instance."

    # -- Fields --
    # These appear as form inputs in the Prefect UI when creating a block.
    base_url: str = Field(
        default="https://play.im.dhis2.org/dev",
        description="DHIS2 instance base URL",
    )
    username: str = Field(default="admin", description="DHIS2 username")
    password: SecretStr = Field(
        default=SecretStr("district"),
        description="DHIS2 password",
    )

    def get_client(self) -> DHIS2Client:
        """Return an authenticated ``DHIS2Client`` from the dhis2-client package."""
        return DHIS2Client(
            self.base_url,
            username=self.username,
            password=self.password.get_secret_value(),
        )
