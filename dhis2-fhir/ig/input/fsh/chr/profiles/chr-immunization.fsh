// ============================================================================
// Profile: DHIS2CHRImmunization
// ============================================================================

Profile: DHIS2CHRImmunization
Parent: Immunization
Id: dhis2-chr-immunization
Title: "DHIS2 CHR Immunization"
Description: """
An Immunization profile for the Lao PDR Electronic Immunization Registry (EIR).
Records a single vaccine administration with vaccine code, date, dose number,
lot number, and place of vaccination. Self-contained — inherits directly from
base FHIR Immunization.
"""

* status MS
* status ^short = "completed | entered-in-error | not-done"

* vaccineCode 1..1 MS
* vaccineCode ^short = "Vaccine product administered"
* vaccineCode.coding 1..* MS
* vaccineCode.coding ^slicing.discriminator.type = #pattern
* vaccineCode.coding ^slicing.discriminator.path = "system"
* vaccineCode.coding ^slicing.rules = #open

* vaccineCode.coding contains
    cvx 0..1 MS and
    whoAtc 0..1 MS

* vaccineCode.coding[cvx] ^short = "CDC CVX vaccine code"
* vaccineCode.coding[cvx].system = "http://hl7.org/fhir/sid/cvx" (exactly)
* vaccineCode.coding[cvx].code 1..1
* vaccineCode.coding[cvx].display 1..1

* vaccineCode.coding[whoAtc] ^short = "WHO ATC classification"
* vaccineCode.coding[whoAtc].system = "http://www.whocc.no/atc" (exactly)
* vaccineCode.coding[whoAtc].code 1..1

* patient 1..1 MS
* patient only Reference(DHIS2CHRPatient)
* patient ^short = "Patient who received the vaccine"

* occurrence[x] 1..1 MS
* occurrence[x] ^short = "Date/time the vaccine was administered"

* lotNumber MS
* lotNumber ^short = "Vaccine lot number"

* site MS
* site ^short = "Body site where vaccine was administered"

* route MS
* route ^short = "Route of administration (IM, SC, oral, etc.)"

* performer MS

* protocolApplied MS
* protocolApplied.doseNumber[x] MS
* protocolApplied.doseNumber[x] ^short = "Dose number in the series"
* protocolApplied.targetDisease MS
* protocolApplied.targetDisease ^short = "Disease the vaccine protects against"

* location MS
* location ^short = "Facility where the vaccine was administered"

* extension contains
    CHRPlaceOfVaccination named placeOfVaccination 0..1 MS
