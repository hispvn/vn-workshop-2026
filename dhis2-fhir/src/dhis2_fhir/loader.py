"""
Resource loader — reads SUSHI-generated JSON and user-created resources,
parses into Pydantic models.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from .models import (
    CodeSystem,
    Immunization,
    Observation,
    Patient,
    Questionnaire,
    QuestionnaireResponse,
    ValueSet,
)
from .store import load_user_resources

# Directories where SUSHI generates JSON
FSH_GENERATED = Path("ig/fsh-generated/resources")
IG_OUTPUT = Path("ig/output")


def _load_raw(prefix: str) -> list[dict[str, Any]]:
    """Load and deduplicate raw JSON dicts for a given resource type prefix."""
    resources: list[dict[str, Any]] = []
    for search_dir in [FSH_GENERATED, IG_OUTPUT]:
        if not search_dir.exists():
            continue
        for path in sorted(search_dir.glob(f"{prefix}-*.json")):
            try:
                resources.append(json.loads(path.read_text()))
            except (json.JSONDecodeError, KeyError):
                continue
    # Also include user-created resources
    resources.extend(load_user_resources(prefix))
    seen: set[str] = set()
    unique: list[dict[str, Any]] = []
    for r in resources:
        rid = r.get("id", "")
        if rid not in seen:
            seen.add(rid)
            unique.append(r)
    return unique


def load_patients() -> list[Patient]:
    return [Patient.model_validate(d) for d in _load_raw("Patient")]


def load_observations() -> list[Observation]:
    return [Observation.model_validate(d) for d in _load_raw("Observation")]


def load_questionnaires() -> list[Questionnaire]:
    return [
        Questionnaire.model_validate(d) for d in _load_raw("Questionnaire") if d.get("resourceType") == "Questionnaire"
    ]


def load_questionnaire_responses() -> list[QuestionnaireResponse]:
    return [QuestionnaireResponse.model_validate(d) for d in _load_raw("QuestionnaireResponse")]


def load_codesystems() -> dict[str, CodeSystem]:
    systems: dict[str, CodeSystem] = {}
    for d in _load_raw("CodeSystem"):
        cs = CodeSystem.model_validate(d)
        if cs.url:
            systems[cs.url] = cs
    return systems


def load_valuesets() -> dict[str, ValueSet]:
    vsets: dict[str, ValueSet] = {}
    for d in _load_raw("ValueSet"):
        vs = ValueSet.model_validate(d)
        if vs.url:
            vsets[vs.url] = vs
    return vsets


def load_immunizations() -> list[Immunization]:
    return [Immunization.model_validate(d) for d in _load_raw("Immunization")]


def load_bundles() -> list[dict[str, Any]]:
    """Load all Bundle resources as raw dicts."""
    return [d for d in _load_raw("Bundle") if d.get("resourceType") == "Bundle"]


def load_organizations() -> list[dict[str, Any]]:
    """Load all Organization resources as raw dicts."""
    return [d for d in _load_raw("Organization") if d.get("resourceType") == "Organization"]


def load_locations() -> list[dict[str, Any]]:
    """Load all Location resources as raw dicts."""
    return [d for d in _load_raw("Location") if d.get("resourceType") == "Location"]


def load_raw_json(resource_type: str, rid: str) -> dict[str, Any] | None:
    """Load a single resource's raw JSON by type and id."""
    from .store import load_user_resource

    pattern = f"{resource_type}-{rid}.json"
    for search_dir in [FSH_GENERATED, IG_OUTPUT]:
        if not search_dir.exists():
            continue
        path = search_dir / pattern
        if path.exists():
            result: dict[str, Any] = json.loads(path.read_text())
            return result
    # Check user-created resources
    return load_user_resource(resource_type, rid)
