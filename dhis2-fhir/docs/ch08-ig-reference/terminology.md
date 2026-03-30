# Terminology

The DHIS2-FHIR IG defines 17 CodeSystem/ValueSet pairs organized into three categories: **system types** used in profiles and extensions, **organisation unit classifications** used in Organization.type, and **option sets** used in Questionnaire `answerValueSet` bindings.

Every CodeSystem in the IG follows a consistent pattern:
- `caseSensitive = true` (DHIS2 codes are UPPER_SNAKE_CASE)
- `content = #complete` (all codes are included)
- `experimental = false` (intended for real use)
- A companion ValueSet that includes all codes from the CodeSystem

## System Types

These code systems represent DHIS2 internal enumerations used in profiles and extensions.

### DHIS2DataElementTypeCS/VS

**Purpose:** Enumerates the 20 value types that a DHIS2 data element can hold. Bound to `DHIS2DataElementExtension.valueType` with `required` strength.

**DHIS2 Context:** Every data element declares a `valueType` that constrains what kind of data can be entered. When mapping to FHIR, the value type determines which `value[x]` type to use.

| Code | Display | FHIR Mapping |
|------|---------|--------------|
| `TEXT` | Text | valueString |
| `LONG_TEXT` | Long text | valueString |
| `NUMBER` | Number | valueQuantity |
| `INTEGER` | Integer | valueInteger |
| `INTEGER_POSITIVE` | Positive Integer | valueInteger (min=1) |
| `INTEGER_NEGATIVE` | Negative Integer | valueInteger (max=-1) |
| `INTEGER_ZERO_OR_POSITIVE` | Zero or Positive Integer | valueInteger (min=0) |
| `PERCENTAGE` | Percentage | valueQuantity (unit=%) |
| `BOOLEAN` | Boolean | valueBoolean |
| `TRUE_ONLY` | True Only | valueBoolean |
| `DATE` | Date | valueDateTime |
| `DATETIME` | Date and Time | valueDateTime |
| `TIME` | Time | valueTime |
| `PHONE_NUMBER` | Phone Number | valueString / ContactPoint |
| `EMAIL` | Email | valueString / ContactPoint |
| `URL` | URL | valueUrl |
| `USERNAME` | Username | valueString |
| `COORDINATE` | Coordinate | Extension (lat/lon) |
| `TRACKER_ASSOCIATE` | Tracker Associate | valueReference(Patient) |
| `FILE_RESOURCE` | File Resource | valueAttachment |
| `ORGANISATION_UNIT` | Organisation Unit | valueReference(Organization) |
| `AGE` | Age | valueQuantity (unit=years) |

```fsh
CodeSystem: DHIS2DataElementTypeCS
Id: dhis2-data-element-type
Title: "DHIS2 Data Element Value Type"
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #TEXT "Text"
* #LONG_TEXT "Long text"
* #NUMBER "Number"
* #INTEGER "Integer"
* #INTEGER_POSITIVE "Positive Integer"
* #INTEGER_NEGATIVE "Negative Integer"
* #INTEGER_ZERO_OR_POSITIVE "Zero or Positive Integer"
* #PERCENTAGE "Percentage"
* #BOOLEAN "Boolean"
* #TRUE_ONLY "True Only"
* #DATE "Date"
* #DATETIME "Date and Time"
* #TIME "Time"
* #PHONE_NUMBER "Phone Number"
* #EMAIL "Email"
* #URL "URL"
* #USERNAME "Username"
* #COORDINATE "Coordinate"
* #TRACKER_ASSOCIATE "Tracker Associate"
* #FILE_RESOURCE "File Resource"
* #ORGANISATION_UNIT "Organisation Unit"
* #AGE "Age"

ValueSet: DHIS2DataElementTypeVS
Id: dhis2-data-element-type-vs
Title: "DHIS2 Data Element Value Types"
* include codes from system DHIS2DataElementTypeCS
```

### DHIS2ProgramTypeCS/VS

**Purpose:** Classifies DHIS2 programs. Bound to `DHIS2ProgramExtension` with `example` strength.

| Code | Display | Description |
|------|---------|-------------|
| `WITH_REGISTRATION` | Tracker program | Follows individuals over time (ANC, HIV, immunization) |
| `WITHOUT_REGISTRATION` | Event program | Standalone anonymous events (case reports, surveillance) |

```fsh
CodeSystem: DHIS2ProgramTypeCS
Id: dhis2-program-type
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #WITH_REGISTRATION "Tracker program"
* #WITHOUT_REGISTRATION "Event program"

ValueSet: DHIS2ProgramTypeVS
Id: dhis2-program-type-vs
* include codes from system DHIS2ProgramTypeCS
```

### DHIS2EventStatusCS/VS

**Purpose:** Lifecycle status codes for DHIS2 tracker events.

| Code | Display | FHIR Encounter Status |
|------|---------|----------------------|
| `ACTIVE` | Active | in-progress |
| `COMPLETED` | Completed | finished |
| `SCHEDULE` | Schedule | planned |
| `OVERDUE` | Overdue | in-progress (with flag) |
| `SKIPPED` | Skipped | cancelled |
| `VISITED` | Visited | finished |

```fsh
CodeSystem: DHIS2EventStatusCS
Id: dhis2-event-status
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #ACTIVE "Active"
* #COMPLETED "Completed"
* #SCHEDULE "Schedule"
* #OVERDUE "Overdue"
* #SKIPPED "Skipped"
* #VISITED "Visited"

ValueSet: DHIS2EventStatusVS
Id: dhis2-event-status-vs
* include codes from system DHIS2EventStatusCS
```

### DHIS2EnrollmentStatusCS/VS

**Purpose:** Lifecycle status codes for DHIS2 tracker enrollments.

| Code | Display | FHIR EpisodeOfCare Status |
|------|---------|--------------------------|
| `ACTIVE` | Active | active |
| `COMPLETED` | Completed | finished |
| `CANCELLED` | Cancelled | cancelled |

```fsh
CodeSystem: DHIS2EnrollmentStatusCS
Id: dhis2-enrollment-status
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #ACTIVE "Active"
* #COMPLETED "Completed"
* #CANCELLED "Cancelled"

ValueSet: DHIS2EnrollmentStatusVS
Id: dhis2-enrollment-status-vs
* include codes from system DHIS2EnrollmentStatusCS
```

### DHIS2AggregationTypeCS/VS

**Purpose:** How values are aggregated across org units and time periods. Bound to `DHIS2DataElementExtension.aggregationType` with `required` strength.

| Code | Display | Use Case |
|------|---------|----------|
| `SUM` | Sum | Counts and additive quantities |
| `AVERAGE` | Average | Rates and non-additive quantities |
| `COUNT` | Count | Number of non-empty values |
| `NONE` | None | No aggregation performed |
| `LAST` | Last value | Stock/inventory levels |
| `MIN` | Min | Minimum value |
| `MAX` | Max | Maximum value |

```fsh
CodeSystem: DHIS2AggregationTypeCS
Id: dhis2-aggregation-type
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #SUM "Sum"
* #AVERAGE "Average"
* #COUNT "Count"
* #NONE "None"
* #LAST "Last value"
* #MIN "Min"
* #MAX "Max"

ValueSet: DHIS2AggregationTypeVS
Id: dhis2-aggregation-type-vs
* include codes from system DHIS2AggregationTypeCS
```

## Organisation Unit Classifications

These code systems classify DHIS2 organisation units by hierarchy level and facility type. Both are used in `Organization.type`.

### DHIS2OrgUnitLevelCS/VS

**Purpose:** Names the levels in the DHIS2 org unit hierarchy. Used in `Organization.type` to indicate where an org unit sits in the tree.

**DHIS2 Context:** The DHIS2 API returns a numeric `level` field (1, 2, 3, 4). The level names are configured per deployment. This CodeSystem uses the common names from the Sierra Leone play server.

| Code | Display | Description |
|------|---------|-------------|
| `national` | National | Root org unit (Ministry of Health) |
| `district` | District | District-level administrative unit |
| `chiefdom` | Chiefdom | Sub-district unit (common in West Africa) |
| `facility` | Facility | Health facility where data is collected |

### DHIS2OrgUnitGroupCS/VS

**Purpose:** Classifies org units by facility type, derived from DHIS2 organisation unit groups. Used in `Organization.type` alongside the level code.

**DHIS2 Context:** DHIS2 org unit groups are user-defined classifications. A single org unit can belong to multiple groups. The groups below are from the Sierra Leone play server.

| Code | Display | Description |
|------|---------|-------------|
| `CHP` | Community Health Post | Basic primary care at community level |
| `CHC` | Community Health Centre | Outpatient and basic inpatient services |
| `MCHP` | Maternal and Child Health Post | Focused on MCH services |
| `hospital` | Hospital | Comprehensive inpatient/outpatient care |
| `clinic` | Clinic | Outpatient services |

An Organization can carry both a level type and a group type:

```fsh
* type[0] = DHIS2OrgUnitLevelCS#facility "Facility"
* type[+] = DHIS2OrgUnitGroupCS#CHC "Community Health Centre"
```

## Option Sets

These code systems represent DHIS2 option sets -- the dropdown lists used in data entry forms. They are bound to Questionnaire items via `answerValueSet`.

### DHIS2GenderCS/VS

**Context:** Used for the "Sex" tracked entity attribute on Person-type TEIs. Kept separate from FHIR's AdministrativeGender to preserve DHIS2 option codes.

| Code | Display |
|------|---------|
| `MALE` | Male |
| `FEMALE` | Female |
| `OTHER` | Other |

```fsh
CodeSystem: DHIS2GenderCS
Id: dhis2-gender
* #MALE "Male"
* #FEMALE "Female"
* #OTHER "Other"
```

### DHIS2YesNoCS/VS and DHIS2YesNoUnknownCS/VS

**Context:** Common boolean-like option sets. DHIS2 has both BOOLEAN and TRUE_ONLY value types, but many programs prefer explicit option sets to distinguish "No" (explicitly answered) from "not answered" (no data value recorded).

**Yes/No:**

| Code | Display |
|------|---------|
| `YES` | Yes |
| `NO` | No |

**Yes/No/Unknown:**

| Code | Display |
|------|---------|
| `YES` | Yes |
| `NO` | No |
| `UNKNOWN` | Unknown |

The UNKNOWN code is semantically different from a missing value -- it explicitly states that the information was sought but could not be determined.

### DHIS2TestResultCS/VS

**Context:** Used across laboratory and point-of-care testing programs (malaria RDT, HIV rapid tests, TB sputum smear).

| Code | Display | Notes |
|------|---------|-------|
| `POSITIVE` | Positive | Reactive result |
| `NEGATIVE` | Negative | Non-reactive result |
| `INDETERMINATE` | Indeterminate | Equivocal/invalid, requires repeat |
| `NOT_DONE` | Not done | Test not performed |

### DHIS2HIVStatusCS/VS

**Context:** Core option set for HIV programs. Distinct from test results because it includes broader status concepts.

| Code | Display | Notes |
|------|---------|-------|
| `POSITIVE` | Positive | Confirmed HIV-positive |
| `NEGATIVE` | Negative | Confirmed HIV-negative |
| `UNKNOWN` | Unknown status | Never tested or result unavailable |
| `EXPOSED_INFANT` | Exposed infant | Born to HIV-positive mother, status unconfirmed |

### DHIS2VisitTypeCS/VS

**Context:** Classifies the nature of a clinical encounter across multiple tracker programs (ANC, PNC, HIV, TB).

| Code | Display | Notes |
|------|---------|-------|
| `NEW` | New visit | First visit / initial encounter |
| `FOLLOW_UP` | Follow-up visit | Subsequent visit |
| `REFERRAL` | Referral visit | Referred by another provider |
| `EMERGENCY` | Emergency visit | Unscheduled emergency |

### DHIS2DeliveryModeCS/VS

**Context:** Used in maternal health tracker programs to record how a baby was delivered.

| Code | Display |
|------|---------|
| `NORMAL` | Normal/Vaginal delivery |
| `CAESAREAN` | Caesarean section |
| `ASSISTED` | Assisted delivery (vacuum/forceps) |
| `BREECH` | Breech delivery |

### DHIS2MalariaSpeciesCS/VS

**Context:** Used in malaria case management and surveillance programs. Species identification drives treatment decisions.

| Code | Display | Notes |
|------|---------|-------|
| `P_FALCIPARUM` | P. falciparum | Most lethal, predominant in sub-Saharan Africa |
| `P_VIVAX` | P. vivax | Can form dormant liver stages |
| `P_MALARIAE` | P. malariae | Causes quartan malaria |
| `P_OVALE` | P. ovale | Similar to P. vivax, potential for relapse |
| `MIXED` | Mixed infection | Co-infection with 2+ species |

### DHIS2ImmunizationVaccineCS/VS

**Context:** Used in EPI (Expanded Programme on Immunization) tracker programs. Reflects the standard EPI schedule used in many low- and middle-income countries.

| Code | Display | Description |
|------|---------|-------------|
| `BCG` | BCG | Against tuberculosis, given at birth |
| `OPV` | Oral Polio Vaccine | Sabin vaccine, multiple doses |
| `IPV` | Inactivated Polio Vaccine | Salk vaccine, by injection |
| `PENTA` | Pentavalent (DPT-HepB-Hib) | Combined 5-in-1 vaccine |
| `PCV` | Pneumococcal Conjugate Vaccine | Against S. pneumoniae |
| `ROTA` | Rotavirus Vaccine | Against severe diarrhoea |
| `MEASLES` | Measles vaccine | Monovalent measles |
| `MEASLES_RUBELLA` | Measles-Rubella | Combined MR vaccine |
| `YELLOW_FEVER` | Yellow Fever | Single dose |
| `HPV` | Human Papillomavirus | Cervical cancer prevention |
| `TETANUS_TOXOID` | Tetanus Toxoid | For pregnant women |

### DHIS2PregnancyOutcomeCS/VS

**Context:** Used in maternal health programs to record the outcome of a pregnancy. Feeds into key indicators like stillbirth rate and neonatal mortality.

| Code | Display | Notes |
|------|---------|-------|
| `LIVE_BIRTH` | Live birth | Pregnancy resulted in live birth |
| `STILLBIRTH` | Stillbirth | Fetal death after 28 weeks |
| `MISCARRIAGE` | Miscarriage | Spontaneous loss before 28 weeks |
| `ABORTION` | Abortion | Induced termination |
| `ECTOPIC` | Ectopic pregnancy | Implanted outside uterus |

## Terminology Summary

| Category | CodeSystem | Codes | Used By |
|----------|-----------|-------|---------|
| System | DHIS2DataElementTypeCS | 22 | DHIS2DataElementExtension |
| System | DHIS2ProgramTypeCS | 2 | DHIS2ProgramExtension |
| System | DHIS2EventStatusCS | 6 | Documentation/mapping |
| System | DHIS2EnrollmentStatusCS | 3 | Documentation/mapping |
| System | DHIS2AggregationTypeCS | 7 | DHIS2DataElementExtension |
| Option Set | DHIS2GenderCS | 3 | Questionnaire answerValueSet |
| Option Set | DHIS2YesNoCS | 2 | Questionnaire answerValueSet |
| Option Set | DHIS2YesNoUnknownCS | 3 | Questionnaire answerValueSet |
| Option Set | DHIS2TestResultCS | 4 | Questionnaire answerValueSet |
| Option Set | DHIS2HIVStatusCS | 4 | Questionnaire answerValueSet |
| Option Set | DHIS2VisitTypeCS | 4 | Questionnaire answerValueSet |
| Option Set | DHIS2DeliveryModeCS | 4 | Questionnaire answerValueSet |
| Option Set | DHIS2MalariaSpeciesCS | 5 | Questionnaire answerValueSet |
| Option Set | DHIS2ImmunizationVaccineCS | 11 | Questionnaire answerValueSet |
| Option Set | DHIS2PregnancyOutcomeCS | 5 | Questionnaire answerValueSet |

## Source Files

All terminology files are located in `ig/input/fsh/terminology/`:

- `data-element-types.fsh`
- `program-types.fsh`
- `event-status.fsh`
- `enrollment-status.fsh`
- `aggregation-types.fsh`
- `gender.fsh`
- `yes-no.fsh`
- `test-result.fsh`
- `hiv-status.fsh`
- `visit-type.fsh`
- `delivery-mode.fsh`
- `malaria-species.fsh`
- `immunization-vaccine.fsh`
- `pregnancy-outcome.fsh`
