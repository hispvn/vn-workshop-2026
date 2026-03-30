"""DHIS2 utility helpers.

Provides a convenience function for loading DHIS2 credentials from
the Prefect server with a clear error message if the block is missing.
"""

from __future__ import annotations

from prefect_dhis2.credentials import Dhis2Credentials


def get_dhis2_credentials(name: str = "dhis2") -> Dhis2Credentials:
    """Load a DHIS2 credentials block from the Prefect server.

    Args:
        name: The block instance name (as saved with ``block.save(name)``).

    Returns:
        A ``Dhis2Credentials`` instance loaded from the server.

    Raises:
        ValueError: If the block does not exist. The error message includes
            the commands needed to create it.
    """
    try:
        return Dhis2Credentials.load(name)  # type: ignore[return-value]
    except Exception:
        msg = (
            f"DHIS2 credentials block '{name}' not found. "
            "Run these commands first:\n"
            "  make block-register\n"
            "  make block-create"
        )
        raise ValueError(msg) from None
