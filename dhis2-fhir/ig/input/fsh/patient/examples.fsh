// ============================================================================
// Instance: PatientJaneDoe
// ============================================================================
// Jane Doe is a female patient registered at Facility Alpha Health Center in
// Lilongwe, Malawi. She is enrolled in the Antenatal Care (ANC) program and
// will appear in clinical examples throughout this IG.
//
// DHIS2 context:
//   - TEI UID: DXz2k5eGbri (assigned by the DHIS2 server)
//   - Registered at Organisation Unit: DiszpKrYNg8 (Facility Alpha)
//   - National ID: 12345678901 (Malawian national ID)
//   - Tracked Entity Type: Person
// ============================================================================
Instance: PatientJaneDoe
InstanceOf: DHIS2Patient
Title: "Patient — Jane Doe"
Description: """
A sample DHIS2 patient representing Jane Doe, a 35-year-old female from
Lilongwe, Malawi. She is registered at Facility Alpha Health Center and
enrolled in the Antenatal Care program. Her DHIS2 TEI UID is DXz2k5eGbri.
"""
Usage: #example

// -- Identifiers (using the reusable RuleSet) --------------------------------
* insert DHIS2PatientIdentifiers(DXz2k5eGbri, 12345678901, urn:oid:2.16.454.1)

// -- Demographics ------------------------------------------------------------
* name[0].family = "Doe"
* name[0].given[0] = "Jane"
* name[0].use = #official

* gender = #female
* birthDate = "1990-05-15"

// -- Address -----------------------------------------------------------------
// Lilongwe is the capital of Malawi and a common location for DHIS2
// implementations, given DHIS2's extensive use across sub-Saharan Africa.
* address[0].line[0] = "123 Kamuzu Procession Road"
* address[0].city = "Lilongwe"
* address[0].state = "Central Region"
* address[0].postalCode = "P.O. Box 30377"
* address[0].country = "MW"
* address[0].use = #home

// -- Organisation Unit (owning org unit in DHIS2) ----------------------------
// Jane is registered at Facility Alpha Health Center. This mirrors the
// orgUnit property on the DHIS2 /api/trackedEntityInstances endpoint.
* extension[orgUnit].valueReference = Reference(OrganizationFacilityA)

// -- Active status -----------------------------------------------------------
* active = true


// ============================================================================
// Instance: PatientJohnKamau
// ============================================================================
// John Kamau is a male patient from Nairobi, Kenya. He demonstrates the
// profile with a Kenyan national ID format and a different geographic context.
//
// DHIS2 context:
//   - TEI UID: AbC1dEf2gHi
//   - National ID: KE-29384756 (Kenyan format)
//   - Registered in a Kenyan DHIS2 instance
// ============================================================================
Instance: PatientJohnKamau
InstanceOf: DHIS2Patient
Title: "Patient — John Kamau"
Description: """
A sample DHIS2 patient representing John Kamau, a 40-year-old male from
Nairobi, Kenya. His DHIS2 TEI UID is AbC1dEf2gHi. This example illustrates
the profile in a Kenyan DHIS2 deployment context.
"""
Usage: #example

// -- Identifiers -------------------------------------------------------------
* insert DHIS2PatientIdentifiers(AbC1dEf2gHi, KE-29384756, urn:oid:2.16.404.1)

// -- Demographics ------------------------------------------------------------
* name[0].family = "Kamau"
* name[0].given[0] = "John"
* name[0].use = #official

* gender = #male
* birthDate = "1985-08-22"

// -- Address -----------------------------------------------------------------
// Nairobi is the capital of Kenya, another country where DHIS2 is widely
// deployed by the Ministry of Health.
* address[0].line[0] = "45 Moi Avenue"
* address[0].city = "Nairobi"
* address[0].state = "Nairobi County"
* address[0].postalCode = "00100"
* address[0].country = "KE"
* address[0].use = #home

// -- Organisation Unit -------------------------------------------------------
* extension[orgUnit].valueReference = Reference(OrganizationFacilityB)

// -- Active status -----------------------------------------------------------
* active = true


// ============================================================================
// Instance: PatientAminaHassan
// ============================================================================
// Amina Hassan is a female patient from Mombasa, Kenya. She provides a second
// Kenyan patient example with a different facility and geographic context,
// useful for demonstrating multi-patient queries and reporting.
//
// DHIS2 context:
//   - TEI UID: XyZ9wVu8tSr
//   - National ID: KE-87654321 (Kenyan format)
//   - Coastal region — illustrates geographic diversity in DHIS2 deployments
// ============================================================================
Instance: PatientAminaHassan
InstanceOf: DHIS2Patient
Title: "Patient — Amina Hassan"
Description: """
A sample DHIS2 patient representing Amina Hassan, a 33-year-old female from
Mombasa, Kenya. Her DHIS2 TEI UID is XyZ9wVu8tSr. This example shows how
the same profile works across different facilities and regions within a
national DHIS2 deployment.
"""
Usage: #example

// -- Identifiers -------------------------------------------------------------
* insert DHIS2PatientIdentifiers(XyZ9wVu8tSr, KE-87654321, urn:oid:2.16.404.1)

// -- Demographics ------------------------------------------------------------
* name[0].family = "Hassan"
* name[0].given[0] = "Amina"
* name[0].use = #official

* gender = #female
* birthDate = "1992-11-03"

// -- Address -----------------------------------------------------------------
// Mombasa is Kenya's second-largest city and a major coastal hub. Including
// patients from different regions demonstrates how DHIS2 captures population
// data across administrative hierarchies.
* address[0].line[0] = "78 Nyali Road"
* address[0].city = "Mombasa"
* address[0].state = "Mombasa County"
* address[0].postalCode = "80100"
* address[0].country = "KE"
* address[0].use = #home

// -- Organisation Unit -------------------------------------------------------
* extension[orgUnit].valueReference = Reference(OrganizationFacilityB)

// -- Active status -----------------------------------------------------------
* active = true
