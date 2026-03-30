"""Hello DHIS2 — connect to DHIS2 and count organisation units.

Demonstrates:
- Blocks: credentials stored in the Prefect server, loaded at runtime
- Flow parameters: block_name has a default but can be changed in the UI
- Retries: tasks automatically retry on failure (e.g. network errors)
- Artifacts: publish a markdown summary to the Prefect UI
- Schedules: deployment runs on a cron schedule (configurable in UI)
- Pydantic models: typed data structures for task inputs/outputs
- cache_policy=NONE: skip caching for tasks with non-serializable inputs

Prerequisites:
    make block-register   # register the dhis2-credentials block type
    make block-create     # save a block instance with play-server defaults
"""

from __future__ import annotations

from dhis2_client import DHIS2Client
from dotenv import load_dotenv
from prefect import flow, task
from prefect.artifacts import create_markdown_artifact
from prefect.cache_policies import NONE
from prefect_dhis2 import get_dhis2_credentials
from pydantic import BaseModel

# -- Pydantic model ----------------------------------------------------------
# Using a Pydantic BaseModel gives us typed, validated data structures.
# Prefect natively supports Pydantic models as task inputs and outputs.


class OrgUnitSummary(BaseModel):
    """Summary of organisation units fetched from DHIS2."""

    server_url: str
    server_version: str
    total_org_units: int


# -- Tasks -------------------------------------------------------------------


@task
def connect_to_dhis2(block_name: str) -> DHIS2Client:
    """Load credentials from a Prefect Block and return an authenticated client.

    Blocks are typed configuration objects stored in the Prefect server.
    They keep credentials out of code and make them reusable across flows.
    The block_name parameter lets you switch between different DHIS2 instances
    (e.g. "dhis2-staging", "dhis2-prod") from the UI.
    """
    creds = get_dhis2_credentials(block_name)
    print(f"Connecting to {creds.base_url}")
    return creds.get_client()


# retries=3: if this task fails (e.g. network timeout), Prefect will
# automatically retry up to 3 times with a 5-second delay between attempts.
# cache_policy=NONE: the DHIS2Client input can't be serialized for caching,
# so we disable the cache for this task.
@task(retries=3, retry_delay_seconds=5, cache_policy=NONE)
def fetch_org_unit_count(client: DHIS2Client) -> int:
    """Fetch organisation units and return the total count."""
    # get_organisation_units returns an iterable of dicts (already unpacked)
    org_units = list(client.get_organisation_units(fields="id", paging="false"))
    count = len(org_units)
    print(f"Found {count} organisation units")
    return count


@task(retries=3, retry_delay_seconds=5, cache_policy=NONE)
def build_summary(client: DHIS2Client, org_unit_count: int) -> OrgUnitSummary:
    """Build a summary from server info and org unit count."""
    info = client.get_system_info()
    summary = OrgUnitSummary(
        server_url=info.get("contextPath", "unknown"),
        server_version=info.get("version", "unknown"),
        total_org_units=org_unit_count,
    )
    print(f"DHIS2 {summary.server_version} at {summary.server_url}")
    print(f"Total organisation units: {summary.total_org_units}")
    return summary


# -- Flow --------------------------------------------------------------------
# The flow orchestrates the tasks and accepts parameters that can be
# configured in the Prefect UI when triggering a run.


@flow(name="dhis2_org_units", log_prints=True)
def dhis2_org_units(block_name: str = "dhis2") -> OrgUnitSummary:
    """Connect to DHIS2 and report the number of organisation units.

    Args:
        block_name: Name of the Dhis2Credentials block saved in the server.
                    Defaults to "dhis2" (the play-server instance).
    """
    client = connect_to_dhis2(block_name)
    count = fetch_org_unit_count(client)
    summary = build_summary(client, count)

    # -- Artifact -------------------------------------------------------------
    # Artifacts publish rich content (markdown, tables, links) to the Prefect UI.
    # They persist across runs and are visible under the flow run's Artifacts tab.
    create_markdown_artifact(
        key="dhis2-org-unit-summary",
        markdown=(
            f"# DHIS2 Organisation Unit Summary\n\n"
            f"| Field | Value |\n"
            f"|-------|-------|\n"
            f"| Server | {summary.server_url} |\n"
            f"| Version | {summary.server_version} |\n"
            f"| Organisation Units | {summary.total_org_units} |"
        ),
    )

    return summary


# -- Deployment with schedule ------------------------------------------------
# flow.serve() registers the deployment and polls for runs.
# The cron parameter adds a schedule — this deployment will run daily at 6am.
# Schedules can be viewed and modified in the Prefect UI under Deployments.

if __name__ == "__main__":
    load_dotenv()
    dhis2_org_units.serve(
        name="dhis2-org-units",
        cron="0 6 * * *",  # Daily at 06:00 UTC
    )
