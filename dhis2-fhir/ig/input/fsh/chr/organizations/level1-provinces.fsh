// ============================================================================
// Level 1 — Provinces
// ============================================================================

Instance: OrgVientianeCapital
InstanceOf: DHIS2Organization
Title: "Organization — Vientiane Capital"
Description: "Province-level org unit for Vientiane Capital."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "Rp2dMYlVFhT"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_VTE"

* name = "Vientiane Capital"
* type = CHROrgUnitLevelCS#province "Province"
* partOf = Reference(OrgLaoPDR)
* active = true


Instance: OrgSavannakhet
InstanceOf: DHIS2Organization
Title: "Organization — Savannakhet"
Description: "Province-level org unit for Savannakhet."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "kG9wT3mlJe5"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_SVK"

* name = "Savannakhet"
* type = CHROrgUnitLevelCS#province "Province"
* partOf = Reference(OrgLaoPDR)
* active = true


Instance: OrgLuangPrabang
InstanceOf: DHIS2Organization
Title: "Organization — Luang Prabang"
Description: "Province-level org unit for Luang Prabang."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "dNLjKwsVjod"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_LPB"

* name = "Luang Prabang"
* type = CHROrgUnitLevelCS#province "Province"
* partOf = Reference(OrgLaoPDR)
* active = true

