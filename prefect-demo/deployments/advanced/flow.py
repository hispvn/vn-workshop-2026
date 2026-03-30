"""Advanced — subflows and state hooks.

Demonstrates:
- Subflows: a @flow that calls another @flow (nested execution)
- State hooks: on_failure callback for error handling
- Random failures: simulating unreliable tasks

Subflows are tracked as separate flow runs in the UI, nested under
the parent. State hooks let you react to flow/task lifecycle events
without wrapping everything in try/except.
"""

import random
from typing import Any

from dotenv import load_dotenv
from prefect import Flow, flow, task
from prefect.client.schemas.objects import FlowRun, State

# -- State hooks -------------------------------------------------------------
# Hooks are callbacks that fire when a flow or task enters a specific state.
# They receive (flow_or_task, run, state) and are useful for notifications,
# cleanup, or custom logging.


def on_flow_failure(flow_obj: Flow[..., Any], flow_run: FlowRun, state: State[Any]) -> None:
    """Called when the flow enters a Failed state.

    In production, you might send a Slack message or page on-call here.
    """
    print(f"HOOK: Flow '{flow_obj.name}' failed! State: {state.name}")
    print("HOOK: This is where you'd send an alert or do cleanup.")


# -- Tasks -------------------------------------------------------------------


@task
def safe_task() -> str:
    """A task that always succeeds."""
    msg = "Safe task completed successfully."
    print(msg)
    return msg


@task
def risky_task() -> str:
    """A task that fails ~50% of the time.

    This simulates unreliable operations like flaky APIs or network issues.
    Combined with the on_failure hook, this shows how Prefect handles errors.
    """
    if random.random() < 0.5:  # noqa: S311
        msg = "Risky task failed!"
        raise RuntimeError(msg)
    msg = "Risky task succeeded!"
    print(msg)
    return msg


# -- Subflow -----------------------------------------------------------------
# A subflow is just a @flow called from inside another @flow.
# It appears as a separate flow run in the UI, nested under the parent.
# This is useful for grouping related work or reusing flows.


@flow(name="greet_subflow", log_prints=True)
def greet_subflow(name: str = "Workshop") -> str:
    """A small subflow that prints a greeting.

    Args:
        name: The name to greet.

    Returns:
        The greeting string.
    """
    msg = f"Hello from the subflow, {name}!"
    print(msg)
    return msg


# -- Main flow ---------------------------------------------------------------


@flow(
    name="advanced",
    log_prints=True,
    on_failure=[on_flow_failure],  # type: ignore[list-item]  # Register the failure hook
)
def advanced_flow() -> str:
    """Demonstrate subflows and state hooks.

    This flow:
    1. Calls greet_subflow (a nested flow run)
    2. Runs a safe task
    3. Runs a risky task (may fail ~50% of the time)

    If the risky task fails, the on_failure hook fires.
    Run this multiple times to see both outcomes.
    """
    # Call the subflow — this creates a nested flow run in the UI
    greeting = greet_subflow("Prefect learner")

    # Run tasks
    safe_task()
    risky_task()  # This may fail — check the on_failure hook in the logs

    return greeting


# -- Deployment --------------------------------------------------------------

if __name__ == "__main__":
    load_dotenv()
    advanced_flow.serve(name="advanced")  # pyright: ignore[reportFunctionMemberAccess]
