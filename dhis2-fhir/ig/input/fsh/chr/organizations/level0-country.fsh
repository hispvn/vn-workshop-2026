// ============================================================================
// CHR Organisation Unit Hierarchy — Lao PDR Representative Examples
// ============================================================================
//
// A representative subset of the Lao PDR organisation unit hierarchy,
// demonstrating the DHIS2Organization profile with four levels:
//
//   Level 0: Lao PDR (country root)
//   ├── Level 1: Vientiane Capital / Savannakhet / Luang Prabang
//   │   ├── Level 2: Districts
//   │   │   └── Level 3: Villages
//
// The full hierarchy has ~500k entries; these 22 instances illustrate
// the pattern for the CHR module.
// ============================================================================


// ============================================================================
// Level 0 — Country
// ============================================================================

Instance: OrgLaoPDR
InstanceOf: DHIS2Organization
Title: "Organization — Lao PDR"
Description: "Country-level root of the Lao PDR organisation unit hierarchy."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "aWQz6FXpMKv"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_LA"

* name = "Lao PDR"
* type = CHROrgUnitLevelCS#country "Country"
* active = true

