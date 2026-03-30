"""Shared fixtures for Playwright end-to-end tests.

Starts the FastAPI app on a free port before the test session and tears it
down afterwards.  Every test gets a ``base_url`` pointing at the running
server, and a fresh Playwright ``page`` via pytest-playwright.
"""

from __future__ import annotations

import socket
import time
from collections.abc import Generator
from multiprocessing import Process

import pytest
import uvicorn


def _free_port() -> int:
    with socket.socket() as s:
        s.bind(("127.0.0.1", 0))
        port: int = s.getsockname()[1]
        return port


def _run_server(port: int) -> None:
    uvicorn.run("dhis2_fhir.app:app", host="127.0.0.1", port=port, log_level="warning")


@pytest.fixture(scope="session")
def base_url() -> Generator[str, None, None]:
    port = _free_port()
    proc = Process(target=_run_server, args=(port,), daemon=True)
    proc.start()

    # Wait for server to be ready
    url = f"http://127.0.0.1:{port}"
    for _ in range(50):
        try:
            sock = socket.create_connection(("127.0.0.1", port), timeout=0.2)
            sock.close()
            break
        except OSError:
            time.sleep(0.1)
    else:
        proc.kill()
        raise RuntimeError("Server failed to start")

    yield url
    proc.kill()
    proc.join(timeout=3)
