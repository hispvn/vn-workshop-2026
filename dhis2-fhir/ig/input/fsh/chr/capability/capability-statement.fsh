// ============================================================================
// CHR FHIR Server CapabilityStatement
// ============================================================================
//
// Describes the FHIR REST capabilities of the CHR service, including
// supported resources, search parameters, and operations.
// ============================================================================


Instance: CHRCapabilityStatement
InstanceOf: CapabilityStatement
Usage: #definition
Title: "CHR FHIR Server Capability Statement"
Description: """
CapabilityStatement for the Community Health Record (CHR) FHIR server.
Supports Patient and Immunization resources with search, read, and
conditional create operations.
"""

* status = #active
* date = "2024-01-01"
* kind = #instance
* fhirVersion = #4.0.1
* format[0] = #json
* implementation.description = "Lao PDR Community Health Record FHIR Server"
* implementation.url = "http://localhost:8000/fhir"

* rest[0].mode = #server
* rest[0].documentation = "CHR FHIR server supporting Patient and Immunization resources"

// -- Patient resource -------------------------------------------------------
* rest[0].resource[0].type = #Patient
* rest[0].resource[0].profile = "http://dhis2.org/fhir/learning/StructureDefinition/dhis2-chr-patient"
* rest[0].resource[0].interaction[0].code = #read
* rest[0].resource[0].interaction[+].code = #search-type
* rest[0].resource[0].interaction[+].code = #create
* rest[0].resource[0].interaction[+].code = #update
* rest[0].resource[0].conditionalCreate = true

* rest[0].resource[0].searchParam[0].name = "identifier"
* rest[0].resource[0].searchParam[0].type = #token
* rest[0].resource[0].searchParam[0].documentation = "Search by identifier (system|value or value only)"

* rest[0].resource[0].searchParam[+].name = "name"
* rest[0].resource[0].searchParam[=].type = #string
* rest[0].resource[0].searchParam[=].documentation = "Search across given and family name"

* rest[0].resource[0].searchParam[+].name = "given"
* rest[0].resource[0].searchParam[=].type = #string
* rest[0].resource[0].searchParam[=].documentation = "Search by given (first) name"

* rest[0].resource[0].searchParam[+].name = "family"
* rest[0].resource[0].searchParam[=].type = #string
* rest[0].resource[0].searchParam[=].documentation = "Search by family (last) name"

* rest[0].resource[0].searchParam[+].name = "gender"
* rest[0].resource[0].searchParam[=].type = #token
* rest[0].resource[0].searchParam[=].documentation = "Search by gender (male | female)"

* rest[0].resource[0].searchParam[+].name = "birthdate"
* rest[0].resource[0].searchParam[=].type = #date
* rest[0].resource[0].searchParam[=].documentation = "Search by date of birth"

* rest[0].resource[0].searchParam[+].name = "phone"
* rest[0].resource[0].searchParam[=].type = #token
* rest[0].resource[0].searchParam[=].documentation = "Search by phone number"

* rest[0].resource[0].searchParam[+].name = "address"
* rest[0].resource[0].searchParam[=].type = #string
* rest[0].resource[0].searchParam[=].documentation = "General address search"

* rest[0].resource[0].searchParam[+].name = "address-city"
* rest[0].resource[0].searchParam[=].type = #string
* rest[0].resource[0].searchParam[=].documentation = "Search by village/city"

* rest[0].resource[0].searchParam[+].name = "address-state"
* rest[0].resource[0].searchParam[=].type = #string
* rest[0].resource[0].searchParam[=].documentation = "Search by province/state"

// -- Immunization resource --------------------------------------------------
* rest[0].resource[+].type = #Immunization
* rest[0].resource[=].profile = "http://dhis2.org/fhir/learning/StructureDefinition/dhis2-chr-immunization"
* rest[0].resource[=].interaction[0].code = #read
* rest[0].resource[=].interaction[+].code = #search-type
* rest[0].resource[=].interaction[+].code = #create

* rest[0].resource[=].searchParam[0].name = "patient"
* rest[0].resource[=].searchParam[0].type = #reference
* rest[0].resource[=].searchParam[0].documentation = "Search immunizations by patient reference"
