"""
JSON file store for user-created FHIR resources.

Saves resources as individual JSON files in the `data/` directory, organized
by resource type. This keeps user-created data separate from SUSHI-generated
output while using the same FHIR JSON format.
"""

from __future__ import annotations

import json
import uuid
from pathlib import Path
from typing import Any

DATA_DIR = Path("data")


def _resource_dir(resource_type: str) -> Path:
    d = DATA_DIR / resource_type
    d.mkdir(parents=True, exist_ok=True)
    return d


def generate_id(prefix: str = "") -> str:
    """Generate a short unique ID for a new resource."""
    short = uuid.uuid4().hex[:8]
    return f"{prefix}{short}" if prefix else short


def save_resource(resource: dict[str, Any]) -> dict[str, Any]:
    """Save a FHIR resource dict to disk. Returns the saved resource."""
    rt = resource.get("resourceType", "Unknown")
    rid = resource.get("id", generate_id())
    resource["id"] = rid
    path = _resource_dir(rt) / f"{rt}-{rid}.json"
    path.write_text(json.dumps(resource, indent=2))
    return resource


def load_user_resources(resource_type: str) -> list[dict[str, Any]]:
    """Load all user-created resources of a given type."""
    d = DATA_DIR / resource_type
    if not d.exists():
        return []
    resources = []
    for path in sorted(d.glob(f"{resource_type}-*.json")):
        try:
            resources.append(json.loads(path.read_text()))
        except (json.JSONDecodeError, KeyError):
            continue
    return resources


def load_user_resource(resource_type: str, rid: str) -> dict[str, Any] | None:
    """Load a single user-created resource by type and id."""
    path = DATA_DIR / resource_type / f"{resource_type}-{rid}.json"
    if path.exists():
        result: dict[str, Any] = json.loads(path.read_text())
        return result
    return None


def delete_resource(resource_type: str, rid: str) -> bool:
    """Delete a user-created resource. Returns True if deleted."""
    path = DATA_DIR / resource_type / f"{resource_type}-{rid}.json"
    if path.exists():
        path.unlink()
        return True
    return False
