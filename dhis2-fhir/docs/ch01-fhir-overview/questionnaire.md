# Questionnaire and QuestionnaireResponse

FHIR provides two resources for structured data collection: **Questionnaire** defines the form (questions, answer types, logic), and **QuestionnaireResponse** captures the filled-in answers. Together they model the complete lifecycle of form-based data collection -- from designing the form to recording the responses.

These resources are particularly relevant for public health systems where standardized data collection forms are central to program delivery. While the names suggest a clinical questionnaire, these resources are general-purpose form definitions -- they model any structured data collection instrument, from patient intake forms to facility assessments, disease notification forms, and stock reports.

## Questionnaire

A Questionnaire defines the structure of a form: which questions to ask, what type of answers to accept, and how questions are organized.

### Key Elements

| Element | Type | Cardinality | Description |
|---------|------|-------------|-------------|
| `url` | uri | 0..1 | Canonical identifier for this questionnaire |
| `status` | code | 1..1 | `draft` \| `active` \| `retired` \| `unknown` (required) |
| `title` | string | 0..1 | Human-readable title |
| `date` | dateTime | 0..1 | When the questionnaire was last changed |
| `item` | BackboneElement[] | 0..* | Questions and sections in the form |
| `item.linkId` | string | 1..1 | Unique identifier for this item (used to link responses) |
| `item.text` | string | 0..1 | The question text displayed to the user |
| `item.type` | code | 1..1 | `group` \| `display` \| `boolean` \| `decimal` \| `integer` \| `date` \| `string` \| `choice` \| `quantity` \| ... |
| `item.required` | boolean | 0..1 | Whether an answer is mandatory |
| `item.answerOption` | BackboneElement[] | 0..* | Permitted answers for choice-type items |
| `item.enableWhen` | BackboneElement[] | 0..* | Conditional display logic |
| `item.item` | BackboneElement[] | 0..* | Nested sub-items (for groups or follow-up questions) |

### Questionnaire JSON Example

This example models a simplified antenatal care visit form:

```json
{
  "resourceType": "Questionnaire",
  "id": "anc-visit-form",
  "url": "http://dhis2.org/fhir/Questionnaire/anc-visit-form",
  "status": "active",
  "title": "ANC Visit Form",
  "item": [
    {
      "linkId": "visit-date",
      "text": "Visit date",
      "type": "date",
      "required": true
    },
    {
      "linkId": "weight",
      "text": "Weight (kg)",
      "type": "decimal",
      "required": true
    },
    {
      "linkId": "bp-systolic",
      "text": "Systolic blood pressure (mmHg)",
      "type": "integer",
      "required": true
    },
    {
      "linkId": "bp-diastolic",
      "text": "Diastolic blood pressure (mmHg)",
      "type": "integer",
      "required": true
    },
    {
      "linkId": "hiv-test-done",
      "text": "Was an HIV test performed?",
      "type": "boolean",
      "required": true
    },
    {
      "linkId": "hiv-test-result",
      "text": "HIV test result",
      "type": "choice",
      "enableWhen": [
        {
          "question": "hiv-test-done",
          "operator": "=",
          "answerBoolean": true
        }
      ],
      "answerOption": [
        {
          "valueCoding": {
            "system": "http://dhis2.org/option/hiv-result",
            "code": "positive",
            "display": "Positive"
          }
        },
        {
          "valueCoding": {
            "system": "http://dhis2.org/option/hiv-result",
            "code": "negative",
            "display": "Negative"
          }
        },
        {
          "valueCoding": {
            "system": "http://dhis2.org/option/hiv-result",
            "code": "indeterminate",
            "display": "Indeterminate"
          }
        }
      ]
    }
  ]
}
```

Notice the `enableWhen` on the HIV test result question -- it only appears when the user answers "yes" to whether an HIV test was performed. The `linkId` is the unique key that ties each question to its answer in the response.

### Binding Items to Value Sets with answerValueSet

When a choice item draws its options from a maintained terminology rather than inline `answerOption` entries, you can bind it to a ValueSet using `answerValueSet`. This is the preferred approach for DHIS2 option sets, because the options are defined once (in a CodeSystem and ValueSet) and reused across multiple Questionnaire items.

```json
{
  "linkId": "malaria-species",
  "text": "Malaria species",
  "type": "choice",
  "answerValueSet": "http://dhis2.org/fhir/ValueSet/malaria-species"
}
```

The referenced ValueSet includes or expands codes from a CodeSystem. The form renderer retrieves the ValueSet to populate the dropdown or radio buttons. This separation keeps the Questionnaire definition stable even when the option list is updated.

### Conditional Logic with enableWhen

The `enableWhen` element controls whether a question is visible (and answerable) based on the value of another item. Each `enableWhen` entry specifies a `question` (the linkId of the controlling item), an `operator` (`=`, `!=`, `exists`, `>`, `<`, etc.), and an expected answer value.

When multiple `enableWhen` entries are present, the `enableBehavior` element determines whether **all** conditions must be met or **any** single condition suffices:

```json
{
  "linkId": "treatment-details",
  "text": "Describe the treatment given",
  "type": "string",
  "enableWhen": [
    {
      "question": "diagnosis-confirmed",
      "operator": "=",
      "answerBoolean": true
    },
    {
      "question": "treatment-given",
      "operator": "=",
      "answerBoolean": true
    }
  ],
  "enableBehavior": "all"
}
```

This maps directly to DHIS2 program rules that show or hide data elements based on the values of other data elements in the same event.

### Anonymous Form Example: Disease Notification

Not every form is linked to a patient. Event programs in DHIS2 collect data without a tracked entity -- for example, a disease notification submitted by a facility. The Questionnaire still defines the form; the QuestionnaireResponse simply omits the `subject` element:

```json
{
  "resourceType": "Questionnaire",
  "id": "disease-notification",
  "url": "http://dhis2.org/fhir/Questionnaire/disease-notification",
  "status": "active",
  "title": "Weekly Disease Notification",
  "item": [
    {
      "linkId": "reporting-period",
      "text": "Reporting week",
      "type": "date",
      "required": true
    },
    {
      "linkId": "disease",
      "text": "Disease",
      "type": "choice",
      "required": true,
      "answerValueSet": "http://dhis2.org/fhir/ValueSet/notifiable-diseases"
    },
    {
      "linkId": "case-count",
      "text": "Number of cases",
      "type": "integer",
      "required": true
    },
    {
      "linkId": "deaths",
      "text": "Number of deaths",
      "type": "integer",
      "required": false
    }
  ]
}
```

A completed response for this form has no `subject` -- it is anonymous, facility-level data:

```json
{
  "resourceType": "QuestionnaireResponse",
  "questionnaire": "http://dhis2.org/fhir/Questionnaire/disease-notification",
  "status": "completed",
  "authored": "2024-07-01T08:00:00+02:00",
  "item": [
    { "linkId": "reporting-period", "answer": [{ "valueDate": "2024-06-24" }] },
    { "linkId": "disease", "answer": [{ "valueCoding": { "system": "http://dhis2.org/fhir/CodeSystem/notifiable-diseases", "code": "CHOLERA", "display": "Cholera" } }] },
    { "linkId": "case-count", "answer": [{ "valueInteger": 12 }] },
    { "linkId": "deaths", "answer": [{ "valueInteger": 1 }] }
  ]
}
```

## QuestionnaireResponse

A QuestionnaireResponse records the answers to a specific Questionnaire for a specific patient.

### Key Elements

| Element | Type | Cardinality | Description |
|---------|------|-------------|-------------|
| `questionnaire` | canonical | 0..1 | Reference to the Questionnaire being answered |
| `status` | code | 1..1 | `in-progress` \| `completed` \| `amended` \| `stopped` (required) |
| `subject` | Reference(Patient) | 0..1 | The patient this response is about |
| `authored` | dateTime | 0..1 | When the response was captured |
| `author` | Reference(Practitioner) | 0..1 | Who recorded the answers |
| `item` | BackboneElement[] | 0..* | Answers, matching the questionnaire items by linkId |
| `item.linkId` | string | 1..1 | Must match the corresponding Questionnaire item |
| `item.answer` | BackboneElement[] | 0..* | The answer value(s) |

### QuestionnaireResponse JSON Example

```json
{
  "resourceType": "QuestionnaireResponse",
  "id": "anc-visit-response-001",
  "questionnaire": "http://dhis2.org/fhir/Questionnaire/anc-visit-form",
  "status": "completed",
  "subject": {
    "reference": "Patient/mw-patient-5428",
    "display": "Grace Banda"
  },
  "authored": "2024-06-10T09:30:00+02:00",
  "item": [
    {
      "linkId": "visit-date",
      "answer": [{ "valueDate": "2024-06-10" }]
    },
    {
      "linkId": "weight",
      "answer": [{ "valueDecimal": 62.5 }]
    },
    {
      "linkId": "bp-systolic",
      "answer": [{ "valueInteger": 120 }]
    },
    {
      "linkId": "bp-diastolic",
      "answer": [{ "valueInteger": 80 }]
    },
    {
      "linkId": "hiv-test-done",
      "answer": [{ "valueBoolean": true }]
    },
    {
      "linkId": "hiv-test-result",
      "answer": [
        {
          "valueCoding": {
            "system": "http://dhis2.org/option/hiv-result",
            "code": "negative",
            "display": "Negative"
          }
        }
      ]
    }
  ]
}
```

Each answer uses a `value[x]` field matching the question type: `valueDate` for date items, `valueDecimal` for decimal items, `valueCoding` for choice items. The `linkId` in each response item must exactly match the corresponding `linkId` in the Questionnaire.

## Common Patterns and Gotchas

**linkId is the glue.** The `linkId` ties questions to answers. It must be unique within a Questionnaire and must match exactly between the Questionnaire and QuestionnaireResponse. Mismatched linkIds are a common source of validation errors.

**Nested items.** Questionnaire items of type `group` can contain nested items, forming a hierarchy. The QuestionnaireResponse mirrors this nesting.

**enableWhen logic.** Conditional questions controlled by `enableWhen` should only have answers in the response when the condition is met. Including an answer for a disabled question may cause validation failures in strict implementations.

**Extraction.** Raw QuestionnaireResponse data can be "extracted" into proper FHIR resources (Observations, Conditions, etc.) using the StructureMap or definition-based extraction approach. This converts form data into clinically meaningful resources.

**Multiple answers.** A single item can have multiple answers (e.g., "select all that apply"). Each answer is a separate entry in the `answer` array.

## Relationship to DHIS2

Questionnaire and QuestionnaireResponse are the primary FHIR representation for DHIS2 program stages and events. The mapping is structural: a program stage *is* a form definition, and an event *is* a submitted form.

### Concept Mapping

| DHIS2 Concept | FHIR Resource / Element | Notes |
|---|---|---|
| Program Stage | Questionnaire | The form definition. One Questionnaire per program stage. |
| Data Element | Questionnaire.item | `linkId` = data element UID, `text` = data element name, `type` maps from the data element value type. |
| Option Set | CodeSystem + ValueSet | The option set becomes a CodeSystem (codes) and a ValueSet (grouping). The Questionnaire item binds via `answerValueSet`. |
| Program Rule (show/hide) | Questionnaire.item.enableWhen | Rules that conditionally display fields map to `enableWhen` conditions. |
| Event | QuestionnaireResponse | A submitted form. One QuestionnaireResponse per event. |
| Data Value | QuestionnaireResponse.item.answer | `linkId` matches the data element UID; `value[x]` carries the recorded value. |
| TEI link | QuestionnaireResponse.subject | Present for tracker programs (references the Patient). Absent for event programs (anonymous data collection). |

### Data Element Type Mapping

| DHIS2 Value Type | Questionnaire item type | answer value[x] |
|---|---|---|
| TEXT | `string` | `valueString` |
| LONG_TEXT | `text` | `valueString` |
| INTEGER | `integer` | `valueInteger` |
| NUMBER | `decimal` | `valueDecimal` |
| BOOLEAN | `boolean` | `valueBoolean` |
| DATE | `date` | `valueDate` |
| DATETIME | `dateTime` | `valueDateTime` |
| Option Set (any type) | `choice` | `valueCoding` |

This makes Questionnaire/QuestionnaireResponse a natural and lossless representation for DHIS2's form-based data collection model. The form structure, conditional logic, and coded option lists all have direct counterparts in FHIR.
