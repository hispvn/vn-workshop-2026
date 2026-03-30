"""Basic tests for climate_tools."""

from climate_tools.config import make_client


def test_make_client_returns_client():
    client = make_client()
    assert client is not None
