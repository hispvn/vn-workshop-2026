# Architecture

This chapter documents how the renderer's components fit together: the package layout, the loader that reads SUSHI output, the FastAPI routes, the option resolution logic, and the Jinja2 templates.

## Package structure

```
src/dhis2_fhir/
├── __init__.py
├── models.py       # Pydantic models for FHIR resources
├── loader.py       # JSON file loading and parsing
├── store.py        # JSON file store for user-created resources
├── seed.py         # Generate 100 seed patients
└── app.py          # FastAPI routes and template rendering

templates/
├── base.html              # Shared layout with card-based styling
├── index.html             # Resource listing page (dashboard)
├── patient_list.html      # Patient search with filtering and pagination
├── patient.html           # Patient profile card
├── patient_form.html      # Create/edit patient form
├── observation_form.html  # Create/edit observation form
├── questionnaire.html     # Form rendering (and pre-filled responses)
└── json_view.html         # Raw JSON display

data/               # User-created resources (gitignored)
├── Patient/        # Patient JSON files
└── Observation/    # Observation JSON files

static/             # CSS and other static assets
```

The Python source uses the `src` layout -- the package lives under `src/dhis2_fhir/` rather than at the repository root. This is the layout expected by the `uv_build` backend configured in `pyproject.toml`.

## The loader module

The loader (`src/dhis2_fhir/loader.py`) is responsible for finding JSON files, deduplicating them, and parsing them into Pydantic models.

### File discovery

The core function `_load_raw(prefix)` scans three locations for JSON files:

```python
FSH_GENERATED = Path("ig/fsh-generated/resources")  # SUSHI output
IG_OUTPUT = Path("ig/output")                        # IG Publisher output
# Plus: data/{prefix}/  via store.load_user_resources()
```

It looks for files matching the pattern `{prefix}-*.json` -- for example, `Patient-*.json` picks up `Patient-example-patient-01.json`. All three directories are searched because SUSHI writes to `fsh-generated/resources/`, the IG Publisher writes to `output/`, and user-created resources live in `data/`. When the same resource appears in multiple locations, deduplication by `id` ensures each resource is loaded only once (the first occurrence wins).

```python
def _load_raw(prefix: str) -> list[dict[str, Any]]:
    resources: list[dict[str, Any]] = []
    for search_dir in [FSH_GENERATED, IG_OUTPUT]:
        if not search_dir.exists():
            continue
        for path in sorted(search_dir.glob(f"{prefix}-*.json")):
            try:
                resources.append(json.loads(path.read_text()))
            except (json.JSONDecodeError, KeyError):
                continue
    # Also include user-created resources from data/
    resources.extend(load_user_resources(prefix))
    seen: set[str] = set()
    unique: list[dict[str, Any]] = []
    for r in resources:
        rid = r.get("id", "")
        if rid not in seen:
            seen.add(rid)
            unique.append(r)
    return unique
```

Files that fail to parse as JSON are silently skipped. This is intentional -- the directories may contain incomplete files during a SUSHI build.

### Typed loaders

Each resource type has a dedicated loader function that calls `_load_raw` and validates through Pydantic:

```python
def load_patients() -> list[Patient]:
    return [Patient.model_validate(d) for d in _load_raw("Patient")]

def load_questionnaires() -> list[Questionnaire]:
    return [
        Questionnaire.model_validate(d)
        for d in _load_raw("Questionnaire")
        if d.get("resourceType") == "Questionnaire"
    ]
```

Note the extra `resourceType` filter on `load_questionnaires()`. This is necessary because `Questionnaire-*.json` also matches `QuestionnaireResponse-*.json` files (the glob `Questionnaire-*` is a prefix match). Without the filter, QuestionnaireResponse JSON would fail validation against the Questionnaire model.

### Terminology indexes

CodeSystems and ValueSets are loaded into dictionaries indexed by their canonical URL:

```python
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
```

This URL-based indexing is what makes the option resolution chain work efficiently -- given an `answerValueSet` URL, we can look up the ValueSet in O(1) time.

### Single resource loading

For the JSON view route, `load_raw_json` loads a single resource by type and id:

```python
def load_raw_json(resource_type: str, rid: str) -> dict[str, Any] | None:
    pattern = f"{resource_type}-{rid}.json"
    for search_dir in [FSH_GENERATED, IG_OUTPUT]:
        if not search_dir.exists():
            continue
        path = search_dir / pattern
        if path.exists():
            return json.loads(path.read_text())
    return None
```

This returns the raw dict (not a Pydantic model) because the JSON view template renders the unprocessed JSON string.

## The store module

The store (`src/dhis2_fhir/store.py`) provides a simple file-based persistence layer for user-created FHIR resources.

### Storage layout

Resources are saved as individual JSON files in `data/{ResourceType}/`:

```
data/
├── Patient/
│   ├── Patient-patient-fac3a9ef.json
│   ├── Patient-seed-patient-001.json
│   └── ...
└── Observation/
    ├── Observation-obs-37abf06a.json
    └── ...
```

The naming convention `{ResourceType}-{id}.json` matches SUSHI's output format, so the loader's glob pattern `{prefix}-*.json` picks up both SUSHI-generated and user-created files.

### API

```python
save_resource(resource: dict) -> dict       # Save to disk
load_user_resources(type: str) -> list      # Load all of a type
load_user_resource(type: str, id: str)      # Load one by id
delete_resource(type: str, id: str) -> bool # Delete one
generate_id(prefix: str) -> str             # Generate unique ID
```

IDs are generated as `{prefix}{8-hex-chars}` using `uuid4`. The prefix helps identify the source -- `patient-` for manually created patients, `seed-patient-` for seeded data, `obs-` for observations.

### Seed data

The seed module (`src/dhis2_fhir/seed.py`) generates 100 realistic patients with:

- Names from common African name pools (50 female, 50 male given names; 50 family names)
- Random demographics (birth dates 1960--2020, ~50/50 gender split)
- Addresses across 8 DHIS2-using countries (Sierra Leone, Kenya, Malawi, Ghana, Tanzania, Uganda, Guinea, Mozambique)
- DHIS2 UIDs (11-character alphanumeric)
- National IDs (70% of patients)
- 5% inactive status

Run with:

```bash
make seed
# or: uv run python -m dhis2_fhir.seed
```

The seed uses `random.seed(42)` for deterministic, reproducible output.

## The app module

The app (`src/dhis2_fhir/app.py`) sets up FastAPI, configures templates and static files, defines routes, and implements option resolution.

### Setup

```python
app = FastAPI(title="DHIS2-FHIR Resource Renderer")

_PROJECT_ROOT = Path.cwd()
templates = Jinja2Templates(directory=str(_PROJECT_ROOT / "templates"))
app.mount("/static", StaticFiles(directory=str(_PROJECT_ROOT / "static")), name="static")
```

Templates and static files are resolved relative to the current working directory, not the Python package directory. This means the app must be launched from the project root -- which is what `make run` and `uv run fastapi dev src/dhis2_fhir/app.py` both do.

### Routes

The app defines routes across four groups:

**Read-only views:**

| Route | Template | Purpose |
|-------|----------|---------|
| `GET /` | `index.html` | Dashboard listing all resource types (shows first 10 patients) |
| `GET /patients` | `patient_list.html` | Patient search with filtering and pagination |
| `GET /patient/{pid}` | `patient.html` | Patient profile card with observations and form submissions |
| `GET /questionnaire/{qid}` | `questionnaire.html` | Interactive form with resolved options |
| `GET /response/{rid}` | `questionnaire.html` | Pre-filled form from response data |
| `GET /json/{type}/{rid}` | `json_view.html` | Raw JSON display with syntax highlighting (toggle expanded view for ValueSets and Questionnaires) |

**Questionnaire filling:**

| Route | Template | Purpose |
|-------|----------|---------|
| `GET /forms` | `forms_list.html` | Questionnaires page -- browse definitions, fill anonymous or patient questionnaires, view QuestionnaireResponses |
| `GET /form/{qid}` | `questionnaire.html` | Fill an anonymous questionnaire (event program) |
| `GET /patient/{pid}/form/{qid}` | `questionnaire.html` | Fill a questionnaire for a specific patient (tracker program) |
| `POST /form/save` | — | Save a QuestionnaireResponse (redirects to patient or response view) |

**Terminology browsing:**

| Route | Template | Purpose |
|-------|----------|---------|
| `GET /terminology/valuesets` | `valueset_list.html` | Browse all ValueSets with concept counts |
| `GET /terminology/valueset/{vid}` | `valueset_detail.html` | ValueSet detail with expanded concepts |
| `GET /terminology/codesystems` | `codesystem_list.html` | Browse all CodeSystems with concept counts |
| `GET /terminology/codesystem/{csid}` | `codesystem_detail.html` | CodeSystem detail with all concepts |

**Patient CRUD:**

| Route | Purpose |
|-------|---------|
| `GET /patient/new/create` | Create patient form |
| `GET /patient/{pid}/edit` | Edit patient form (user-created only) |
| `POST /patient/save` | Create or update a patient |
| `POST /patient/{pid}/delete` | Delete patient and its observations |

**Observation CRUD:**

| Route | Purpose |
|-------|---------|
| `GET /patient/{pid}/observation/new` | Add observation form |
| `GET /observation/{oid}/edit` | Edit observation form (user-created only) |
| `POST /observation/save` | Create or update an observation |
| `POST /observation/{oid}/delete` | Delete an observation |

Route ordering matters for FastAPI path matching. Specific paths like `/patient/new/create` and `/patient/save` must be declared **before** the catch-all `/patient/{pid}` to prevent the path variable from capturing literal segments like "new".

### Patient search

The `/patients` route supports text search, gender filtering, country filtering, and pagination:

```python
@app.get("/patients")
async def patient_list(
    request: Request,
    q: str = "",           # Free-text search
    gender: str = "",      # Filter: male, female, other
    country: str = "",     # Filter: country name
    page: int = 1,         # Current page
    per_page: int = 20,    # Results per page
):
```

The search matches against multiple fields:
- Patient display name
- DHIS2 UID
- National ID
- Resource ID
- City and country from address

All matching is case-insensitive. Filters compose with AND logic -- setting both `gender=female` and `country=Kenya` returns female patients in Kenya.

The country dropdown is dynamically populated from all unique countries found across loaded patients.

### Read-only vs editable resources

SUSHI-generated resources (from `ig/fsh-generated/`) are read-only. User-created resources (in `data/`) are editable. The `_is_user_resource()` helper checks which category a resource belongs to, and templates conditionally show Edit/Delete buttons based on this.

The response route (`/response/{rid}`) reuses the same `questionnaire.html` template as the questionnaire route. It finds the matching Questionnaire definition through a multi-step lookup -- first by URL suffix, then by exact URL match, then by id guess -- and passes `answers=qr.extract_answers()` to pre-fill form fields.

### Option resolution

The `resolve_answer_options` function connects Questionnaire items to their selectable values. This is the most important piece of logic in the app:

```python
def resolve_answer_options(
    item: QuestionnaireItem,
    valuesets: dict[str, ValueSet],
    codesystems: dict[str, CodeSystem],
) -> list[dict[str, str]]:
```

The resolution follows this flow:

1. **Direct options first.** If the item has `answerOption` entries, each one becomes a `{code, display}` dict. These come from inline `valueCoding` or `valueString` values in the Questionnaire definition.

2. **ValueSet resolution.** If no direct options exist and the item has an `answerValueSet` URL, look up the ValueSet by that URL.

3. **Concept extraction.** For each `compose.include[]` entry in the ValueSet:
   - If the include has explicit `concept[]` entries, use those directly.
   - If the include only has a `system` URL (no inline concepts), look up the CodeSystem by that URL and use all its `concept[]` entries.

4. **Return.** The result is a flat list of `{code, display}` dicts ready for dropdown rendering.

This chain looks like:

```
QuestionnaireItem.answerValueSet (URL)
    └─> ValueSet.compose.include[]
            ├─> include.concept[] (if present, use directly)
            └─> include.system (URL)
                    └─> CodeSystem.concept[] (all concepts from the system)
```

The function is passed to the template as `resolve_options`, so Jinja2 can call it for each item during rendering.

### Client-side ValueSet expansion

When filling a questionnaire, choice fields that reference an `answerValueSet` populate their dropdown options via the FHIR API rather than server-side resolution. The template renders an empty `<select>` with a `data-valueset-url` attribute, and JavaScript calls `GET /fhir/ValueSet/$expand?url={answerValueSet}` to fetch the expanded concepts. Each dropdown shows the FHIR `$expand` URL being called, making the FHIR interaction visible to workshop participants.

Items with inline `answerOption` entries (no ValueSet reference) still render their options server-side.

### FHIR URL annotations

Throughout the UI, FHIR Equivalent annotations show the corresponding FHIR REST API call for the data being displayed. For example, a Patient profile page shows `GET /fhir/Patient/{id}`, and a ValueSet detail page shows both the read URL and the `$expand` URL. These annotations link to either the rendered JSON view (`/json/`) for single resources or the raw FHIR API (`/fhir/`) for search bundles.

### Patient search via FHIR API

The Questionnaires page uses client-side FHIR search to find patients. Instead of a static dropdown, users type into a search field that calls `GET /fhir/Patient?name={query}` and displays matching results. This demonstrates the FHIR patient search API in real-time.

### Anonymous vs patient questionnaires

The Questionnaires page separates anonymous (event program) and patient (tracker program) questionnaire filling. Anonymous questionnaires have no `subjectType` and submit without a patient reference. Patient questionnaires require selecting a patient via FHIR search before filling.

## Templates

All templates extend `base.html`, which provides a shared layout with card-based styling and a navigation bar (Home, Patients).

### index.html

Dashboard listing resources in three sections. Shows the first 10 patients with a "View all" link to the full search page. Questionnaires and QuestionnaireResponses show all entries.

### patient_list.html

Full patient search interface with:
- **Text search** — matches name, DHIS2 UID, national ID, city, country
- **Gender filter** — dropdown for male/female/other
- **Country filter** — dynamically populated from all loaded patients
- **Pagination** — 20 per page with numbered page links
- **Results count** — shows total matches

### patient.html

Renders a patient profile card with:
- Name, gender, birth date, active status
- All identifiers with human-friendly type labels (from `identifier_display()`)
- Address display
- Org unit reference (from the DHIS2 extension)
- Observations table with "+ Add Observation" button
- Links to associated QuestionnaireResponses
- Edit/Delete buttons for user-created patients

### patient_form.html

Create/edit form for patients with fields for:
- Given name(s), family name
- Gender (dropdown), date of birth
- Active status
- DHIS2 UID and national ID (identifier slices)
- City and country

### observation_form.html

Create/edit form for observations with:
- **Quick select** — pill buttons for common LOINC observations (body weight, height, heart rate, temperature, BP, hemoglobin, malaria RDT, HIV test) that auto-fill code, unit, and category
- **Value type** — radio buttons to switch between quantity (number + unit), text, or coded value inputs
- Category dropdown (vital signs, laboratory, exam, social history)
- LOINC code and display fields
- Date picker

### questionnaire.html

The most complex template. It recursively renders `QuestionnaireItem` entries, choosing the HTML input type based on `item.type`:
- `string` -> `<input type="text">`
- `date` -> `<input type="date">`
- `boolean` -> `<input type="checkbox">`
- `choice` -> `<select>` dropdown with options from `resolve_options()`
- `integer`, `decimal` -> `<input type="number">`
- `group` -> `<fieldset>` wrapper with nested items

When rendering a QuestionnaireResponse, the `answers` dict is checked for each item's `linkId`. If a value exists, the input is pre-populated -- `value` attribute for text/date/number, `selected` for dropdowns, `checked` for checkboxes.

### json_view.html

Displays the raw JSON of any resource using `<pre>` formatting. The route passes a pre-formatted `json_str` (via `json.dumps(data, indent=2)`) to the template.

## Dependencies and build system

From `pyproject.toml`:

```toml
[project]
name = "dhis2-fhir"
requires-python = ">=3.13"
dependencies = [
    "fastapi[standard]>=0.135.1",
    "jinja2>=3.1.6",
    "pydantic>=2.12.5",
    "uvicorn>=0.41.0",
]

[build-system]
requires = ["uv_build>=0.7.2,<0.8"]
build-backend = "uv_build"
```

- **fastapi[standard]** -- The `[standard]` extra includes uvicorn, the ASGI server, and the CLI (`fastapi dev` command).
- **pydantic** -- Version 2.x is required for `model_validate()` and the modern BaseModel API.
- **jinja2** -- Template engine, used through FastAPI's `Jinja2Templates` wrapper.
- **uvicorn** -- Listed explicitly as a dependency alongside the fastapi standard extra.

The build backend is `uv_build` (not the more common `hatchling` or `setuptools`). This is the native build backend for the `uv` package manager, which handles the `src` layout automatically.

To run the application:

```bash
# Compile FSH first (generates the FHIR JSON that the renderer reads)
make docker-sushi

# Generate 100 seed patients (optional, populates data/)
make seed

# Start the renderer
make run
# or: uv run fastapi dev src/dhis2_fhir/app.py
```

The `fastapi dev` command starts uvicorn with auto-reload enabled, so code changes are picked up immediately without restarting the server.

### Available make targets

| Target | Description |
|--------|-------------|
| `make run` | Start the renderer at http://localhost:8000 |
| `make seed` | Generate 100 seed patients in `data/` |
| `make docker-sushi` | Compile FSH to JSON |
| `make docker-build` | Full IG Publisher build |
| `make build-book` | Build mdbook documentation |
| `make serve` | Serve mdbook with live reload |
| `make clean` | Remove generated files |
