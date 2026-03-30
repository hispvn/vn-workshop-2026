# Prefect Demo

A minimal Prefect 3 project to get started with workflow orchestration.

## Quick Start

```bash
make sync                # install dependencies
```

### 1. Run locally (no server needed)

```bash
make run
```

Executes the flow once in your local Python and exits. No Docker, no server. Good for testing flow logic.

### 2. Run with Docker Compose (full stack)

```bash
make start               # starts PostgreSQL + Prefect server + deployments
```

This brings up the server and three deployment containers. Each calls `flow.serve()` to register with the server and poll for runs.

To trigger a run:
1. Open <http://localhost:4200>
2. Go to **Deployments** — you'll see **basics**, **advanced**, and **dhis2-org-units**
3. Click **Quick run** on any deployment
4. Watch the run complete under **Flow runs**

To stop: `Ctrl+C` or `docker compose down`. To reset everything: `make restart`.

### 3. Run a deployment as a standalone Docker container

This shows that deployments don't have to live in the compose file. With the server running (from step 2), open another terminal:

```bash
make run-docker
```

This builds and runs the **parallel** deployment — a separate container that registers with the same Prefect server. You'll see it appear as an additional deployment in the UI.

## What is Prefect?

Prefect is a Python workflow orchestration framework. You write regular Python functions, decorate them with `@flow` and `@task`, and Prefect handles scheduling, retries, logging, and observability.

Unlike older orchestration tools, there is no DAG definition file or XML config. Your workflow **is** your Python code.

## Core Concepts

### Flows

A **flow** is the main unit of work. It is a Python function decorated with `@flow`. Flows track execution state, log output, and can be scheduled, retried, and monitored from the UI.

```python
from prefect import flow

@flow(log_prints=True)
def my_flow():
    print("Hello from Prefect!")
```

A flow can call other flows (subflows) for nested execution.

### Tasks

A **task** is a single step within a flow. Tasks are decorated with `@task` and provide retries, caching, concurrency controls, and individual observability.

```python
from prefect import task

@task
def extract() -> dict:
    return {"data": [1, 2, 3]}

@task
def transform(raw: dict) -> list:
    return [x * 2 for x in raw["data"]]
```

Tasks are called like normal functions inside a flow. Data passes between tasks as return values — no XCom or intermediate storage needed.

### Retries

Tasks and flows support automatic retries with backoff:

```python
@task(retries=3, retry_delay_seconds=10)
def flaky_api_call():
    ...
```

You can also use `retry_delay_seconds=[1, 5, 30]` for custom backoff, or `retry_condition_fn` to retry only on specific exceptions.

### Task Dependencies

By default tasks run **sequentially** in the order they are called. For parallel execution, use `.submit()` which returns a future:

```python
@flow
def my_flow():
    future_a = task_a.submit()
    future_b = task_b.submit()       # runs in parallel with task_a
    result = future_a.result()        # wait for result
```

For fan-out over a collection, use `.map()`:

```python
@flow
def process_all():
    results = transform.map([1, 2, 3, 4])  # one task run per item
```

### Deployments

A **deployment** packages a flow for remote execution. Deployments are what allow you to trigger flows from the UI, API, or on a schedule.

Two approaches:

- **`flow.serve()`** — simplest, runs in-process, good for development
- **`flow.deploy()`** — production-grade, sends runs to a work pool

Deployments can also be declared in `prefect.yaml`:

```yaml
deployments:
  - name: basics
    entrypoint: deployments/basics/flow.py:basics_flow
    work_pool:
      name: default
    schedules: []
```

Deploy with the CLI:

```bash
prefect deploy --all
```

### Work Pools and Workers

**Work pools** define *where* flow runs execute. Common types:

| Type | Use case |
|------|----------|
| `process` | Local subprocesses (development) |
| `docker` | Docker containers (team use) |
| `kubernetes` | K8s jobs (production) |

**Workers** are long-running processes that poll a work pool and execute scheduled runs:

```bash
prefect work-pool create default --type process
prefect worker start --pool default
```

### Schedules

Flows can be triggered on a schedule using cron, interval, or rrule syntax:

```python
flow.serve(name="daily-etl", cron="0 6 * * *")          # daily at 6am
flow.serve(name="frequent", interval=900)                 # every 15 minutes
```

Schedules can be changed after deployment without redeploying:

```bash
prefect deployment set-schedule my-flow/daily-etl --cron "0 8 * * *"
```

### Blocks

**Blocks** are typed, reusable configuration objects — the Prefect equivalent of Airflow Connections. They store credentials, API endpoints, webhooks, and other config that flows need at runtime.

Built-in blocks include `Secret`, `JSON`, and `Webhook`. You can also create custom blocks:

```python
from prefect.blocks.core import Block
from pydantic import SecretStr

class MyCredentials(Block):
    base_url: str
    username: str
    password: SecretStr
```

Blocks are saved to the server and loaded by name in any flow:

```python
creds = MyCredentials.load("production")
```

### Variables

**Variables** are simple key-value pairs stored in the Prefect server. Use them for non-sensitive configuration that you want to change without redeploying — feature flags, thresholds, environment names, etc.

```python
from prefect.variables import Variable

# Set a variable (or update via the UI)
Variable.set("org_unit_level", "3")

# Read it in a flow
level = Variable.get("org_unit_level", default="1")
```

Variables can be created and edited in the Prefect UI under **Variables**, or via the CLI:

```bash
prefect variable set org_unit_level 3
prefect variable get org_unit_level
```

Unlike Blocks, variables are plain strings — no typed fields or secrets. Use Blocks for credentials, variables for simple config.

### Artifacts

**Artifacts** publish rich content (markdown, tables, links) to the Prefect UI:

```python
from prefect.artifacts import create_markdown_artifact

create_markdown_artifact(
    key="summary",
    markdown="# Run Summary\nProcessed **42** records.",
)
```

Useful for reports, data quality summaries, and run documentation.

### Logging

Three ways to log:

```python
from prefect import get_run_logger

# 1. Structured logger (recommended)
logger = get_run_logger()
logger.info("Processing %d records", count)

# 2. Capture prints (set log_prints=True on the flow)
print("This shows up in Prefect logs")

# 3. Extra context fields
logger.info("done", extra={"user_id": user_id})
```

### Prefect UI

The web UI at <http://localhost:4200> shows:

- Flow runs and task runs with their states
- Logs with structured context
- Artifacts (markdown reports, tables)
- Deployment schedules and history
- Events and automations

## Project Structure

```
prefect-demo/
  Makefile                        # build and run targets
  compose.yml                     # Docker stack (PostgreSQL + server + deployments)
  pyproject.toml                  # Python dependencies
  packages/
    prefect-dhis2/                # DHIS2 credentials block (wraps dhis2-client)
  deployments/
    basics/                       # sequential tasks, parameters, logging
    parallel/                     # .submit() and .map() for concurrency
    advanced/                     # subflows, state hooks
    dhis2_org_units/              # blocks, retries, artifacts, schedule
```

## Make Targets

```
make help             Show this help
make sync             Install dependencies
make lint             Auto-format, fix lint errors, and type-check
make check            Check formatting, linting, and types (read-only)
make run              Run basics flow locally (no server needed)
make run-docker       Run parallel flow as standalone Docker container (needs server)
make start            Start Prefect stack with Docker (PostgreSQL + Server + deployments)
make restart          Tear down, rebuild, and start the Docker stack from scratch
make block-register   Register custom block types with Prefect server
make block-create     Create DHIS2 credentials block with default play-server values
make clean            Remove build artifacts and caches
```
