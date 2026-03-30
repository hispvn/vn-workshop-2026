# Instances

An **Instance** is a concrete example of a FHIR resource. While profiles define the *rules* a resource must follow, instances are actual *data* that conforms to those rules. Instances serve multiple purposes: they document expected payloads, feed test suites, populate the examples tab in your Implementation Guide, and validate that your profiles work as intended.

## Syntax reference

```fsh
Instance:    <name>
InstanceOf:  <resource-or-profile>
Usage:       #example | #definition | #inline
Title:       "<title>"
Description: "<description>"

* <path> = <value>
```

### Usage values

| Usage | Purpose |
|-------|---------|
| `#example` | An illustrative example included in the IG (the default). |
| `#definition` | A definitional resource (e.g., a SearchParameter or CapabilityStatement) that is part of the IG specification itself. |
| `#inline` | An instance that is not standalone but will be included inside another resource (e.g., a contained resource). |

## Example 1: Simple Patient instance

A minimal Patient instance to illustrate the basics.

```fsh
Instance:    PatientExample
InstanceOf:  Patient
Usage:       #example
Title:       "Patient Example"
Description: "A simple example patient."

* name.family = "Banda"
* name.given[0] = "Grace"
* gender = #female
* birthDate = "1990-05-15"
```

Code values like `#female` use the `#` prefix. Dates and strings use quotes.

## Example 2: DHIS2 Patient with realistic data

A more detailed instance using a DHIS2 Tracked Entity Instance UID as an identifier, along with a national ID.

```fsh
Instance:    DHIS2PatientExample
InstanceOf:  DHIS2Patient
Usage:       #example
Title:       "DHIS2 Patient Example"
Description: "A patient originating from DHIS2 Tracker with UID DXz2k5eGbri."

* identifier[0].system = "https://dhis2.org/tracked-entity-instance"
* identifier[0].value = "DXz2k5eGbri"
* identifier[1].system = "https://example.org/national-id"
* identifier[1].value = "MWI-2024-98761"
* name[0].family = "Phiri"
* name[0].given[0] = "Chimwemwe"
* name[0].given[1] = "James"
* gender = #male
* birthDate = "1985-11-22"
* address[0].country = "MWI"
* address[0].state = "Central Region"
* address[0].district = "Lilongwe"
```

This instance conforms to the `DHIS2Patient` profile defined in the Profiles section. SUSHI validates the instance against the profile rules. If you forget a required element (e.g., leave out `identifier`), SUSHI will report a warning.

## Example 3: Observation instance

An Observation representing a DHIS2 data value -- in this case, a malaria test result.

```fsh
Instance:    MalariaTestResult
InstanceOf:  Observation
Usage:       #example
Title:       "Malaria RDT Result"
Description: "A rapid diagnostic test result for malaria."

* status = #final
* code = http://loinc.org#70568-5 "Malaria rapid diagnostic test"
* subject = Reference(DHIS2PatientExample)
* effectiveDateTime = "2025-01-10"
* valueCodeableConcept = http://snomed.info/sct#10828004 "Positive"
```

Notice the `Reference(DHIS2PatientExample)` -- SUSHI resolves this to the full URL of the patient instance. You refer to other instances by their FSH name, and SUSHI handles the wiring.

## Generated output

The DHIS2 Patient instance produces JSON like this:

```json
{
  "resourceType": "Patient",
  "id": "DHIS2PatientExample",
  "meta": {
    "profile": [
      "http://example.org/fhir/StructureDefinition/dhis2-patient"
    ]
  },
  "identifier": [
    {
      "system": "https://dhis2.org/tracked-entity-instance",
      "value": "DXz2k5eGbri"
    },
    {
      "system": "https://example.org/national-id",
      "value": "MWI-2024-98761"
    }
  ],
  "name": [
    {
      "family": "Phiri",
      "given": ["Chimwemwe", "James"]
    }
  ],
  "gender": "male",
  "birthDate": "1985-11-22",
  "address": [
    {
      "country": "MWI",
      "state": "Central Region",
      "district": "Lilongwe"
    }
  ]
}
```

Notice how the `meta.profile` field is automatically set because the instance declares `InstanceOf: DHIS2Patient`. This tells validators which profile to check the resource against.

## Tips

- Use array indexing (`[0]`, `[1]`) for repeating elements like `identifier` and `name.given`.
- Reference other instances by their FSH name, not their URL.
- If your instance does not conform to the profile, SUSHI will emit warnings. Treat these as errors and fix them.
- Instances with `Usage: #example` appear in the Examples tab of the IG publisher output.

## Example 4: Questionnaire and QuestionnaireResponse instances

Questionnaire and QuestionnaireResponse instances model DHIS2 program stages and events. The Questionnaire defines the form items (data elements), and the QuestionnaireResponse captures submitted answers (data values).

```fsh
Instance:    MalariaScreeningForm
InstanceOf:  Questionnaire
Usage:       #definition
Title:       "Malaria Screening Form"
Description: "Questionnaire representing a DHIS2 malaria screening program stage."

* url = "http://dhis2.org/fhir/Questionnaire/malaria-screening"
* status = #active
* title = "Malaria Screening"
* item[0].linkId = "temperature"
* item[0].text = "Body temperature (C)"
* item[0].type = #decimal
* item[0].required = true
* item[1].linkId = "rdt-result"
* item[1].text = "RDT result"
* item[1].type = #choice
* item[1].answerValueSet = "http://dhis2.org/fhir/ValueSet/rdt-results"
* item[1].required = true
* item[2].linkId = "treatment-given"
* item[2].text = "Treatment given"
* item[2].type = #choice
* item[2].answerValueSet = "http://dhis2.org/fhir/ValueSet/malaria-treatments"
* item[2].enableWhen[0].question = "rdt-result"
* item[2].enableWhen[0].operator = #=
* item[2].enableWhen[0].answerCoding = http://dhis2.org/fhir/CodeSystem/rdt-results#positive
```

The `answerValueSet` binds choice items to a ValueSet (representing a DHIS2 option set). The `enableWhen` conditionally shows the treatment question only when the RDT result is positive.

```fsh
Instance:    MalariaScreeningResponse001
InstanceOf:  QuestionnaireResponse
Usage:       #example
Title:       "Malaria Screening Response"
Description: "A completed malaria screening event from DHIS2."

* questionnaire = "http://dhis2.org/fhir/Questionnaire/malaria-screening"
* status = #completed
* subject = Reference(DHIS2PatientExample)
* authored = "2025-01-10T14:30:00+02:00"
* item[0].linkId = "temperature"
* item[0].answer[0].valueDecimal = 38.2
* item[1].linkId = "rdt-result"
* item[1].answer[0].valueCoding = http://dhis2.org/fhir/CodeSystem/rdt-results#positive "Positive"
* item[2].linkId = "treatment-given"
* item[2].answer[0].valueCoding = http://dhis2.org/fhir/CodeSystem/malaria-treatments#act "ACT"
```

The QuestionnaireResponse references both the Questionnaire (via `questionnaire`) and the patient (via `subject`). For anonymous event programs, omit the `subject` line.

## Exercise

Open `exercises/ch04-instances/` and complete the exercise. You will create an instance of the `DHIS2Observation` profile representing a weight measurement, referencing the DHIS2 patient example.
