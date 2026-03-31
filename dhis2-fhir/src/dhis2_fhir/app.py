"""
DHIS2-FHIR Resource Renderer — FastAPI application.

Reads FHIR JSON from SUSHI-generated output and user-created data,
renders Patients as profile cards, Questionnaires as interactive forms,
and supports creating/editing Patients and Observations.
"""

from __future__ import annotations

import json
import re
from datetime import date
from pathlib import Path

from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse, Response
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from .fhir_api import fhir_router
from .loader import (
    load_bundles,
    load_codesystems,
    load_immunizations,
    load_observations,
    load_patients,
    load_questionnaire_responses,
    load_questionnaires,
    load_raw_json,
    load_valuesets,
)
from .models import CodeSystem, QuestionnaireItem, ValueSet
from .store import delete_resource, generate_id, load_user_resource, save_resource

app = FastAPI(title="DHIS2-FHIR Resource Renderer")

# Mount FHIR REST API router
app.include_router(fhir_router, prefix="/fhir")

# Resolve template/static dirs relative to project root (cwd)
_PROJECT_ROOT = Path.cwd()
templates = Jinja2Templates(directory=str(_PROJECT_ROOT / "templates"))
app.mount("/static", StaticFiles(directory=str(_PROJECT_ROOT / "static")), name="static")


def _humanize_camel(value: str) -> str:
    """Insert spaces before uppercase letters in camelCase/PascalCase strings."""
    return re.sub(r"([a-z])([A-Z])", r"\1 \2", value)


templates.env.filters["humanize_camel"] = _humanize_camel


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def resolve_answer_options(
    item: QuestionnaireItem,
    valuesets: dict[str, ValueSet],
    codesystems: dict[str, CodeSystem],
) -> list[dict[str, str]]:
    """Resolve answer options for a Questionnaire item."""
    options: list[dict[str, str]] = []

    for opt in item.answerOption:
        if opt.valueCoding:
            options.append({"code": opt.valueCoding.code, "display": opt.valueCoding.display})
        if opt.valueString:
            options.append({"code": opt.valueString, "display": opt.valueString})

    if item.answerValueSet and not options:
        vs = valuesets.get(item.answerValueSet)
        if vs and vs.compose:
            for include in vs.compose.include:
                for concept in include.concept:
                    options.append({"code": concept.code, "display": concept.display})
                if not include.concept and include.system in codesystems:
                    cs = codesystems[include.system]
                    for concept in cs.concept:
                        options.append({"code": concept.code, "display": concept.display})

    return options


def _is_user_resource(resource_type: str, rid: str) -> bool:
    """Check if a resource is user-created (editable)."""
    return load_user_resource(resource_type, rid) is not None


def _extract_identifiers(patient_data: dict | None) -> dict[str, str]:
    """Extract identifier values by type code from raw patient JSON."""
    result: dict[str, str] = {}
    if not patient_data:
        return result
    for ident in patient_data.get("identifier", []):
        type_obj = ident.get("type", {})
        for coding in type_obj.get("coding", []):
            result[coding.get("code", "")] = ident.get("value", "")
    return result


OBSERVATION_CATEGORIES = [
    ("vital-signs", "Vital Signs"),
    ("laboratory", "Laboratory"),
    ("exam", "Exam"),
    ("social-history", "Social History"),
]

COMMON_OBSERVATIONS = [
    {
        "code": "29463-7",
        "display": "Body weight",
        "system": "http://loinc.org",
        "unit": "kg",
        "ucum": "kg",
        "category": "vital-signs",
    },
    {
        "code": "8302-2",
        "display": "Body height",
        "system": "http://loinc.org",
        "unit": "cm",
        "ucum": "cm",
        "category": "vital-signs",
    },
    {
        "code": "8867-4",
        "display": "Heart rate",
        "system": "http://loinc.org",
        "unit": "beats/min",
        "ucum": "/min",
        "category": "vital-signs",
    },
    {
        "code": "8310-5",
        "display": "Body temperature",
        "system": "http://loinc.org",
        "unit": "Cel",
        "ucum": "Cel",
        "category": "vital-signs",
    },
    {
        "code": "85354-9",
        "display": "Blood pressure systolic",
        "system": "http://loinc.org",
        "unit": "mmHg",
        "ucum": "mm[Hg]",
        "category": "vital-signs",
    },
    {
        "code": "718-7",
        "display": "Hemoglobin",
        "system": "http://loinc.org",
        "unit": "g/dL",
        "ucum": "g/dL",
        "category": "laboratory",
    },
    {
        "code": "70218-5",
        "display": "Malaria RDT",
        "system": "http://loinc.org",
        "unit": "",
        "ucum": "",
        "category": "laboratory",
    },
    {
        "code": "75622-1",
        "display": "HIV test",
        "system": "http://loinc.org",
        "unit": "",
        "ucum": "",
        "category": "laboratory",
    },
]


# ---------------------------------------------------------------------------
# Routes — Home and Search
# ---------------------------------------------------------------------------


@app.get("/", response_class=HTMLResponse)
async def index(request: Request) -> Response:
    """List all Patients, Questionnaires, and QuestionnaireResponses."""
    bundles = load_bundles()
    ips_count = sum(1 for b in bundles if b.get("type") == "document")
    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "patients": load_patients(),
            "questionnaires": load_questionnaires(),
            "responses": load_questionnaire_responses(),
            "ips_count": ips_count,
            "is_user_resource": _is_user_resource,
        },
    )


def _digits_only(s: str) -> str:
    """Strip non-digit characters for phone comparison."""
    return "".join(c for c in s if c.isdigit())


# Mapping from identifier type codes to FHIR system URIs
_ID_TYPE_SYSTEMS: dict[str, str] = {
    "RI": "http://dhis2.org/fhir/id/tracked-entity",
    "NI": "http://example.org/national-id",
    "CHR": "http://moh.gov.la/fhir/id/chr",
    "CVID": "http://moh.gov.la/fhir/id/cvid",
    "INS": "http://moh.gov.la/fhir/id/insurance",
    "GREENCARD": "http://moh.gov.la/fhir/id/green-national-id",
    "PPN": "http://example.org/passport",
    "FAMILYBOOK": "http://moh.gov.la/fhir/id/family-book",
}


def _build_fhir_search_url(
    search_mode: str,
    q: str,
    gender: str,
    country: str,
    id_type: str,
    id_value: str,
    firstname: str,
    lastname: str,
    dob: str,
    sex: str,
    district: str,
    phone: str,
) -> str:
    """Build the equivalent FHIR REST search URL for the current query."""
    base = "GET [base]/Patient"
    params: list[str] = []

    if search_mode == "identifier":
        if id_type and id_value:
            system = _ID_TYPE_SYSTEMS.get(id_type, "")
            params.append(f"identifier={system}|{id_value}")
    elif search_mode == "attributes":
        if firstname:
            params.append(f"given={firstname}")
        if lastname:
            params.append(f"family={lastname}")
        if dob:
            params.append(f"birthdate={dob}")
        if sex:
            params.append(f"gender={sex}")
        if district:
            params.append(f"address={district}")
        if phone:
            params.append(f"phone={phone}")
    else:
        if q:
            params.append(f"name={q}")
        if gender:
            params.append(f"gender={gender}")
        if country:
            params.append(f"address-country={country}")

    if not params:
        return ""
    return base + "?" + "&".join(params)


@app.get("/patients", response_class=HTMLResponse)
async def patient_list(
    request: Request,
    q: str = "",
    gender: str = "",
    country: str = "",
    page: int = 1,
    per_page: int = 20,
    search_mode: str = "",
    id_type: str = "",
    id_value: str = "",
    firstname: str = "",
    lastname: str = "",
    dob: str = "",
    sex: str = "",
    district: str = "",
    phone: str = "",
) -> Response:
    """Search and browse patients with filtering and pagination."""
    all_patients = load_patients()

    # Collect unique countries and districts for filter dropdowns
    countries: set[str] = set()
    districts: set[str] = set()
    for p in all_patients:
        for addr in p.address:
            if addr.country:
                countries.add(addr.country)
            if addr.district:
                districts.add(addr.district)

    # Apply filters based on search mode
    filtered = all_patients

    if search_mode == "identifier":
        # Identifier search: exact or prefix match on a specific identifier type
        if id_type and id_value:
            val = id_value.strip().lower()
            filtered = [p for p in filtered if p.identifier_by_type(id_type).lower().startswith(val)]
        else:
            filtered = []

    elif search_mode == "attributes":
        # Attribute combo search: AND logic across all provided fields
        if firstname:
            fn = firstname.strip().lower()
            filtered = [p for p in filtered if any(fn in g.lower() for n in p.name for g in n.given)]
        if lastname:
            ln = lastname.strip().lower()
            filtered = [p for p in filtered if any(ln in n.family.lower() for n in p.name)]
        if dob:
            filtered = [p for p in filtered if p.birthDate == dob]
        if sex:
            filtered = [p for p in filtered if p.gender == sex]
        if district:
            filtered = [p for p in filtered if any(addr.district == district for addr in p.address)]
        if phone:
            phone_digits = _digits_only(phone)
            filtered = [
                p
                for p in filtered
                if any(phone_digits in _digits_only(t.value) for t in p.telecom if t.system == "phone")
            ]
        # If no attribute fields provided, show nothing
        if not any([firstname, lastname, dob, sex, district, phone]):
            filtered = []

    else:
        # Simple mode (default): substring search across name/uid/id/address
        query = q.strip().lower()
        if query:
            filtered = [
                p
                for p in filtered
                if query in p.display_name.lower()
                or query in p.dhis2_uid.lower()
                or query in p.national_id.lower()
                or query in p.id.lower()
                or any(
                    query in addr.city.lower() or query in addr.country.lower() or query in addr.district.lower()
                    for addr in p.address
                )
            ]
        if gender:
            filtered = [p for p in filtered if p.gender == gender]
        if country:
            filtered = [p for p in filtered if any(addr.country == country for addr in p.address)]

    # Paginate
    total = len(filtered)
    total_pages = max(1, (total + per_page - 1) // per_page)
    page = max(1, min(page, total_pages))
    start = (page - 1) * per_page
    page_patients = filtered[start : start + per_page]

    fhir_url = _build_fhir_search_url(
        search_mode,
        q,
        gender,
        country,
        id_type,
        id_value,
        firstname,
        lastname,
        dob,
        sex,
        district,
        phone,
    )

    return templates.TemplateResponse(
        "patient_list.html",
        {
            "request": request,
            "patients": page_patients,
            "total": total,
            "page": page,
            "per_page": per_page,
            "total_pages": total_pages,
            "query": q,
            "gender": gender,
            "country": country,
            "countries": sorted(countries),
            "districts": sorted(districts),
            "search_mode": search_mode,
            "id_type": id_type,
            "id_value": id_value,
            "firstname": firstname,
            "lastname": lastname,
            "dob": dob,
            "sex": sex,
            "district": district,
            "phone": phone,
            "fhir_search_url": fhir_url,
            "is_user_resource": _is_user_resource,
        },
    )


# ---------------------------------------------------------------------------
# Routes — Patient (specific paths BEFORE {pid} catch-all)
# ---------------------------------------------------------------------------


@app.get("/patient/new/create", response_class=HTMLResponse)
async def patient_create_form(request: Request) -> Response:
    """Show form for creating a new Patient."""
    return templates.TemplateResponse(
        "patient_form.html",
        {
            "request": request,
            "patient": None,
            "identifiers": {},
            "mode": "create",
        },
    )


@app.post("/patient/save")
async def patient_save(
    request: Request,
    patient_id: str = Form(""),
    given_name: str = Form(""),
    family_name: str = Form(""),
    gender: str = Form(""),
    birth_date: str = Form(""),
    active: str = Form("true"),
    dhis2_uid: str = Form(""),
    national_id: str = Form(""),
    address_city: str = Form(""),
    address_country: str = Form(""),
) -> RedirectResponse:
    """Create or update a Patient."""
    rid = patient_id or generate_id("patient-")

    identifiers = []
    if dhis2_uid:
        identifiers.append(
            {
                "system": "http://dhis2.org/fhir/id/tracked-entity",
                "value": dhis2_uid,
                "type": {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                            "code": "RI",
                            "display": "Resource identifier",
                        }
                    ]
                },
            }
        )
    if national_id:
        identifiers.append(
            {
                "system": "http://example.org/national-id",
                "value": national_id,
                "type": {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                            "code": "NI",
                            "display": "National identifier",
                        }
                    ]
                },
            }
        )

    resource: dict = {
        "resourceType": "Patient",
        "id": rid,
        "meta": {
            "profile": ["http://dhis2.org/fhir/learning/StructureDefinition/dhis2-patient"],
        },
        "identifier": identifiers,
        "name": [
            {
                "use": "official",
                "family": family_name,
                "given": [g.strip() for g in given_name.split() if g.strip()],
            }
        ],
        "gender": gender,
        "birthDate": birth_date,
        "active": active == "true",
    }

    if address_city or address_country:
        resource["address"] = [
            {
                "use": "home",
                "city": address_city,
                "country": address_country,
            }
        ]

    save_resource(resource)
    return RedirectResponse(url=f"/patient/{rid}", status_code=303)


@app.get("/patient/{pid}/edit", response_class=HTMLResponse)
async def patient_edit_form(request: Request, pid: str) -> Response:
    """Show form for editing an existing user-created Patient."""
    data = load_user_resource("Patient", pid)
    if not data:
        return HTMLResponse(
            f"<h1>Patient '{pid}' is not editable (SUSHI-generated resources are read-only)</h1>",
            status_code=403,
        )
    return templates.TemplateResponse(
        "patient_form.html",
        {
            "request": request,
            "patient": data,
            "identifiers": _extract_identifiers(data),
            "mode": "edit",
        },
    )


@app.post("/patient/{pid}/delete")
async def patient_delete(pid: str) -> RedirectResponse:
    """Delete a user-created Patient and its observations."""
    delete_resource("Patient", pid)
    from .store import load_user_resources

    for obs_data in load_user_resources("Observation"):
        subject = obs_data.get("subject", {})
        ref = subject.get("reference", "") if isinstance(subject, dict) else ""
        if ref.endswith(pid):
            delete_resource("Observation", obs_data.get("id", ""))
    return RedirectResponse(url="/", status_code=303)


@app.get("/patient/{pid}/observation/new", response_class=HTMLResponse)
async def observation_create_form(request: Request, pid: str) -> Response:
    """Show form for adding an observation to a patient."""
    patients = load_patients()
    patient = next((p for p in patients if p.id == pid), None)
    if not patient:
        return HTMLResponse(f"<h1>Patient '{pid}' not found</h1>", status_code=404)

    return templates.TemplateResponse(
        "observation_form.html",
        {
            "request": request,
            "patient": patient,
            "observation": None,
            "mode": "create",
            "categories": OBSERVATION_CATEGORIES,
            "common_observations": COMMON_OBSERVATIONS,
            "today": date.today().isoformat(),
        },
    )


@app.get("/patient/{pid}", response_class=HTMLResponse)
async def render_patient(request: Request, pid: str) -> Response:
    """Render a Patient profile card."""
    patients = load_patients()
    patient = next((p for p in patients if p.id == pid), None)
    if not patient:
        return HTMLResponse(f"<h1>Patient '{pid}' not found</h1>", status_code=404)

    all_responses = load_questionnaire_responses()
    patient_responses = [r for r in all_responses if r.subject and r.subject.reference.endswith(pid)]

    all_observations = load_observations()
    patient_observations = [o for o in all_observations if o.subject and o.subject.reference.endswith(pid)]

    return templates.TemplateResponse(
        "patient.html",
        {
            "request": request,
            "patient": patient,
            "responses": patient_responses,
            "observations": patient_observations,
            "editable": _is_user_resource("Patient", pid),
            "is_user_resource": _is_user_resource,
        },
    )


# ---------------------------------------------------------------------------
# Routes — Forms (Questionnaires & Responses)
# ---------------------------------------------------------------------------


@app.get("/forms", response_class=HTMLResponse)
async def forms_list(request: Request) -> Response:
    """List all questionnaires and responses."""
    all_responses = load_questionnaire_responses()

    patient_id = request.query_params.get("patient")
    selected_patient = None
    if patient_id:
        patients = load_patients()
        selected_patient = next((p for p in patients if p.id == patient_id), None)
        responses = [r for r in all_responses if r.subject and r.subject.reference.endswith(patient_id)]
    else:
        responses = all_responses

    return templates.TemplateResponse(
        "forms_list.html",
        {
            "request": request,
            "questionnaires": load_questionnaires(),
            "responses": responses,
            "selected_patient": selected_patient,
        },
    )


@app.get("/patient/{pid}/form/{qid}", response_class=HTMLResponse)
async def fill_form_for_patient(request: Request, pid: str, qid: str) -> Response:
    """Fill a questionnaire for a specific patient."""
    patients = load_patients()
    patient = next((p for p in patients if p.id == pid), None)
    if not patient:
        return HTMLResponse(f"<h1>Patient '{pid}' not found</h1>", status_code=404)
    questionnaires = load_questionnaires()
    q = next((q for q in questionnaires if q.id == qid), None)
    if not q:
        return HTMLResponse(f"<h1>Questionnaire '{qid}' not found</h1>", status_code=404)
    valuesets = load_valuesets()
    codesystems = load_codesystems()
    return templates.TemplateResponse(
        "questionnaire.html",
        {
            "request": request,
            "q": q,
            "valuesets": valuesets,
            "codesystems": codesystems,
            "resolve_options": resolve_answer_options,
            "answers": {},
            "response": None,
            "patient": patient,
            "today": date.today().isoformat(),
        },
    )


@app.get("/form/{qid}", response_class=HTMLResponse)
async def fill_form_anonymous(request: Request, qid: str) -> Response:
    """Fill a questionnaire without a patient (anonymous/event program)."""
    questionnaires = load_questionnaires()
    q = next((q for q in questionnaires if q.id == qid), None)
    if not q:
        return HTMLResponse(f"<h1>Questionnaire '{qid}' not found</h1>", status_code=404)
    valuesets = load_valuesets()
    codesystems = load_codesystems()
    return templates.TemplateResponse(
        "questionnaire.html",
        {
            "request": request,
            "q": q,
            "valuesets": valuesets,
            "codesystems": codesystems,
            "resolve_options": resolve_answer_options,
            "answers": {},
            "response": None,
            "anonymous": True,
            "today": date.today().isoformat(),
        },
    )


@app.post("/form/save")
async def save_form(request: Request) -> RedirectResponse:
    """Save a submitted QuestionnaireResponse."""
    form = await request.form()
    patient_id = form.get("patient_id", "")
    questionnaire_url = form.get("questionnaire_url", "")

    # Build QR items from form fields (linkId -> value)
    items: list[dict] = []
    for key, value in form.multi_items():
        if key.startswith("answer_") and value:
            link_id = key[7:]  # strip "answer_" prefix
            text = str(form.get(f"text_{link_id}", link_id))
            answer_type = str(form.get(f"type_{link_id}", "string"))
            answer: dict = {}
            if answer_type in ("choice", "coding"):
                # value is "system|code|display" or just "code"
                parts = str(value).split("|", 2)
                if len(parts) == 3:
                    answer["valueCoding"] = {"system": parts[0], "code": parts[1], "display": parts[2]}
                else:
                    answer["valueCoding"] = {"code": str(value)}
            elif answer_type == "boolean":
                answer["valueBoolean"] = str(value).lower() in ("true", "on", "1")
            elif answer_type == "integer":
                answer["valueInteger"] = int(str(value))
            elif answer_type == "decimal":
                answer["valueDecimal"] = float(str(value))
            elif answer_type in ("date", "dateTime"):
                answer["valueDate" if answer_type == "date" else "valueDateTime"] = str(value)
            else:
                answer["valueString"] = str(value)
            items.append({"linkId": link_id, "text": text, "answer": [answer]})

    rid = generate_id("qr-")
    resource: dict = {
        "resourceType": "QuestionnaireResponse",
        "id": rid,
        "questionnaire": questionnaire_url,
        "status": "completed",
        "authored": date.today().isoformat(),
        "item": items,
    }
    if patient_id:
        resource["subject"] = {"reference": f"Patient/{patient_id}"}

    save_resource(resource)

    if patient_id:
        return RedirectResponse(url=f"/patient/{patient_id}", status_code=303)
    return RedirectResponse(url=f"/response/{rid}", status_code=303)


@app.get("/questionnaire/{qid}", response_class=HTMLResponse)
async def render_questionnaire(request: Request, qid: str) -> Response:
    """Render a Questionnaire as an HTML form."""
    questionnaires = load_questionnaires()
    q = next((q for q in questionnaires if q.id == qid), None)
    if not q:
        return HTMLResponse(f"<h1>Questionnaire '{qid}' not found</h1>", status_code=404)

    valuesets = load_valuesets()
    codesystems = load_codesystems()

    all_responses = load_questionnaire_responses()
    q_slug = q.url.rstrip("/").split("/")[-1] if q.url else ""
    related_responses = [
        r
        for r in all_responses
        if r.questionnaire == q.url or (q_slug and r.questionnaire.rstrip("/").split("/")[-1] == q_slug)
    ]

    return templates.TemplateResponse(
        "questionnaire.html",
        {
            "request": request,
            "q": q,
            "valuesets": valuesets,
            "codesystems": codesystems,
            "resolve_options": resolve_answer_options,
            "answers": {},
            "response": None,
            "related_responses": related_responses,
            "today": date.today().isoformat(),
        },
    )


@app.get("/response/{rid}", response_class=HTMLResponse)
async def render_response(request: Request, rid: str) -> Response:
    """Render a QuestionnaireResponse as a pre-filled form."""
    responses = load_questionnaire_responses()
    qr = next((r for r in responses if r.id == rid), None)
    if not qr:
        return HTMLResponse(f"<h1>QuestionnaireResponse '{rid}' not found</h1>", status_code=404)

    questionnaires = load_questionnaires()
    q = None

    # 1. Exact URL match first
    for candidate in questionnaires:
        if candidate.url and candidate.url == qr.questionnaire:
            q = candidate
            break

    # 2. Match by last URL segment (exact segment match, not substring)
    qr_slug = qr.questionnaire.rstrip("/").split("/")[-1]
    if not q:
        for candidate in questionnaires:
            if candidate.url:
                candidate_slug = candidate.url.rstrip("/").split("/")[-1]
                if candidate_slug == qr_slug:
                    q = candidate
                    break

    # 3. Fallback: match by id
    if not q:
        q = next((c for c in questionnaires if c.id == qr_slug), None)

    if not q:
        return HTMLResponse(
            f"<h1>Matching Questionnaire for '{qr.questionnaire}' not found</h1>",
            status_code=404,
        )

    valuesets = load_valuesets()
    codesystems = load_codesystems()
    answers = qr.extract_answers()

    return templates.TemplateResponse(
        "questionnaire.html",
        {
            "request": request,
            "q": q,
            "valuesets": valuesets,
            "codesystems": codesystems,
            "resolve_options": resolve_answer_options,
            "answers": answers,
            "response": qr,
        },
    )


# ---------------------------------------------------------------------------
# Routes — Observation CRUD
# ---------------------------------------------------------------------------


@app.get("/observation/{oid}/edit", response_class=HTMLResponse)
async def observation_edit_form(request: Request, oid: str) -> Response:
    """Show form for editing a user-created observation."""
    data = load_user_resource("Observation", oid)
    if not data:
        return HTMLResponse(f"<h1>Observation '{oid}' is not editable</h1>", status_code=403)

    subject_ref = data.get("subject", {}).get("reference", "")
    pid = subject_ref.split("/")[-1] if subject_ref else ""
    patients = load_patients()
    patient = next((p for p in patients if p.id == pid), None)

    return templates.TemplateResponse(
        "observation_form.html",
        {
            "request": request,
            "patient": patient,
            "observation": data,
            "mode": "edit",
            "categories": OBSERVATION_CATEGORIES,
            "common_observations": COMMON_OBSERVATIONS,
        },
    )


@app.post("/observation/save")
async def observation_save(
    request: Request,
    observation_id: str = Form(""),
    patient_id: str = Form(""),
    status: str = Form("final"),
    category: str = Form("vital-signs"),
    code_system: str = Form("http://loinc.org"),
    code_code: str = Form(""),
    code_display: str = Form(""),
    effective_date: str = Form(""),
    value_type: str = Form("quantity"),
    value_number: str = Form(""),
    value_unit: str = Form(""),
    value_ucum: str = Form(""),
    value_string: str = Form(""),
    value_coded_code: str = Form(""),
    value_coded_display: str = Form(""),
) -> RedirectResponse:
    """Create or update an Observation."""
    rid = observation_id or generate_id("obs-")

    resource: dict = {
        "resourceType": "Observation",
        "id": rid,
        "meta": {
            "profile": ["http://dhis2.org/fhir/learning/StructureDefinition/dhis2-observation"],
        },
        "status": status,
        "category": [
            {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                        "code": category,
                        "display": dict(OBSERVATION_CATEGORIES).get(category, category),
                    }
                ]
            }
        ],
        "code": {
            "coding": [
                {
                    "system": code_system,
                    "code": code_code,
                    "display": code_display,
                }
            ]
        },
        "subject": {"reference": f"Patient/{patient_id}"},
    }

    if effective_date:
        resource["effectiveDateTime"] = effective_date

    if value_type == "quantity" and value_number:
        resource["valueQuantity"] = {
            "value": float(value_number),
            "unit": value_unit,
            "system": "http://unitsofmeasure.org",
            "code": value_ucum or value_unit,
        }
    elif value_type == "string" and value_string:
        resource["valueString"] = value_string
    elif value_type == "coded" and value_coded_code:
        resource["valueCodeableConcept"] = {
            "coding": [
                {
                    "code": value_coded_code,
                    "display": value_coded_display or value_coded_code,
                }
            ]
        }

    save_resource(resource)
    return RedirectResponse(url=f"/patient/{patient_id}", status_code=303)


@app.post("/observation/{oid}/delete")
async def observation_delete(oid: str, patient_id: str = Form("")) -> RedirectResponse:
    """Delete a user-created Observation."""
    delete_resource("Observation", oid)
    if patient_id:
        return RedirectResponse(url=f"/patient/{patient_id}", status_code=303)
    return RedirectResponse(url="/", status_code=303)


# ---------------------------------------------------------------------------
# Routes — Terminology (ValueSet / CodeSystem browsing)
# ---------------------------------------------------------------------------


@app.get("/terminology/valuesets", response_class=HTMLResponse)
async def valueset_list(request: Request) -> Response:
    """Browse all ValueSets."""
    valuesets = load_valuesets()
    codesystems = load_codesystems()
    return templates.TemplateResponse(
        "valueset_list.html",
        {
            "request": request,
            "valuesets": sorted(valuesets.values(), key=lambda v: v.name or v.id),
            "codesystems": codesystems,
        },
    )


@app.get("/terminology/valueset/{vid}", response_class=HTMLResponse)
async def valueset_detail(request: Request, vid: str) -> Response:
    """View a ValueSet and its expanded concepts."""
    valuesets = load_valuesets()
    codesystems = load_codesystems()
    vs = next((v for v in valuesets.values() if v.id == vid), None)
    if not vs:
        return HTMLResponse(f"<h1>ValueSet '{vid}' not found</h1>", status_code=404)
    # Expand concepts
    concepts: list[dict[str, str]] = []
    system_url = ""
    if vs.compose:
        for include in vs.compose.include:
            system_url = include.system
            for concept in include.concept:
                concepts.append({"system": include.system, "code": concept.code, "display": concept.display})
            if not include.concept and include.system in codesystems:
                cs = codesystems[include.system]
                for concept in cs.concept:
                    concepts.append({"system": include.system, "code": concept.code, "display": concept.display})
    return templates.TemplateResponse(
        "valueset_detail.html",
        {
            "request": request,
            "vs": vs,
            "concepts": concepts,
            "system_url": system_url,
        },
    )


@app.get("/terminology/codesystems", response_class=HTMLResponse)
async def codesystem_list(request: Request) -> Response:
    """Browse all CodeSystems."""
    codesystems = load_codesystems()
    return templates.TemplateResponse(
        "codesystem_list.html",
        {
            "request": request,
            "codesystems": sorted(codesystems.values(), key=lambda c: c.name or c.id),
        },
    )


@app.get("/terminology/codesystem/{csid}", response_class=HTMLResponse)
async def codesystem_detail(request: Request, csid: str) -> Response:
    """View a CodeSystem and its concepts."""
    codesystems = load_codesystems()
    cs = next((c for c in codesystems.values() if c.id == csid), None)
    if not cs:
        return HTMLResponse(f"<h1>CodeSystem '{csid}' not found</h1>", status_code=404)
    return templates.TemplateResponse(
        "codesystem_detail.html",
        {
            "request": request,
            "cs": cs,
        },
    )


# ---------------------------------------------------------------------------
# Routes — IPS Bundle view
# ---------------------------------------------------------------------------


def _resolve_bundle_entries(bundle: dict) -> dict:
    """Build a lookup from fullUrl and resource references to entry resources."""
    index: dict[str, dict] = {}
    for entry in bundle.get("entry", []):
        resource = entry.get("resource", {})
        full_url = entry.get("fullUrl", "")
        rt = resource.get("resourceType", "")
        rid = resource.get("id", "")
        if full_url:
            index[full_url] = resource
        if rt and rid:
            index[f"{rt}/{rid}"] = resource
    return index


def _expand_bundle_json(bundle: dict) -> dict:
    """Return a copy of the bundle with Composition references expanded inline."""
    import copy

    expanded = copy.deepcopy(bundle)
    index = _resolve_bundle_entries(bundle)

    for entry in expanded.get("entry", []):
        resource = entry.get("resource", {})
        if resource.get("resourceType") == "Composition":
            for section in resource.get("section", []):
                expanded_entries = []
                for ref_obj in section.get("entry", []):
                    ref = ref_obj.get("reference", "")
                    resolved = index.get(ref)
                    if resolved:
                        expanded_entries.append(
                            {
                                "reference": ref,
                                "_resolved": resolved,
                            }
                        )
                    else:
                        expanded_entries.append(ref_obj)
                section["entry"] = expanded_entries
            # Also expand subject
            subject = resource.get("subject", {})
            sub_ref = subject.get("reference", "")
            if sub_ref and sub_ref in index:
                resource["subject"] = {
                    "reference": sub_ref,
                    "_resolved": index[sub_ref],
                }
    return expanded


def _expand_valueset_json(data: dict) -> dict | None:
    """Return a copy of the ValueSet with expansion.contains resolved from CodeSystems."""
    import copy

    compose = data.get("compose")
    if not compose:
        return None
    codesystems = load_codesystems()
    contains: list[dict] = []
    for include in compose.get("include", []):
        system = include.get("system", "")
        concepts = include.get("concept", [])
        if concepts:
            for c in concepts:
                contains.append({"system": system, "code": c.get("code", ""), "display": c.get("display", "")})
        elif system in codesystems:
            cs = codesystems[system]
            for c in cs.concept:
                contains.append({"system": system, "code": c.code, "display": c.display})
    if not contains:
        return None
    expanded = copy.deepcopy(data)
    expanded["expansion"] = {
        "timestamp": date.today().isoformat(),
        "total": len(contains),
        "contains": contains,
    }
    return expanded


def _expand_questionnaire_json(data: dict) -> dict | None:
    """Return a copy of the Questionnaire with answerValueSet references resolved inline."""
    import copy

    valuesets = load_valuesets()
    codesystems = load_codesystems()
    has_valuesets = False

    def resolve_items(items: list[dict]) -> list[dict]:
        nonlocal has_valuesets
        resolved = []
        for item in items:
            item = copy.deepcopy(item)
            vs_url = item.get("answerValueSet", "")
            if vs_url and vs_url in valuesets:
                has_valuesets = True
                vs = valuesets[vs_url]
                options: list[dict] = []
                if vs.compose:
                    for include in vs.compose.include:
                        for c in include.concept:
                            options.append({"system": include.system, "code": c.code, "display": c.display})
                        if not include.concept and include.system in codesystems:
                            cs = codesystems[include.system]
                            for c in cs.concept:
                                options.append({"system": include.system, "code": c.code, "display": c.display})
                item["_resolvedOptions"] = options
            if "item" in item:
                item["item"] = resolve_items(item["item"])
            resolved.append(item)
        return resolved

    expanded = copy.deepcopy(data)
    if "item" in expanded:
        expanded["item"] = resolve_items(expanded["item"])
    return expanded if has_valuesets else None


@app.get("/ips", response_class=HTMLResponse)
async def ips_list(request: Request) -> Response:
    """List all IPS Bundles."""
    bundles = load_bundles()
    ips_bundles = [b for b in bundles if b.get("type") == "document"]
    # Extract summary info for each IPS
    summaries = []
    for b in ips_bundles:
        info: dict = {"id": b.get("id", ""), "timestamp": b.get("timestamp", "")}
        entries = b.get("entry", [])
        patient = None
        immunizations = []
        for entry in entries:
            res = entry.get("resource", {})
            rt = res.get("resourceType", "")
            if rt == "Patient" and not patient:
                names = res.get("name", [{}])
                name_parts = names[0] if names else {}
                given = " ".join(name_parts.get("given", []))
                family = name_parts.get("family", "")
                patient = {
                    "name": f"{given} {family}".strip(),
                    "gender": res.get("gender", ""),
                    "birthDate": res.get("birthDate", ""),
                    "id": res.get("id", ""),
                }
            elif rt == "Immunization":
                codes = res.get("vaccineCode", {}).get("coding", [])
                display = codes[0].get("display", codes[0].get("code", "")) if codes else "Unknown"
                immunizations.append(display)
        info["patient"] = patient
        info["immunizations"] = immunizations
        info["imm_count"] = len(immunizations)
        summaries.append(info)
    return templates.TemplateResponse(
        "ips_list.html",
        {"request": request, "bundles": summaries},
    )


@app.get("/ips/{bid}", response_class=HTMLResponse)
async def render_ips(request: Request, bid: str) -> Response:
    """Render an IPS Bundle with all resources expanded."""
    bundles = load_bundles()
    bundle = next((b for b in bundles if b.get("id") == bid), None)
    if not bundle:
        return HTMLResponse(f"<h1>Bundle '{bid}' not found</h1>", status_code=404)

    entries = bundle.get("entry", [])
    composition = None
    patient = None
    immunizations = []

    for entry in entries:
        res = entry.get("resource", {})
        rt = res.get("resourceType", "")
        if rt == "Composition" and not composition:
            composition = res
        elif rt == "Patient" and not patient:
            patient = res
        elif rt == "Immunization":
            immunizations.append(res)

    return templates.TemplateResponse(
        "ips_view.html",
        {
            "request": request,
            "bundle": bundle,
            "composition": composition,
            "patient": patient,
            "immunizations": immunizations,
        },
    )


# ---------------------------------------------------------------------------
# Routes — CHR (Community Health Record)
# ---------------------------------------------------------------------------


@app.get("/chr", response_class=HTMLResponse)
async def chr_dashboard(request: Request) -> Response:
    """CHR dashboard with stats and quick actions."""
    all_patients = load_patients()
    chr_patients = [p for p in all_patients if p.identifier_by_type("CHR")]
    all_immunizations = load_immunizations()
    return templates.TemplateResponse(
        "chr_dashboard.html",
        {
            "request": request,
            "chr_patient_count": len(chr_patients),
            "immunization_count": len(all_immunizations),
        },
    )


@app.get("/chr/patients", response_class=HTMLResponse)
async def chr_patients(request: Request) -> Response:
    """List all CHR patients."""
    all_patients = load_patients()
    chr_patients = [p for p in all_patients if p.identifier_by_type("CHR")]
    return templates.TemplateResponse(
        "chr_search.html",
        {
            "request": request,
            "results": chr_patients,
            "searched": True,
            "search_mode": "",
            "id_type": "",
            "id_value": "",
            "firstname": "",
            "lastname": "",
            "sex": "",
            "dob": "",
            "mobile": "",
            "village": "",
            "villages": [],
            "fhir_url": "GET /fhir/Patient",
            "page_title": "CHR Patients",
            "page_subtitle": "All registered CHR patients",
        },
    )


@app.get("/chr/search", response_class=HTMLResponse)
async def chr_search(
    request: Request,
    search_mode: str = "",
    id_type: str = "",
    id_value: str = "",
    firstname: str = "",
    lastname: str = "",
    sex: str = "",
    dob: str = "",
    mobile: str = "",
    village: str = "",
) -> Response:
    """CHR search page."""
    all_patients = load_patients()
    chr_patients = [p for p in all_patients if p.identifier_by_type("CHR")]

    # Collect unique villages for dropdown
    villages: set[str] = set()
    for p in chr_patients:
        for addr in p.address:
            if addr.city:
                villages.add(addr.city)

    results: list = []
    fhir_url = ""
    searched = False

    if search_mode == "identifier" and id_type and id_value:
        searched = True
        val = id_value.strip().lower()
        type_map = {
            "clientHealthId": "CHR",
            "cvid": "CVID",
            "nationalId": "GREENCARD",
            "passport": "PPN",
            "systemCvid": "CVID",
        }
        code = type_map.get(id_type, id_type)
        results = [p for p in chr_patients if p.identifier_by_type(code).lower().startswith(val)]

        sys_map = {
            "clientHealthId": "http://moh.gov.la/fhir/id/client-health-id",
            "cvid": "http://moh.gov.la/fhir/id/cvid",
            "nationalId": "http://moh.gov.la/fhir/id/green-national-id",
            "passport": "http://example.org/passport",
            "systemCvid": "http://moh.gov.la/fhir/id/cvid",
        }
        system = sys_map.get(id_type, "")
        fhir_url = f"GET /fhir/Patient?identifier={system}|{id_value}"

    elif search_mode == "attributes":
        searched = True
        filtered = chr_patients
        params: list[str] = []

        if firstname:
            fn = firstname.strip().lower()
            filtered = [p for p in filtered if any(fn in g.lower() for n in p.name for g in n.given)]
            params.append(f"given={firstname}")
        if lastname:
            ln = lastname.strip().lower()
            filtered = [p for p in filtered if any(ln in n.family.lower() for n in p.name)]
            params.append(f"family={lastname}")
        if sex:
            filtered = [p for p in filtered if p.gender == sex]
            params.append(f"gender={sex}")
        if dob:
            filtered = [p for p in filtered if p.birthDate == dob]
            params.append(f"birthdate={dob}")
        if mobile:
            mobile_digits = _digits_only(mobile)
            filtered = [
                p
                for p in filtered
                if any(mobile_digits in _digits_only(t.value) for t in p.telecom if t.system == "phone")
            ]
            params.append(f"phone={mobile}")
        if village:
            v = village.strip().lower()
            filtered = [p for p in filtered if any(v in a.city.lower() for a in p.address)]
            params.append(f"address-city={village}")

        if any([firstname, lastname, sex, dob, mobile, village]):
            results = filtered
        fhir_url = "GET /fhir/Patient?" + "&".join(params) if params else ""

    return templates.TemplateResponse(
        "chr_search.html",
        {
            "request": request,
            "results": results,
            "searched": searched,
            "search_mode": search_mode,
            "id_type": id_type,
            "id_value": id_value,
            "firstname": firstname,
            "lastname": lastname,
            "sex": sex,
            "dob": dob,
            "mobile": mobile,
            "village": village,
            "villages": sorted(villages),
            "fhir_url": fhir_url,
        },
    )


@app.get("/chr/register", response_class=HTMLResponse)
async def chr_register_form(request: Request) -> Response:
    """CHR patient registration form."""
    return templates.TemplateResponse("chr_register.html", {"request": request})


@app.get("/chr/patient/{pid}/eir", response_class=HTMLResponse)
async def chr_eir(request: Request, pid: str) -> Response:
    """EIR immunization history for a CHR patient."""
    patients = load_patients()
    patient = next((p for p in patients if p.id == pid), None)
    if not patient:
        return HTMLResponse(f"<h1>Patient '{pid}' not found</h1>", status_code=404)

    all_imm = load_immunizations()
    patient_imm = [i for i in all_imm if i.patient_id == pid]
    patient_imm.sort(key=lambda i: i.occurrenceDateTime)

    return templates.TemplateResponse(
        "chr_eir.html",
        {
            "request": request,
            "patient": patient,
            "immunizations": patient_imm,
        },
    )


@app.get("/chr/patient/{pid}", response_class=HTMLResponse)
async def chr_patient_view(request: Request, pid: str) -> Response:
    """CHR patient view with demographics and EIR link."""
    patients = load_patients()
    patient = next((p for p in patients if p.id == pid), None)
    if not patient:
        return HTMLResponse(f"<h1>Patient '{pid}' not found</h1>", status_code=404)

    all_imm = load_immunizations()
    patient_imm = [i for i in all_imm if i.patient_id == pid]

    return templates.TemplateResponse(
        "chr_eir.html",
        {
            "request": request,
            "patient": patient,
            "immunizations": patient_imm,
        },
    )


# ---------------------------------------------------------------------------
# Routes — JSON view
# ---------------------------------------------------------------------------


@app.get("/json/{resource_type}/{rid}", response_class=HTMLResponse)
async def view_json(request: Request, resource_type: str, rid: str) -> Response:
    """View the raw JSON of a resource."""
    data = load_raw_json(resource_type, rid)
    if not data:
        return HTMLResponse(f"<h1>Resource not found: {resource_type}/{rid}</h1>", status_code=404)
    # For Bundles, offer an expanded view
    expanded_json = None
    if data.get("resourceType") == "Bundle" and data.get("type") == "document":
        expanded = _expand_bundle_json(data)
        expanded_json = json.dumps(expanded, indent=2)
    # For ValueSets, show expanded (resolved concepts)
    elif data.get("resourceType") == "ValueSet":
        vs_expanded = _expand_valueset_json(data)
        if vs_expanded:
            expanded_json = json.dumps(vs_expanded, indent=2)
    # For Questionnaires, resolve answerValueSet references inline
    elif data.get("resourceType") == "Questionnaire":
        q_expanded = _expand_questionnaire_json(data)
        if q_expanded:
            expanded_json = json.dumps(q_expanded, indent=2)
    return templates.TemplateResponse(
        "json_view.html",
        {
            "request": request,
            "resource": data,
            "json_str": json.dumps(data, indent=2),
            "expanded_json": expanded_json,
        },
    )
