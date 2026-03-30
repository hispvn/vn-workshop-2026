---
layout: section
---

# Part 1: What is FHIR?

---

# What is FHIR?

**Fast Healthcare Interoperability Resources** — an HL7 standard.

<v-clicks>

- **REST + JSON** — same web standards as modern APIs
- **Resource-based** — everything is a Resource (Patient, Immunization, Questionnaire...)
- **Profiling** — constrain base resources for your country/program
- **Open** — free specification, large ecosystem, no licensing

</v-clicks>

<div class="absolute bottom-8 left-12 right-12 text-sm opacity-50">

Standard: HL7 FHIR R4 (v4.0.1) — https://hl7.org/fhir/

</div>

---

# Why FHIR?

<div class="grid grid-cols-2 gap-6 mt-4">
<div>

### Before FHIR
- Custom point-to-point integrations
- Different formats per system
- Expensive to build and maintain
- Breaks when systems change

</div>
<div>

### With FHIR
- One standard API for all systems
- JSON/XML with defined structure
- Reusable profiles & terminology
- Large vendor/tool ecosystem

</div>
</div>

<div class="absolute bottom-8 left-12 right-12 p-3 bg-green-50 rounded-lg text-sm">

**DHIS2 context:** deployed in 80+ countries. FHIR provides a common language to exchange data between DHIS2, OpenMRS, lab systems, and national registries.

</div>

---

# FHIR Resources We Need

Over 140 resource types exist — we use these for the Lao EIR:

<div class="grid grid-cols-4 gap-3 mt-6 text-sm">

<div class="border rounded p-3 bg-blue-50">

**Patient**
Demographics, identifiers, address

</div>

<div class="border rounded p-3 bg-amber-50">

**Questionnaire**
Form definitions (program stages)

</div>

<div class="border rounded p-3 bg-amber-50">

**QuestionnaireResponse**
Submitted form data (events)

</div>

<div class="border rounded p-3 bg-green-50">

**Immunization**
Vaccine, date, dose, target disease

</div>

<div class="border rounded p-3 bg-green-50">

**CodeSystem / ValueSet**
Coded vocabularies (option sets)

</div>

<div class="border rounded p-3 bg-purple-50">

**Organization**
Facilities, org unit hierarchy

</div>

<div class="border rounded p-3 bg-purple-50">

**Bundle**
Search results, IPS documents

</div>

</div>

---

# Resource Structure — Patient Example

A Lao CHR patient as FHIR JSON:

```json {all|1|2-4|5-9|10-12|all}
{
  "resourceType": "Patient",
  "id": "lao-patient-001",
  "meta": { "profile": ["http://moh.gov.la/fhir/StructureDefinition/chr-patient"] },
  "identifier": [{
    "system": "http://moh.gov.la/fhir/id/client-health-id",
    "value": "15032019-2-6092",
    "type": { "coding": [{ "code": "CHR", "display": "Community Health Record ID" }] }
  }],
  "name": [{ "family": "Phommasan", "given": ["Khamla"] }],
  "gender": "female",
  "birthDate": "2019-03-15"
}
```
