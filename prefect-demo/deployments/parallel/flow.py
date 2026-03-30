"""Parallel — concurrent tasks with .submit() and .map().

Demonstrates:
- .submit(): run tasks concurrently, returning futures
- .result(): wait for a future and get its return value
- .map(): fan-out a task over a list of items (one task run per item)
- Parameters with list types

By default, tasks run sequentially. Use .submit() to run them in
parallel, and .map() to apply a task to every item in a collection.

Run with: make run-docker (requires the Prefect server to be running)
"""

import time

from dotenv import load_dotenv
from prefect import flow, task

# -- Tasks -------------------------------------------------------------------


@task
def process_item(item: str) -> str:
    """Simulate processing a single item (takes 1 second).

    Args:
        item: The item to process.

    Returns:
        A status message for this item.
    """
    print(f"Processing: {item}")
    time.sleep(1)  # Simulate real work (e.g. API call, file processing)
    result = f"{item} done"
    print(f"Finished: {result}")
    return result


@task
def summarise(results: list[str]) -> str:
    """Combine all results into a summary.

    Args:
        results: List of individual result strings.

    Returns:
        A combined summary string.
    """
    summary = f"Processed {len(results)} items: {', '.join(results)}"
    print(summary)
    return summary


# -- Flow --------------------------------------------------------------------


@flow(name="parallel", log_prints=True)
def parallel_flow(items: list[str] | None = None) -> str:
    """Process items in parallel using .submit() and .map().

    Args:
        items: List of items to process. Defaults to three example items.

    Returns:
        A summary of all processed items.
    """
    if items is None:
        items = ["alpha", "bravo", "charlie"]

    # -- .submit() -----------------------------------------------------------
    # submit() runs tasks concurrently and returns futures.
    # Use .result() to wait for the return value.
    # These two tasks run at the same time (~1 second total, not 2).
    print("--- Using .submit() for parallel execution ---")
    future_a = process_item.submit("parallel-1")
    future_b = process_item.submit("parallel-2")

    # .result() blocks until the task completes and returns its value
    result_a = future_a.result()
    result_b = future_b.result()
    print(f"submit() results: {result_a}, {result_b}")

    # -- .map() --------------------------------------------------------------
    # map() fans out a task over a list — one task run per item.
    # All items are processed concurrently.
    print("--- Using .map() for fan-out ---")
    futures = process_item.map(items)

    # Collect all results
    map_results = [f.result() for f in futures]

    return summarise(map_results)


# -- Deployment --------------------------------------------------------------

if __name__ == "__main__":
    load_dotenv()
    parallel_flow.serve(name="parallel")
