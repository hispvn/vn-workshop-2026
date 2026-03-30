# Pydantic Models

The file `src/dhis2_fhir/models.py` defines Pydantic models for every FHIR resource type the renderer handles. These models serve two purposes: they parse SUSHI-generated JSON into typed Python objects, and they provide computed properties that centralize display logic. This chapter is a complete reference for every model class.

## Design choices

Before diving into the models, it helps to understand three design decisions that apply throughout:

**Permissive defaults.** Every field has a default value -- empty string for scalars, `Field(default_factory=list)` for lists, `None` for optional complex types. This means any valid FHIR JSON will parse without raising a validation error, even if it omits most fields. We are rendering example instances, not enforcing conformance.

**Computed properties.** Models use `@property` methods for display logic. `HumanName.display` joins given names and family name. `Patient.display_name` joins all names with semicolons. Templates call these properties directly, keeping Jinja2 markup clean.

**FHIR naming conventions preserved.** Field names match FHIR's camelCase naming (`resourceType`, `birthDate`, `answerValueSet`). This means the JSON parses without any field mapping configuration -- Pydantic reads the keys directly.

## Shared building blocks

These small models represent FHIR data types used across multiple resources.

### Coding

```python
class Coding(BaseModel):
    system: str = ""
    code: str = ""
    display: str = ""
```

The fundamental unit of coded data in FHIR. A `system` URL identifies the code system, `code` is the value within that system, and `display` is the human-readable label. Used inside `CodeableConcept`, `AnswerOption`, `QRAnswer`, and `EnableWhen`.

### CodeableConcept

```python
class CodeableConcept(BaseModel):
    coding: list[Coding] = Field(default_factory=list)
    text: str = ""
```

A concept that can carry multiple codings from different systems, plus a plain-text fallback. In the renderer, this appears primarily as the `type` field on `Identifier`, where it distinguishes DHIS2 UIDs (`RI`), national IDs (`NI`), and medical record numbers (`MR`).

### Reference

```python
class Reference(BaseModel):
    reference: str = ""
    display: str = ""
```

A pointer to another resource. The `reference` field holds a relative or absolute URL (e.g., `"Patient/example-patient-01"`), and `display` provides a human label. Used in `Extension.valueReference` and `QuestionnaireResponse.subject`.

### Extension

```python
class Extension(BaseModel):
    url: str = ""
    valueReference: Reference | None = None
    valueString: str | None = None
    valueCode: str | None = None
```

FHIR extensions carry additional data not in the base spec. The `url` identifies the extension definition, and one of the `value[x]` fields holds the data. The renderer uses this primarily for the DHIS2 org-unit extension on Patient, which uses `valueReference` to point to an Organization.

### Identifier

```python
class Identifier(BaseModel):
    system: str = ""
    value: str = ""
    type: CodeableConcept | None = None
```

A business identifier for a resource. The `system` namespace and `value` together uniquely identify an entity. The optional `type` uses coded values to classify the identifier -- the renderer checks `type.coding[].code` to distinguish DHIS2 UIDs from national IDs.

### HumanName

```python
class HumanName(BaseModel):
    use: str = ""
    family: str = ""
    given: list[str] = Field(default_factory=list)

    @property
    def display(self) -> str:
        given_str = " ".join(self.given)
        return f"{given_str} {self.family}".strip()
```

The `display` property joins all given names with spaces, appends the family name, and strips whitespace. This handles cases where either part is missing. For a name with `given: ["Abebe", "Bekele"]` and `family: "Tadesse"`, the display is `"Abebe Bekele Tadesse"`.

### Address

```python
class Address(BaseModel):
    use: str = ""
    line: list[str] = Field(default_factory=list)
    city: str = ""
    state: str = ""
    postalCode: str = ""
    country: str = ""

    @property
    def display(self) -> str:
        parts = list(self.line)
        if self.city:
            parts.append(self.city)
        if self.state:
            parts.append(self.state)
        if self.country:
            parts.append(self.country)
        return ", ".join(parts)
```

The `display` property builds a comma-separated string from available address parts. Note that `postalCode` is intentionally omitted from the display -- it is available for structured use but not shown in the rendered address line.

### Meta

```python
class Meta(BaseModel):
    profile: list[str] = Field(default_factory=list)
```

Resource metadata. The renderer only reads the `profile` list, which contains URLs of the StructureDefinitions this resource claims to conform to.

## Patient

```python
class Patient(BaseModel):
    resourceType: str = "Patient"
    id: str = ""
    meta: Meta | None = None
    identifier: list[Identifier] = Field(default_factory=list)
    name: list[HumanName] = Field(default_factory=list)
    gender: str = ""
    birthDate: str = ""
    active: bool | None = None
    address: list[Address] = Field(default_factory=list)
    extension: list[Extension] = Field(default_factory=list)
```

The Patient model carries four computed properties:

**`display_name`** returns the first name's display string, or falls back to the resource id, or `"Unknown"`:

```python
@property
def display_name(self) -> str:
    if self.name:
        return "; ".join(n.display for n in self.name)
    return self.id or "Unknown"
```

**`dhis2_uid`** scans identifiers for one typed with code `"RI"` (Resource Identifier in HL7's identifier type vocabulary, repurposed here for DHIS2 UIDs):

```python
@property
def dhis2_uid(self) -> str:
    for ident in self.identifier:
        if ident.type:
            for c in ident.type.coding:
                if c.code == "RI":
                    return ident.value
    return ""
```

**`national_id`** works the same way but looks for code `"NI"`.

**`org_unit_reference`** finds the DHIS2 org-unit extension and returns its reference string:

```python
@property
def org_unit_reference(self) -> str | None:
    for ext in self.extension:
        if "org-unit" in ext.url and ext.valueReference:
            return ext.valueReference.reference
    return None
```

**`identifier_display()`** is a method (not a property) that returns a list of dicts with human-friendly type labels. It maps coded types to readable names using a lookup table:

```python
def identifier_display(self) -> list[dict[str, str]]:
    label_map = {"RI": "DHIS2 UID", "NI": "National ID", "MR": "MRN"}
    result = []
    for ident in self.identifier:
        type_code = ""
        if ident.type:
            for c in ident.type.coding:
                type_code = c.code
                break
        result.append({
            "type": label_map.get(type_code, type_code or "ID"),
            "system": ident.system,
            "value": ident.value,
        })
    return result
```

## Questionnaire

### EnableWhen

```python
class EnableWhen(BaseModel):
    question: str = ""
    operator: str = ""
    answerCoding: Coding | None = None
    answerBoolean: bool | None = None
    answerString: str | None = None
```

Conditional display logic. A questionnaire item with `enableWhen` should only appear when the referenced `question` (by linkId) has an answer matching the specified value and `operator`. The renderer does not currently enforce this client-side, but the data is available for JavaScript enhancement.

### AnswerOption

```python
class AnswerOption(BaseModel):
    valueCoding: Coding | None = None
    valueString: str | None = None
```

A single selectable option for a questionnaire item. Can be either a coded value or a plain string.

### QuestionnaireItem

```python
class QuestionnaireItem(BaseModel):
    linkId: str = ""
    text: str = ""
    type: str = "string"
    required: bool = False
    answerValueSet: str = ""
    answerOption: list[AnswerOption] = Field(default_factory=list)
    enableWhen: list[EnableWhen] = Field(default_factory=list)
    item: list[QuestionnaireItem] = Field(default_factory=list)
```

This model is recursive -- an item can contain nested `item` children, supporting FHIR's group-based questionnaire structure. The `type` field determines what HTML input the renderer creates (`string` -> text input, `date` -> date picker, `choice` -> dropdown/radio, `boolean` -> checkbox, `group` -> fieldset wrapper).

### Questionnaire

```python
class Questionnaire(BaseModel):
    resourceType: str = "Questionnaire"
    id: str = ""
    meta: Meta | None = None
    url: str = ""
    name: str = ""
    title: str = ""
    status: str = ""
    description: str = ""
    subjectType: list[str] = Field(default_factory=list)
    item: list[QuestionnaireItem] = Field(default_factory=list)

    @property
    def display_title(self) -> str:
        return self.title or self.name or self.id
```

The `display_title` property provides a graceful fallback chain: use `title` if available, then `name`, then the resource `id`.

## QuestionnaireResponse

### QRAnswer

```python
class QRAnswer(BaseModel):
    valueString: str | None = None
    valueInteger: int | None = None
    valueDecimal: float | None = None
    valueBoolean: bool | None = None
    valueDate: str | None = None
    valueDateTime: str | None = None
    valueCoding: Coding | None = None
    valueUri: str | None = None

    def extract_value(self) -> object:
        if self.valueCoding is not None:
            return self.valueCoding.code
        if self.valueBoolean is not None:
            return self.valueBoolean
        for field in [
            "valueString", "valueInteger", "valueDecimal",
            "valueDate", "valueDateTime", "valueUri",
        ]:
            val = getattr(self, field)
            if val is not None:
                return val
        return ""
```

The `extract_value()` method implements FHIR's `value[x]` polymorphism. It checks each possible value type and returns the first non-None value. For `valueCoding`, it returns just the `code` string (not the full Coding object), which simplifies template rendering. The `valueBoolean` check comes before the generic loop because `False` is a valid answer that would be missed by a simple truthiness check.

### QRItem

```python
class QRItem(BaseModel):
    linkId: str = ""
    text: str = ""
    answer: list[QRAnswer] = Field(default_factory=list)
    item: list[QRItem] = Field(default_factory=list)
```

Like `QuestionnaireItem`, this is recursive to support nested groups.

### QuestionnaireResponse

```python
class QuestionnaireResponse(BaseModel):
    resourceType: str = "QuestionnaireResponse"
    id: str = ""
    meta: Meta | None = None
    questionnaire: str = ""
    status: str = ""
    authored: str = ""
    subject: Reference | None = None
    item: list[QRItem] = Field(default_factory=list)

    def extract_answers(self) -> dict[str, object]:
        answers: dict[str, object] = {}
        def walk(items: list[QRItem]) -> None:
            for item in items:
                if item.answer:
                    answers[item.linkId] = item.answer[0].extract_value()
                walk(item.item)
        walk(self.item)
        return answers
```

The `extract_answers()` method is the key method for response rendering. It recursively walks all items, flattening the nested structure into a flat dictionary keyed by `linkId`. This dict is passed to the questionnaire template, which uses `answers.get(item.linkId)` to pre-fill form fields. Note that it only takes the first answer for each item -- multi-valued answers are not yet supported.

## Terminology models

These models support the option resolution chain that connects Questionnaire dropdowns to coded values.

### Concept, CodeSystem, ValueSet

```python
class Concept(BaseModel):
    code: str = ""
    display: str = ""

class CodeSystem(BaseModel):
    resourceType: str = "CodeSystem"
    id: str = ""
    url: str = ""
    name: str = ""
    concept: list[Concept] = Field(default_factory=list)

class ComposeInclude(BaseModel):
    system: str = ""
    concept: list[Concept] = Field(default_factory=list)

class Compose(BaseModel):
    include: list[ComposeInclude] = Field(default_factory=list)

class ValueSet(BaseModel):
    resourceType: str = "ValueSet"
    id: str = ""
    url: str = ""
    name: str = ""
    compose: Compose | None = None
```

A `ValueSet` defines which codes are valid for a given context. Its `compose.include[]` entries either list concepts directly or reference a CodeSystem by `system` URL. The loader indexes both CodeSystems and ValueSets by URL, enabling the app to resolve a Questionnaire item's `answerValueSet` URL into a list of selectable options. See the [Architecture](architecture.md) chapter for the full resolution flow.
