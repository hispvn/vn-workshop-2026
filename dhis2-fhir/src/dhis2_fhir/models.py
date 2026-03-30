"""
Pydantic models for FHIR resources used in the DHIS2-FHIR renderer.

These models represent the subset of FHIR R4 fields that we read from
SUSHI-generated JSON. They are intentionally permissive (most fields optional)
because we parse instance data that may not include every element.
"""

from __future__ import annotations

from pydantic import BaseModel, Field

# ---------------------------------------------------------------------------
# Shared building blocks
# ---------------------------------------------------------------------------


class Coding(BaseModel):
    system: str = ""
    code: str = ""
    display: str = ""


class CodeableConcept(BaseModel):
    coding: list[Coding] = Field(default_factory=list)
    text: str = ""


class Reference(BaseModel):
    reference: str = ""
    display: str = ""


class Extension(BaseModel):
    url: str = ""
    valueReference: Reference | None = None
    valueString: str | None = None
    valueCode: str | None = None


class Identifier(BaseModel):
    system: str = ""
    value: str = ""
    type: CodeableConcept | None = None


class HumanName(BaseModel):
    use: str = ""
    family: str = ""
    given: list[str] = Field(default_factory=list)

    @property
    def display(self) -> str:
        given_str = " ".join(self.given)
        return f"{given_str} {self.family}".strip()


class ContactPoint(BaseModel):
    system: str = ""  # phone | email | ...
    value: str = ""
    use: str = ""  # home | work | mobile | ...


class Address(BaseModel):
    use: str = ""
    line: list[str] = Field(default_factory=list)
    city: str = ""
    district: str = ""
    state: str = ""
    postalCode: str = ""
    country: str = ""

    @property
    def display(self) -> str:
        parts = list(self.line)
        if self.city:
            parts.append(self.city)
        if self.district:
            parts.append(self.district)
        if self.state:
            parts.append(self.state)
        if self.country:
            parts.append(self.country)
        return ", ".join(parts)


class Meta(BaseModel):
    profile: list[str] = Field(default_factory=list)


# ---------------------------------------------------------------------------
# Patient
# ---------------------------------------------------------------------------


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
    telecom: list[ContactPoint] = Field(default_factory=list)
    extension: list[Extension] = Field(default_factory=list)

    @property
    def display_name(self) -> str:
        if self.name:
            return "; ".join(n.display for n in self.name)
        return self.id or "Unknown"

    @property
    def dhis2_uid(self) -> str:
        for ident in self.identifier:
            if ident.type:
                for c in ident.type.coding:
                    if c.code == "RI":
                        return ident.value
        return ""

    @property
    def national_id(self) -> str:
        for ident in self.identifier:
            if ident.type:
                for c in ident.type.coding:
                    if c.code == "NI":
                        return ident.value
        return ""

    @property
    def org_unit_reference(self) -> str | None:
        for ext in self.extension:
            if "org-unit" in ext.url and ext.valueReference:
                return ext.valueReference.reference
        return None

    def identifier_by_type(self, type_code: str) -> str:
        """Look up identifier value by type code (RI, NI, CHR, PPN, etc.)."""
        for ident in self.identifier:
            if ident.type:
                for c in ident.type.coding:
                    if c.code == type_code:
                        return ident.value
        return ""

    @property
    def phone_numbers(self) -> list[str]:
        return [t.value for t in self.telecom if t.system == "phone"]

    def identifier_display(self) -> list[dict[str, str]]:
        """Return identifiers with human-friendly type labels."""
        label_map = {
            "RI": "DHIS2",
            "NI": "National",
            "MR": "MRN",
            "CHR": "CHR",
            "CVID": "CVID",
            "GREENCARD": "Green Card",
            "FAMILYBOOK": "Family Book",
            "INS": "Insurance",
            "PPN": "Passport",
        }
        result = []
        for ident in self.identifier:
            type_code = ""
            if ident.type:
                for c in ident.type.coding:
                    type_code = c.code
                    break
            result.append(
                {
                    "type": label_map.get(type_code, type_code or "ID"),
                    "system": ident.system,
                    "value": ident.value,
                }
            )
        return result


# ---------------------------------------------------------------------------
# Observation
# ---------------------------------------------------------------------------


class Quantity(BaseModel):
    value: float | None = None
    unit: str = ""
    system: str = ""
    code: str = ""

    @property
    def display(self) -> str:
        if self.value is not None:
            return f"{self.value} {self.unit}".strip()
        return ""


class Observation(BaseModel):
    resourceType: str = "Observation"
    id: str = ""
    meta: Meta | None = None
    status: str = ""
    code: CodeableConcept | None = None
    subject: Reference | None = None
    encounter: Reference | None = None
    effectiveDateTime: str = ""
    category: list[CodeableConcept] = Field(default_factory=list)
    valueQuantity: Quantity | None = None
    valueCodeableConcept: CodeableConcept | None = None
    valueString: str | None = None
    valueBoolean: bool | None = None
    valueInteger: int | None = None
    valueDateTime: str | None = None

    @property
    def code_display(self) -> str:
        if self.code:
            for c in self.code.coding:
                if c.display:
                    return c.display
            return self.code.text or (self.code.coding[0].code if self.code.coding else "")
        return self.id

    @property
    def category_display(self) -> str:
        for cat in self.category:
            for c in cat.coding:
                if c.display:
                    return c.display
        return ""

    @property
    def value_display(self) -> str:
        if self.valueQuantity:
            return self.valueQuantity.display
        if self.valueCodeableConcept:
            for c in self.valueCodeableConcept.coding:
                if c.display:
                    return c.display
            return self.valueCodeableConcept.text
        if self.valueString is not None:
            return self.valueString
        if self.valueBoolean is not None:
            return "Yes" if self.valueBoolean else "No"
        if self.valueInteger is not None:
            return str(self.valueInteger)
        if self.valueDateTime:
            return self.valueDateTime
        return ""


# ---------------------------------------------------------------------------
# Questionnaire
# ---------------------------------------------------------------------------


class EnableWhen(BaseModel):
    question: str = ""
    operator: str = ""
    answerCoding: Coding | None = None
    answerBoolean: bool | None = None
    answerString: str | None = None


class AnswerOption(BaseModel):
    valueCoding: Coding | None = None
    valueString: str | None = None


class QuestionnaireItem(BaseModel):
    linkId: str = ""
    text: str = ""
    type: str = "string"
    required: bool = False
    answerValueSet: str = ""
    answerOption: list[AnswerOption] = Field(default_factory=list)
    enableWhen: list[EnableWhen] = Field(default_factory=list)
    item: list[QuestionnaireItem] = Field(default_factory=list)


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


# ---------------------------------------------------------------------------
# QuestionnaireResponse
# ---------------------------------------------------------------------------


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
        """Return the first non-None answer value (code string for Coding)."""
        if self.valueCoding is not None:
            return self.valueCoding.code
        if self.valueBoolean is not None:
            return self.valueBoolean
        for field in [
            "valueString",
            "valueInteger",
            "valueDecimal",
            "valueDate",
            "valueDateTime",
            "valueUri",
        ]:
            val = getattr(self, field)
            if val is not None:
                return val
        return ""


class QRItem(BaseModel):
    linkId: str = ""
    text: str = ""
    answer: list[QRAnswer] = Field(default_factory=list)
    item: list[QRItem] = Field(default_factory=list)


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
        """Flatten all answers into a dict keyed by linkId."""
        answers: dict[str, object] = {}

        def walk(items: list[QRItem]) -> None:
            for item in items:
                if item.answer:
                    answers[item.linkId] = item.answer[0].extract_value()
                walk(item.item)

        walk(self.item)
        return answers


# ---------------------------------------------------------------------------
# CodeSystem / ValueSet (for option resolution)
# ---------------------------------------------------------------------------


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


# ---------------------------------------------------------------------------
# Immunization
# ---------------------------------------------------------------------------


class ImmunizationProtocol(BaseModel):
    doseNumberPositiveInt: int | None = None
    targetDisease: list[CodeableConcept] = Field(default_factory=list)


class ImmunizationPerformer(BaseModel):
    actor: Reference | None = None


class Immunization(BaseModel):
    resourceType: str = "Immunization"
    id: str = ""
    meta: Meta | None = None
    status: str = "completed"
    vaccineCode: CodeableConcept | None = None
    patient: Reference | None = None
    occurrenceDateTime: str = ""
    lotNumber: str = ""
    site: CodeableConcept | None = None
    route: CodeableConcept | None = None
    performer: list[ImmunizationPerformer] = Field(default_factory=list)
    protocolApplied: list[ImmunizationProtocol] = Field(default_factory=list)
    location: Reference | None = None
    extension: list[Extension] = Field(default_factory=list)

    @property
    def vaccine_display(self) -> str:
        if self.vaccineCode:
            for c in self.vaccineCode.coding:
                if c.display:
                    return c.display
            return self.vaccineCode.text or (self.vaccineCode.coding[0].code if self.vaccineCode.coding else "")
        return ""

    @property
    def dose_number(self) -> int | None:
        if self.protocolApplied:
            return self.protocolApplied[0].doseNumberPositiveInt
        return None

    @property
    def target_disease_display(self) -> str:
        if self.protocolApplied:
            diseases = []
            for td in self.protocolApplied[0].targetDisease:
                for c in td.coding:
                    if c.display:
                        diseases.append(c.display)
                        break
            return ", ".join(diseases)
        return ""

    @property
    def patient_id(self) -> str:
        if self.patient and self.patient.reference:
            return self.patient.reference.split("/")[-1]
        return ""


# ---------------------------------------------------------------------------
# OperationOutcome (for FHIR API error responses)
# ---------------------------------------------------------------------------


class OperationOutcomeIssue(BaseModel):
    severity: str  # fatal | error | warning | information
    code: str  # not-found | invalid | conflict | ...
    diagnostics: str = ""


class OperationOutcome(BaseModel):
    resourceType: str = "OperationOutcome"
    issue: list[OperationOutcomeIssue] = Field(default_factory=list)


# ---------------------------------------------------------------------------
# Bundle (for FHIR search results)
# ---------------------------------------------------------------------------


class BundleLink(BaseModel):
    relation: str
    url: str


class BundleEntry(BaseModel):
    fullUrl: str = ""
    resource: dict = Field(default_factory=dict)


class SearchBundle(BaseModel):
    resourceType: str = "Bundle"
    type: str = "searchset"
    total: int = 0
    link: list[BundleLink] = Field(default_factory=list)
    entry: list[BundleEntry] = Field(default_factory=list)
