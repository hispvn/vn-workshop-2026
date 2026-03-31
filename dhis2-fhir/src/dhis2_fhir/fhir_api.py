"""
FHIR REST API router — provides standard FHIR endpoints for the CHR service.

Mounted at /fhir/, this router exposes Patient, Immunization, Questionnaire,
QuestionnaireResponse, and Bundle resources using proper FHIR REST conventions:
search via GET with query params, read by id, create via POST, and conditional
create via If-None-Exist header.
"""

from __future__ import annotations

import json
import random
import string
from datetime import date

from fastapi import APIRouter, Header, Request
from fastapi.responses import JSONResponse

from .loader import (
    load_bundles,
    load_codesystems,
    load_immunizations,
    load_patients,
    load_questionnaire_responses,
    load_questionnaires,
    load_raw_json,
    load_valuesets,
)
from .models import Patient
from .store import save_resource

fhir_router = APIRouter()

# FHIR JSON content type
FHIR_JSON = "application/fhir+json"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _fhir_json(data: dict, status_code: int = 200, headers: dict | None = None) -> JSONResponse:
    return JSONResponse(content=data, status_code=status_code, media_type=FHIR_JSON, headers=headers)


def _operation_outcome(severity: str, code: str, diagnostics: str, status_code: int = 400) -> JSONResponse:
    return _fhir_json(
        {
            "resourceType": "OperationOutcome",
            "issue": [{"severity": severity, "code": code, "diagnostics": diagnostics}],
        },
        status_code=status_code,
    )


def _patient_to_dict(p: Patient) -> dict:
    """Convert a Patient model back to a JSON-serializable dict."""
    raw = load_raw_json("Patient", p.id)
    if raw:
        return raw
    result: dict = json.loads(p.model_dump_json(exclude_none=True))
    return result


def _make_search_bundle(entries: list[dict], total: int, self_url: str) -> dict:
    bundle: dict = {
        "resourceType": "Bundle",
        "type": "searchset",
        "total": total,
        "link": [{"relation": "self", "url": self_url}],
        "entry": [],
    }
    for res in entries:
        rt = res.get("resourceType", "")
        rid = res.get("id", "")
        bundle["entry"].append(
            {
                "fullUrl": f"{rt}/{rid}",
                "resource": res,
            }
        )
    return bundle


def _generate_client_health_id(birth_date: str, gender: str) -> str:
    """Generate a CHR clientHealthId: DDMMYYYY-SexCode-NNNN."""
    parts = birth_date.split("-")
    if len(parts) == 3:
        dd, mm, yyyy = parts[2], parts[1], parts[0]
    else:
        dd, mm, yyyy = "01", "01", "2000"
    sex_code = "1" if gender == "male" else "2"
    seq = "".join(random.choices(string.digits, k=4))
    return f"{dd}{mm}{yyyy}-{sex_code}-{seq}"


def _digits_only(s: str) -> str:
    return "".join(c for c in s if c.isdigit())


def _match_patient_identifier(p: Patient, system: str, value: str) -> bool:
    """Check if patient has an identifier matching system|value."""
    for ident in p.identifier:
        if system and ident.system != system:
            continue
        if ident.value == value:
            return True
        if not system and value.lower() in ident.value.lower():
            return True
    return False


# ---------------------------------------------------------------------------
# GET /fhir/metadata — CapabilityStatement
# ---------------------------------------------------------------------------


@fhir_router.get("/metadata")
async def metadata() -> JSONResponse:
    raw = load_raw_json("CapabilityStatement", "CHRCapabilityStatement")
    if raw:
        return _fhir_json(raw)
    return _fhir_json(
        {
            "resourceType": "CapabilityStatement",
            "status": "active",
            "kind": "instance",
            "fhirVersion": "4.0.1",
            "format": ["json"],
            "rest": [
                {
                    "mode": "server",
                    "resource": [
                        {
                            "type": "Patient",
                            "interaction": [
                                {"code": "read"},
                                {"code": "search-type"},
                                {"code": "create"},
                                {"code": "update"},
                            ],
                        },
                        {
                            "type": "Immunization",
                            "interaction": [{"code": "read"}, {"code": "search-type"}, {"code": "create"}],
                        },
                    ],
                }
            ],
        }
    )


# ---------------------------------------------------------------------------
# GET /fhir/Patient — Search patients
# ---------------------------------------------------------------------------


@fhir_router.get("/Patient")
async def search_patients(
    request: Request,
    identifier: str = "",
    name: str = "",
    given: str = "",
    family: str = "",
    gender: str = "",
    birthdate: str = "",
    phone: str = "",
    address: str = "",
    address_city: str = "",
    address_state: str = "",
    _count: int = 20,
    _offset: int = 0,
) -> JSONResponse:
    # Normalize query param names (FHIR uses hyphens, FastAPI uses underscores)
    qp = dict(request.query_params)
    address_city = address_city or qp.get("address-city", "")
    address_state = address_state or qp.get("address-state", "")

    all_patients = load_patients()
    filtered = all_patients

    if identifier:
        parts = identifier.split("|", 1)
        if len(parts) == 2:
            sys, val = parts
            filtered = [p for p in filtered if _match_patient_identifier(p, sys, val)]
        else:
            val = parts[0]
            filtered = [p for p in filtered if _match_patient_identifier(p, "", val)]

    if name:
        q = name.lower()
        filtered = [p for p in filtered if any(q in n.display.lower() for n in p.name)]

    if given:
        q = given.lower()
        filtered = [p for p in filtered if any(q in g.lower() for n in p.name for g in n.given)]

    if family:
        q = family.lower()
        filtered = [p for p in filtered if any(q in n.family.lower() for n in p.name)]

    if gender:
        filtered = [p for p in filtered if p.gender == gender]

    if birthdate:
        filtered = [p for p in filtered if p.birthDate == birthdate]

    if phone:
        phone_digits = _digits_only(phone)
        filtered = [
            p for p in filtered if any(phone_digits in _digits_only(t.value) for t in p.telecom if t.system == "phone")
        ]

    if address:
        q = address.lower()
        filtered = [
            p
            for p in filtered
            if any(
                q in a.city.lower() or q in a.district.lower() or q in a.state.lower() or q in a.country.lower()
                for a in p.address
            )
        ]

    if address_city:
        q = address_city.lower()
        filtered = [p for p in filtered if any(q in a.city.lower() for a in p.address)]

    if address_state:
        q = address_state.lower()
        filtered = [p for p in filtered if any(q in a.state.lower() for a in p.address)]

    total = len(filtered)
    page = filtered[_offset : _offset + _count]
    entries = [_patient_to_dict(p) for p in page]

    self_url = str(request.url)
    return _fhir_json(_make_search_bundle(entries, total, self_url))


# ---------------------------------------------------------------------------
# GET /fhir/Patient/{pid} — Read patient
# ---------------------------------------------------------------------------


@fhir_router.get("/Patient/{pid}")
async def read_patient(pid: str) -> JSONResponse:
    raw = load_raw_json("Patient", pid)
    if not raw:
        return _operation_outcome("error", "not-found", f"Patient/{pid} not found", 404)
    return _fhir_json(raw)


# ---------------------------------------------------------------------------
# POST /fhir/Patient — Create (with conditional create)
# ---------------------------------------------------------------------------


@fhir_router.post("/Patient")
async def create_patient(
    request: Request,
    if_none_exist: str = Header(None, alias="If-None-Exist"),
) -> JSONResponse:
    body = await request.json()

    if if_none_exist:
        # Parse If-None-Exist as search params and find matches
        matches = _conditional_search(if_none_exist)
        if len(matches) == 1:
            return _fhir_json(_patient_to_dict(matches[0]), status_code=200)
        if len(matches) > 1:
            return _operation_outcome(
                "error",
                "conflict",
                f"Conditional create matched {len(matches)} resources",
                412,
            )

    # Ensure clientHealthId
    has_chr_id = False
    for ident in body.get("identifier", []):
        if ident.get("system") == "http://moh.gov.la/fhir/id/client-health-id":
            has_chr_id = True
            break

    if not has_chr_id:
        birth_date = body.get("birthDate", "2000-01-01")
        gender = body.get("gender", "unknown")
        chr_id = _generate_client_health_id(birth_date, gender)
        if "identifier" not in body:
            body["identifier"] = []
        body["identifier"].append(
            {
                "system": "http://moh.gov.la/fhir/id/client-health-id",
                "value": chr_id,
                "type": {
                    "coding": [
                        {
                            "system": "http://moh.gov.la/fhir/CodeSystem/identifier-type",
                            "code": "CHR",
                            "display": "Community Health Record ID",
                        }
                    ]
                },
            }
        )

    body["resourceType"] = "Patient"
    saved = save_resource(body)
    rid = saved.get("id", "")
    return _fhir_json(saved, status_code=201, headers={"Location": f"Patient/{rid}"})


def _conditional_search(params_str: str) -> list[Patient]:
    """Parse If-None-Exist search string and return matching patients."""
    all_patients = load_patients()
    filtered = all_patients

    for param in params_str.split("&"):
        if "=" not in param:
            continue
        key, val = param.split("=", 1)
        key = key.strip()
        val = val.strip()

        if key == "identifier":
            parts = val.split("|", 1)
            if len(parts) == 2:
                sys, v = parts
                filtered = [p for p in filtered if _match_patient_identifier(p, sys, v)]
            else:
                filtered = [p for p in filtered if _match_patient_identifier(p, "", val)]
        elif key == "given":
            q = val.lower()
            filtered = [p for p in filtered if any(q in g.lower() for n in p.name for g in n.given)]
        elif key == "family":
            q = val.lower()
            filtered = [p for p in filtered if any(q in n.family.lower() for n in p.name)]
        elif key == "gender":
            filtered = [p for p in filtered if p.gender == val]
        elif key == "birthdate":
            filtered = [p for p in filtered if p.birthDate == val]

    return filtered


# ---------------------------------------------------------------------------
# PUT /fhir/Patient/{pid} — Update patient
# ---------------------------------------------------------------------------


@fhir_router.put("/Patient/{pid}")
async def update_patient(request: Request, pid: str) -> JSONResponse:
    body = await request.json()
    body["resourceType"] = "Patient"
    body["id"] = pid
    saved = save_resource(body)
    return _fhir_json(saved, status_code=200)


# ---------------------------------------------------------------------------
# GET /fhir/Immunization — Search immunizations
# ---------------------------------------------------------------------------


@fhir_router.get("/Immunization")
async def search_immunizations(
    request: Request,
    patient: str = "",
    _count: int = 50,
    _offset: int = 0,
) -> JSONResponse:
    all_imm = load_immunizations()
    filtered = all_imm

    if patient:
        # Accept "Patient/xxx" or just "xxx"
        pid = patient.split("/")[-1] if "/" in patient else patient
        filtered = [i for i in filtered if i.patient_id == pid]

    total = len(filtered)
    page = filtered[_offset : _offset + _count]

    entries = []
    for imm in page:
        raw = load_raw_json("Immunization", imm.id)
        if raw:
            entries.append(raw)
        else:
            entries.append(json.loads(imm.model_dump_json(exclude_none=True)))

    self_url = str(request.url)
    return _fhir_json(_make_search_bundle(entries, total, self_url))


# ---------------------------------------------------------------------------
# GET /fhir/Immunization/{iid} — Read immunization
# ---------------------------------------------------------------------------


@fhir_router.get("/Immunization/{iid}")
async def read_immunization(iid: str) -> JSONResponse:
    raw = load_raw_json("Immunization", iid)
    if not raw:
        return _operation_outcome("error", "not-found", f"Immunization/{iid} not found", 404)
    return _fhir_json(raw)


# ---------------------------------------------------------------------------
# POST /fhir/Immunization — Create immunization
# ---------------------------------------------------------------------------


@fhir_router.post("/Immunization")
async def create_immunization(request: Request) -> JSONResponse:
    body = await request.json()
    body["resourceType"] = "Immunization"
    saved = save_resource(body)
    rid = saved.get("id", "")
    return _fhir_json(saved, status_code=201, headers={"Location": f"Immunization/{rid}"})


# ---------------------------------------------------------------------------
# GET /fhir/Questionnaire — Search questionnaires
# ---------------------------------------------------------------------------


@fhir_router.get("/Questionnaire")
async def search_questionnaires(
    request: Request,
    name: str = "",
    title: str = "",
    status: str = "",
    _count: int = 50,
    _offset: int = 0,
) -> JSONResponse:
    all_q = load_questionnaires()
    filtered = all_q

    if name:
        q = name.lower()
        filtered = [item for item in filtered if q in item.name.lower()]

    if title:
        q = title.lower()
        filtered = [item for item in filtered if q in item.display_title.lower()]

    if status:
        filtered = [item for item in filtered if item.status == status]

    total = len(filtered)
    page = filtered[_offset : _offset + _count]

    entries = []
    for item in page:
        raw = load_raw_json("Questionnaire", item.id)
        if raw:
            entries.append(raw)
        else:
            entries.append(json.loads(item.model_dump_json(exclude_none=True)))

    self_url = str(request.url)
    return _fhir_json(_make_search_bundle(entries, total, self_url))


# ---------------------------------------------------------------------------
# GET /fhir/Questionnaire/{qid} — Read questionnaire
# ---------------------------------------------------------------------------


@fhir_router.get("/Questionnaire/{qid}")
async def read_questionnaire(qid: str) -> JSONResponse:
    raw = load_raw_json("Questionnaire", qid)
    if not raw:
        return _operation_outcome("error", "not-found", f"Questionnaire/{qid} not found", 404)
    return _fhir_json(raw)


# ---------------------------------------------------------------------------
# GET /fhir/QuestionnaireResponse — Search responses
# ---------------------------------------------------------------------------


@fhir_router.get("/QuestionnaireResponse")
async def search_questionnaire_responses(
    request: Request,
    questionnaire: str = "",
    subject: str = "",
    status: str = "",
    _count: int = 50,
    _offset: int = 0,
) -> JSONResponse:
    all_qr = load_questionnaire_responses()
    filtered = all_qr

    if questionnaire:
        q = questionnaire.lower()
        filtered = [item for item in filtered if q in item.questionnaire.lower()]

    if subject:
        # Accept "Patient/xxx" or just "xxx"
        pid = subject.split("/")[-1] if "/" in subject else subject
        filtered = [item for item in filtered if item.subject and item.subject.reference.endswith(pid)]

    if status:
        filtered = [item for item in filtered if item.status == status]

    total = len(filtered)
    page = filtered[_offset : _offset + _count]

    entries = []
    for item in page:
        raw = load_raw_json("QuestionnaireResponse", item.id)
        if raw:
            entries.append(raw)
        else:
            entries.append(json.loads(item.model_dump_json(exclude_none=True)))

    self_url = str(request.url)
    return _fhir_json(_make_search_bundle(entries, total, self_url))


# ---------------------------------------------------------------------------
# GET /fhir/QuestionnaireResponse/{rid} — Read response
# ---------------------------------------------------------------------------


@fhir_router.get("/QuestionnaireResponse/{rid}")
async def read_questionnaire_response(rid: str) -> JSONResponse:
    raw = load_raw_json("QuestionnaireResponse", rid)
    if not raw:
        return _operation_outcome("error", "not-found", f"QuestionnaireResponse/{rid} not found", 404)
    return _fhir_json(raw)


# ---------------------------------------------------------------------------
# GET /fhir/Bundle — Search bundles
# ---------------------------------------------------------------------------


@fhir_router.get("/Bundle")
async def search_bundles(
    request: Request,
    type: str = "",
    _count: int = 50,
    _offset: int = 0,
) -> JSONResponse:
    all_bundles = load_bundles()
    filtered = all_bundles

    if type:
        filtered = [b for b in filtered if b.get("type") == type]

    total = len(filtered)
    page = filtered[_offset : _offset + _count]

    self_url = str(request.url)
    return _fhir_json(_make_search_bundle(page, total, self_url))


# ---------------------------------------------------------------------------
# GET /fhir/Bundle/{bid} — Read bundle
# ---------------------------------------------------------------------------


@fhir_router.get("/Bundle/{bid}")
async def read_bundle(bid: str) -> JSONResponse:
    raw = load_raw_json("Bundle", bid)
    if not raw:
        return _operation_outcome("error", "not-found", f"Bundle/{bid} not found", 404)
    return _fhir_json(raw)


# ---------------------------------------------------------------------------
# GET /fhir/ValueSet — Search ValueSets
# ---------------------------------------------------------------------------


@fhir_router.get("/ValueSet")
async def search_valuesets(
    request: Request,
    name: str = "",
    url: str = "",
    _count: int = 50,
    _offset: int = 0,
) -> JSONResponse:
    all_vs = load_valuesets()
    filtered = list(all_vs.values())

    if name:
        q = name.lower()
        filtered = [vs for vs in filtered if q in vs.name.lower()]

    if url:
        filtered = [vs for vs in filtered if vs.url == url]

    total = len(filtered)
    page = filtered[_offset : _offset + _count]

    entries = []
    for vs in page:
        raw = load_raw_json("ValueSet", vs.id)
        if raw:
            entries.append(raw)
        else:
            entries.append(json.loads(vs.model_dump_json(exclude_none=True)))

    self_url = str(request.url)
    return _fhir_json(_make_search_bundle(entries, total, self_url))


# ---------------------------------------------------------------------------
# GET /fhir/ValueSet/$expand — Expand ValueSet
# ---------------------------------------------------------------------------


@fhir_router.get("/ValueSet/$expand")
async def expand_valueset(
    request: Request,
    url: str = "",
) -> JSONResponse:
    all_vs = load_valuesets()
    vs = all_vs.get(url)
    if not vs:
        return _operation_outcome("error", "not-found", f"ValueSet with url={url} not found", 404)

    codesystems = load_codesystems()
    contains: list[dict] = []

    if vs.compose:
        for include in vs.compose.include:
            system_url = include.system
            if include.concept:
                # Explicit concepts listed in the include
                for concept in include.concept:
                    contains.append({"system": system_url, "code": concept.code, "display": concept.display})
            elif system_url in codesystems:
                # Include all concepts from the referenced CodeSystem
                cs = codesystems[system_url]
                for concept in cs.concept:
                    contains.append({"system": system_url, "code": concept.code, "display": concept.display})

    expanded: dict = {
        "resourceType": "ValueSet",
        "id": vs.id,
        "url": vs.url,
        "name": vs.name,
        "status": "active",
        "expansion": {
            "timestamp": date.today().isoformat(),
            "contains": contains,
        },
    }
    return _fhir_json(expanded)


# ---------------------------------------------------------------------------
# GET /fhir/ValueSet/{vid} — Read ValueSet
# ---------------------------------------------------------------------------


@fhir_router.get("/ValueSet/{vid}")
async def read_valueset(vid: str) -> JSONResponse:
    raw = load_raw_json("ValueSet", vid)
    if not raw:
        return _operation_outcome("error", "not-found", f"ValueSet/{vid} not found", 404)
    return _fhir_json(raw)


# ---------------------------------------------------------------------------
# GET /fhir/CodeSystem — Search CodeSystems
# ---------------------------------------------------------------------------


@fhir_router.get("/CodeSystem")
async def search_codesystems(
    request: Request,
    name: str = "",
    url: str = "",
    _count: int = 50,
    _offset: int = 0,
) -> JSONResponse:
    all_cs = load_codesystems()
    filtered = list(all_cs.values())

    if name:
        q = name.lower()
        filtered = [cs for cs in filtered if q in cs.name.lower()]

    if url:
        filtered = [cs for cs in filtered if cs.url == url]

    total = len(filtered)
    page = filtered[_offset : _offset + _count]

    entries = []
    for cs in page:
        raw = load_raw_json("CodeSystem", cs.id)
        if raw:
            entries.append(raw)
        else:
            entries.append(json.loads(cs.model_dump_json(exclude_none=True)))

    self_url = str(request.url)
    return _fhir_json(_make_search_bundle(entries, total, self_url))


# ---------------------------------------------------------------------------
# GET /fhir/CodeSystem/{csid} — Read CodeSystem
# ---------------------------------------------------------------------------


@fhir_router.get("/CodeSystem/{csid}")
async def read_codesystem(csid: str) -> JSONResponse:
    raw = load_raw_json("CodeSystem", csid)
    if not raw:
        return _operation_outcome("error", "not-found", f"CodeSystem/{csid} not found", 404)
    return _fhir_json(raw)
