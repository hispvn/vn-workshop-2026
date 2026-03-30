// Organisation Unit Level — 4 codes for the Lao PDR hierarchy

CodeSystem: CHROrgUnitLevelCS
Id: chr-org-unit-level
Title: "CHR Organisation Unit Level"
Description: "Levels in the Lao PDR organisation unit hierarchy used by the Community Health Record."
* ^url = "http://moh.gov.la/fhir/CodeSystem/chr-org-unit-level"
* ^status = #active
* ^caseSensitive = true
* ^content = #complete
* #country "Country"
    "The national root of the org unit hierarchy."
* #province "Province"
    "A province (khoueng) — the first administrative subdivision."
* #district "District"
    "A district (muang) — the second administrative subdivision."
* #village "Village"
    "A village (ban) — the lowest administrative subdivision."


ValueSet: CHROrgUnitLevelVS
Id: chr-org-unit-level-vs
Title: "CHR Organisation Unit Level"
Description: "Organisation unit levels used in the Lao PDR CHR hierarchy."
* ^url = "http://moh.gov.la/fhir/ValueSet/chr-org-unit-level"
* ^status = #active
* include codes from system CHROrgUnitLevelCS
