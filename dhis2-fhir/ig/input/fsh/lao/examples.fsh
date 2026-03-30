// ============================================================================
// Lao PDR Patient Examples
// ============================================================================
//
// These instances demonstrate the DHIS2Patient profile with Lao-specific
// identifier types, telecom (phone), and address districts. They support
// the Lao PDR health registry search patterns documented in the book.
// ============================================================================


// ============================================================================
// Instance: PatientSomchaiVongsa
// ============================================================================
// Male patient from Vientiane/Chanthabuly district. Demonstrates identifier
// search (CHR ID, Green Card, Insurance) and name+DOB+sex+district combo.
// ============================================================================
Instance: PatientSomchaiVongsa
InstanceOf: DHIS2Patient
Title: "Patient — Somchai Vongsa"
Description: """
A Lao PDR patient representing Somchai Vongsa, a 42-year-old male from
Vientiane, Chanthabuly district. He has a DHIS2 UID, CHR ID, Green National
ID Card, and insurance number. Demonstrates identifier-based search patterns.
"""
Usage: #example

// -- Identifiers ---------------------------------------------------------------
* insert DHIS2PatientIdentifiers(LaB3cD4eF5g, LA-1984-34521, http://moh.gov.la/fhir/id/green-national-id)

* identifier[chr].type = LaoIdentifierType#CHR
* identifier[chr].system = $LAO-CHR
* identifier[chr].value = "CHR-1042567"

* identifier[greenCard].type = LaoIdentifierType#GREENCARD
* identifier[greenCard].system = $LAO-GREEN
* identifier[greenCard].value = "GC-840115001234"

* identifier[insurance].type = LaoIdentifierType#INS
* identifier[insurance].system = $LAO-INSURANCE
* identifier[insurance].value = "INS-LA-30421"

// -- Demographics ---------------------------------------------------------------
* name[0].family = "Vongsa"
* name[0].given[0] = "Somchai"
* name[0].use = #official

* gender = #male
* birthDate = "1984-01-15"

// -- Telecom --------------------------------------------------------------------
* telecom[0].system = #phone
* telecom[0].value = "+856-20-5551234"
* telecom[0].use = #mobile

// -- Address --------------------------------------------------------------------
* address[0].city = "Vientiane"
* address[0].district = "Chanthabuly"
* address[0].country = "LA"
* address[0].use = #home

* active = true


// ============================================================================
// Instance: PatientKhamlaPhommasan
// ============================================================================
// Female patient from Savannakhet/Kaysone district. Demonstrates CVID search,
// passport, and family book identifiers.
// ============================================================================
Instance: PatientKhamlaPhommasan
InstanceOf: DHIS2Patient
Title: "Patient — Khamla Phommasan"
Description: """
A Lao PDR patient representing Khamla Phommasan, a 29-year-old female from
Savannakhet, Kaysone district. She has a CVID, passport, and family book
number. Demonstrates CVID search and family book+DOB+sex combo.
"""
Usage: #example

// -- Identifiers ---------------------------------------------------------------
* insert DHIS2PatientIdentifiers(MnO6pQ7rS8t, LA-1997-78432, http://moh.gov.la/fhir/id/cvid)

* identifier[cvid].type = LaoIdentifierType#CVID
* identifier[cvid].system = $LAO-CVID
* identifier[cvid].value = "CVID-19970622"

* identifier[passport].type = $V2-0203#PPN
* identifier[passport].value = "LA-P234567"

* identifier[familyBook].type = LaoIdentifierType#FAMILYBOOK
* identifier[familyBook].system = $LAO-FAMILYBOOK
* identifier[familyBook].value = "FB-84210"

// -- Demographics ---------------------------------------------------------------
* name[0].family = "Phommasan"
* name[0].given[0] = "Khamla"
* name[0].use = #official

* gender = #female
* birthDate = "1997-06-22"

// -- Telecom --------------------------------------------------------------------
* telecom[0].system = #phone
* telecom[0].value = "+856-20-5559876"
* telecom[0].use = #mobile

// -- Address --------------------------------------------------------------------
* address[0].city = "Savannakhet"
* address[0].district = "Kaysone"
* address[0].country = "LA"
* address[0].use = #home

* active = true


// ============================================================================
// Instance: PatientBounmyKeomany
// ============================================================================
// Male patient from Luang Prabang district. Demonstrates phone+DOB+sex+district
// combo search and Green Card + insurance identifiers.
// ============================================================================
Instance: PatientBounmyKeomany
InstanceOf: DHIS2Patient
Title: "Patient — Bounmy Keomany"
Description: """
A Lao PDR patient representing Bounmy Keomany, a 55-year-old male from
Luang Prabang. He has a Green Card and insurance number. Demonstrates
phone+DOB+sex+district attribute combination search.
"""
Usage: #example

// -- Identifiers ---------------------------------------------------------------
* insert DHIS2PatientIdentifiers(UvW1xY2zA3b, LA-1971-12087, http://moh.gov.la/fhir/id/green-national-id)

* identifier[greenCard].type = LaoIdentifierType#GREENCARD
* identifier[greenCard].system = $LAO-GREEN
* identifier[greenCard].value = "GC-710803005678"

* identifier[insurance].type = LaoIdentifierType#INS
* identifier[insurance].system = $LAO-INSURANCE
* identifier[insurance].value = "INS-LA-87654"

// -- Demographics ---------------------------------------------------------------
* name[0].family = "Keomany"
* name[0].given[0] = "Bounmy"
* name[0].use = #official

* gender = #male
* birthDate = "1971-08-03"

// -- Telecom --------------------------------------------------------------------
* telecom[0].system = #phone
* telecom[0].value = "+856-20-5554321"
* telecom[0].use = #mobile

// -- Address --------------------------------------------------------------------
* address[0].city = "Luang Prabang"
* address[0].district = "Luang Prabang"
* address[0].country = "LA"
* address[0].use = #home

* active = true
