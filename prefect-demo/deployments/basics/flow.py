"""Basics — sequential tasks, parameters, and logging.

Demonstrates:
- @flow with parameters: the flow accepts typed inputs with defaults
- @task: individual units of work, tracked in the Prefect UI
- log_prints=True: captures print() output as Prefect log entries
- Sequential execution: tasks run in the order they are called
- Data passing: return values flow between tasks as normal Python

This is the simplest possible Prefect flow — a good starting point.
"""

import subprocess

from dotenv import load_dotenv
from prefect import flow, task

# -- Tasks -------------------------------------------------------------------
# A @task is a single step in a workflow. Each task is tracked individually
# in the Prefect UI with its own state (Pending, Running, Completed, Failed).


@task
def greet(name: str) -> str:
    """Build and print a personalised greeting.

    Args:
        name: The name to greet.

    Returns:
        The greeting string.
    """
    msg = f"Hello, {name}! Welcome to Prefect."
    print(msg)  # Captured as a log entry because the flow sets log_prints=True
    return msg


@task
def get_timestamp() -> str:
    """Run the 'date' command and return the current timestamp."""
    result = subprocess.run(["date"], capture_output=True, text=True, check=True)
    output = result.stdout.strip()
    print(f"Current time: {output}")
    return output


# -- Flow --------------------------------------------------------------------
# A @flow is the main entry point. It orchestrates tasks, tracks the overall
# run state, and can accept parameters that are configurable from the UI.


@flow(name="basics", log_prints=True)
def basics_flow(name: str = "World") -> str:
    """Greet someone and print the current time.

    Args:
        name: The name to greet. Defaults to "World".
              This parameter is visible and editable in the Prefect UI.

    Returns:
        The greeting message.
    """
    # Tasks are called like normal functions.
    # They run in the order they appear — no explicit dependency graph needed.
    greeting = greet(name)
    get_timestamp()
    return greeting


# -- Deployment --------------------------------------------------------------
# flow.serve() registers this flow as a deployment with the Prefect server
# and starts polling for runs. When a run is triggered (via UI or API),
# the flow executes inside this process.

if __name__ == "__main__":
    load_dotenv()
    basics_flow.serve(name="basics")
