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
        timeout=300.0,
    )


def post_data_value_set_batched(
    client: DHIS2Client,
    payload: dict,
) -> dict:
    """Post dataValueSets in per-org-unit batches to avoid server timeouts."""
    data_values = payload["dataValues"]

    # Group by orgUnit
    by_org_unit: dict[str, list] = {}
    for dv in data_values:
        by_org_unit.setdefault(dv["orgUnit"], []).append(dv)

    if len(by_org_unit) <= 1:
        return client.post_data_value_set(payload)

    imported = updated = ignored = 0
    for i, (org_unit, values) in enumerate(by_org_unit.items(), 1):
        print(f"    Org unit {i}/{len(by_org_unit)} ({org_unit}): {len(values)} values...")
        result = client.post_data_value_set({"dataValues": values})
        counts = result.get("response", {}).get("importCount", {})
        imported += counts.get("imported", 0)
        updated += counts.get("updated", 0)
        ignored += counts.get("ignored", 0)

    return {"response": {"importCount": {"imported": imported, "updated": updated, "ignored": ignored}}}
