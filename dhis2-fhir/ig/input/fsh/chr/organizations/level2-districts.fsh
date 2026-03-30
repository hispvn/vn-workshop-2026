// ============================================================================
// Level 2 — Districts (Vientiane Capital)
// ============================================================================

Instance: OrgChanthabuly
InstanceOf: DHIS2Organization
Title: "Organization — Chanthabuly District"
Description: "District-level org unit for Chanthabuly, Vientiane Capital."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "Qw7c6Ckb0XC"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_VTE_CTB"

* name = "Chanthabuly"
* type = CHROrgUnitLevelCS#district "District"
* partOf = Reference(OrgVientianeCapital)
* active = true


Instance: OrgSisattanak
InstanceOf: DHIS2Organization
Title: "Organization — Sisattanak District"
Description: "District-level org unit for Sisattanak, Vientiane Capital."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "jNb63DIHuwU"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_VTE_SSN"

* name = "Sisattanak"
* type = CHROrgUnitLevelCS#district "District"
* partOf = Reference(OrgVientianeCapital)
* active = true


// ============================================================================
// Level 2 — Districts (Savannakhet)
// ============================================================================

Instance: OrgKaysonePhomvihane
InstanceOf: DHIS2Organization
Title: "Organization — Kaysone Phomvihane District"
Description: "District-level org unit for Kaysone Phomvihane, Savannakhet."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "YuQRtpLP10I"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_SVK_KPV"

* name = "Kaysone Phomvihane"
* type = CHROrgUnitLevelCS#district "District"
* partOf = Reference(OrgSavannakhet)
* active = true


Instance: OrgOuthoumphone
InstanceOf: DHIS2Organization
Title: "Organization — Outhoumphone District"
Description: "District-level org unit for Outhoumphone, Savannakhet."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "pMbC0FJwHzE"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_SVK_OTP"

* name = "Outhoumphone"
* type = CHROrgUnitLevelCS#district "District"
* partOf = Reference(OrgSavannakhet)
* active = true


Instance: OrgAtsaphangthong
InstanceOf: DHIS2Organization
Title: "Organization — Atsaphangthong District"
Description: "District-level org unit for Atsaphangthong, Savannakhet."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "Lk2x4mQnT3a"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_SVK_APT"

* name = "Atsaphangthong"
* type = CHROrgUnitLevelCS#district "District"
* partOf = Reference(OrgSavannakhet)
* active = true


// ============================================================================
// Level 2 — Districts (Luang Prabang)
// ============================================================================

Instance: OrgLuangPrabangDistrict
InstanceOf: DHIS2Organization
Title: "Organization — Luang Prabang District"
Description: "District-level org unit for Luang Prabang district, Luang Prabang province."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "Vth0fbpFcsO"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_LPB_LPB"

* name = "Luang Prabang"
* type = CHROrgUnitLevelCS#district "District"
* partOf = Reference(OrgLuangPrabang)
* active = true


Instance: OrgChomphet
InstanceOf: DHIS2Organization
Title: "Organization — Chomphet District"
Description: "District-level org unit for Chomphet, Luang Prabang."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "gR4mObVuj3S"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_LPB_CPT"

* name = "Chomphet"
* type = CHROrgUnitLevelCS#district "District"
* partOf = Reference(OrgLuangPrabang)
* active = true


Instance: OrgPakOu
InstanceOf: DHIS2Organization
Title: "Organization — Pak Ou District"
Description: "District-level org unit for Pak Ou, Luang Prabang."
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "hR7WjMdrYEh"

* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_LPB_PKO"

* name = "Pak Ou"
* type = CHROrgUnitLevelCS#district "District"
* partOf = Reference(OrgLuangPrabang)
* active = true
