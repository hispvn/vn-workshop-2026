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
CapabilityStatement for the DHIS2-FHIR learning server.
Supports Patient, Immunization, Questionnaire, QuestionnaireResponse,
ValueSet (with $expand), CodeSystem, and Bundle resources.
"""

* status = #active
* date = "2024-01-01"
* kind = #instance
* fhirVersion = #4.0.1
* format[0] = #json
* implementation.description = "Lao PDR Community Health Record FHIR Server"
* implementation.url = "http://localhost:8000/fhir"

* rest[0].mode = #server
* rest[0].documentation = "DHIS2-FHIR learning server supporting Patient, Questionnaire, ValueSet, CodeSystem, and more"

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

// -- Questionnaire resource ---------------------------------------------------
* rest[0].resource[+].type = #Questionnaire
* rest[0].resource[=].interaction[0].code = #read
* rest[0].resource[=].interaction[+].code = #search-type

* rest[0].resource[=].searchParam[0].name = "name"
* rest[0].resource[=].searchParam[0].type = #string
* rest[0].resource[=].searchParam[0].documentation = "Search by questionnaire name"

* rest[0].resource[=].searchParam[+].name = "title"
* rest[0].resource[=].searchParam[=].type = #string
* rest[0].resource[=].searchParam[=].documentation = "Search by questionnaire title"

* rest[0].resource[=].searchParam[+].name = "status"
* rest[0].resource[=].searchParam[=].type = #token
* rest[0].resource[=].searchParam[=].documentation = "Filter by status (active | draft | retired)"

// -- QuestionnaireResponse resource -------------------------------------------
* rest[0].resource[+].type = #QuestionnaireResponse
* rest[0].resource[=].interaction[0].code = #read
* rest[0].resource[=].interaction[+].code = #search-type

* rest[0].resource[=].searchParam[0].name = "questionnaire"
* rest[0].resource[=].searchParam[0].type = #reference
* rest[0].resource[=].searchParam[0].documentation = "Search by questionnaire URL"

* rest[0].resource[=].searchParam[+].name = "subject"
* rest[0].resource[=].searchParam[=].type = #reference
* rest[0].resource[=].searchParam[=].documentation = "Search by subject (Patient reference)"

* rest[0].resource[=].searchParam[+].name = "status"
* rest[0].resource[=].searchParam[=].type = #token
* rest[0].resource[=].searchParam[=].documentation = "Filter by status (completed | in-progress)"

// -- ValueSet resource --------------------------------------------------------
* rest[0].resource[+].type = #ValueSet
* rest[0].resource[=].interaction[0].code = #read
* rest[0].resource[=].interaction[+].code = #search-type

* rest[0].resource[=].searchParam[0].name = "name"
* rest[0].resource[=].searchParam[0].type = #string
* rest[0].resource[=].searchParam[0].documentation = "Search by ValueSet name"

* rest[0].resource[=].searchParam[+].name = "url"
* rest[0].resource[=].searchParam[=].type = #uri
* rest[0].resource[=].searchParam[=].documentation = "Search by canonical URL (exact match)"

* rest[0].resource[=].operation[0].name = "expand"
* rest[0].resource[=].operation[0].definition = "http://hl7.org/fhir/OperationDefinition/ValueSet-expand"

// -- CodeSystem resource ------------------------------------------------------
* rest[0].resource[+].type = #CodeSystem
* rest[0].resource[=].interaction[0].code = #read
* rest[0].resource[=].interaction[+].code = #search-type

* rest[0].resource[=].searchParam[0].name = "name"
* rest[0].resource[=].searchParam[0].type = #string
* rest[0].resource[=].searchParam[0].documentation = "Search by CodeSystem name"

* rest[0].resource[=].searchParam[+].name = "url"
* rest[0].resource[=].searchParam[=].type = #uri
* rest[0].resource[=].searchParam[=].documentation = "Search by canonical URL (exact match)"

// -- Bundle resource ----------------------------------------------------------
* rest[0].resource[+].type = #Bundle
* rest[0].resource[=].interaction[0].code = #read
* rest[0].resource[=].interaction[+].code = #search-type

* rest[0].resource[=].searchParam[0].name = "type"
* rest[0].resource[=].searchParam[0].type = #token
* rest[0].resource[=].searchParam[0].documentation = "Filter by bundle type (document | searchset)"
