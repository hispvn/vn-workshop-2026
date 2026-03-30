// ============================================================================
// CHR Examples — Community Health Record Patient and Immunization Instances
// ============================================================================


// ----------------------------------------------------------------------------
// Example: CHR Patient — Phouthasinh Douangmala
// ----------------------------------------------------------------------------
// Female patient from Vientiane/Chanthabuly/Anou village. Has clientHealthId,
// CVID, Green Card, and phone. Representative of a typical CHR registration.
// ----------------------------------------------------------------------------

Instance: CHRPatientPhouthasinh
InstanceOf: DHIS2CHRPatient
Usage: #example
Title: "CHR Patient — Phouthasinh Douangmala"
Description: "A female CHR patient from Vientiane with full Lao identifiers and demographics."

* identifier[clientHealthId].system = $LAO-CHRID
* identifier[clientHealthId].type = CHRIdentifierType#CHR
* identifier[clientHealthId].value = "17011994-2-4821"

* identifier[cvid].system = $LAO-CVID
* identifier[cvid].type = CHRIdentifierType#CVID
* identifier[cvid].value = "CVID-30481726"

* identifier[greenCard].system = $LAO-GREEN
* identifier[greenCard].type = CHRIdentifierType#GREENCARD
* identifier[greenCard].value = "GC-481726305917"

* name[0].use = #official
* name[0].family = "Douangmala"
* name[0].given[0] = "Phouthasinh"

* gender = #female
* birthDate = "1994-01-17"
* active = true

* telecom[0].system = #phone
* telecom[0].value = "+856-20-5548192"
* telecom[0].use = #mobile

* address[0].state = "Vientiane Capital"
* address[0].district = "Chanthabuly"
* address[0].city = "Anou"
* address[0].country = "Lao PDR"
* address[0].extension[provinceCode].valueString = "OU_VTE"
* address[0].extension[districtCode].valueString = "OU_VTE_CTB"
* address[0].extension[villageCode].valueString = "OU_VTE_CTB_ANU"

* extension[nationality].valueCodeableConcept = CHRNationalityCS#LA "Laos"
* extension[ethnicity].valueCodeableConcept = CHREthnicityCS#ລາວ "Lao"
* extension[occupation].valueCodeableConcept = CHROccupationCS#Government "Government"
* extension[education].valueCodeableConcept = CHREducationCS#UNI "University/College"
* extension[bloodGroup].valueCodeableConcept = CHRBloodGroupCS#A+ "A+"


// ----------------------------------------------------------------------------
// Example: CHR Patient — Somchai Sisoulith
// ----------------------------------------------------------------------------
// Male patient from Savannakhet/Kaysone. Has clientHealthId, passport, and
// Green Card. Demonstrates a patient with passport identifier.
// ----------------------------------------------------------------------------

Instance: CHRPatientSomchai
InstanceOf: DHIS2CHRPatient
Usage: #example
Title: "CHR Patient — Somchai Sisoulith"
Description: "A male CHR patient from Savannakhet with passport and Green Card identifiers."

* identifier[clientHealthId].system = $LAO-CHRID
* identifier[clientHealthId].type = CHRIdentifierType#CHR
* identifier[clientHealthId].value = "05031985-1-7293"

* identifier[passport].type = $V2-0203#PPN
* identifier[passport].value = "LA-P482917"

* identifier[greenCard].system = $LAO-GREEN
* identifier[greenCard].type = CHRIdentifierType#GREENCARD
* identifier[greenCard].value = "GC-729384610253"

* name[0].use = #official
* name[0].family = "Sisoulith"
* name[0].given[0] = "Somchai"

* gender = #male
* birthDate = "1985-03-05"
* active = true

* telecom[0].system = #phone
* telecom[0].value = "+856-20-9172834"
* telecom[0].use = #mobile

* address[0].state = "Savannakhet"
* address[0].district = "Kaysone Phomvihane"
* address[0].city = "Naxeng"
* address[0].country = "Lao PDR"
* address[0].extension[provinceCode].valueString = "OU_SVK"
* address[0].extension[districtCode].valueString = "OU_SVK_KPV"
* address[0].extension[villageCode].valueString = "OU_SVK_KPV_NXG"

* extension[nationality].valueCodeableConcept = CHRNationalityCS#LA "Laos"
* extension[ethnicity].valueCodeableConcept = CHREthnicityCS#ລາວ "Lao"
* extension[occupation].valueCodeableConcept = CHROccupationCS#Farmer "Farmer"
* extension[education].valueCodeableConcept = CHREducationCS#PRI "Primary"
* extension[bloodGroup].valueCodeableConcept = CHRBloodGroupCS#O+ "O+"


// ----------------------------------------------------------------------------
// Example: CHR Immunization — Phouthasinh OPV Dose 1
// ----------------------------------------------------------------------------

Instance: CHRImmunizationPhouthasinhOPV1
InstanceOf: DHIS2CHRImmunization
Usage: #example
Title: "CHR Immunization — Phouthasinh OPV Dose 1"
Description: "OPV dose 1 administered at a health facility for patient Phouthasinh."

* status = #completed
* vaccineCode.coding[cvx] = http://hl7.org/fhir/sid/cvx#02 "OPV, trivalent"
* patient = Reference(CHRPatientPhouthasinh) "Phouthasinh Douangmala"
* occurrenceDateTime = "1994-03-17"
* lotNumber = "OPV-2024-A001"
* protocolApplied[0].doseNumberPositiveInt = 1
* protocolApplied[0].targetDisease[0].coding[0] = $SCT#398102009 "Acute poliomyelitis"
* extension[placeOfVaccination].valueCode = #facility


// ----------------------------------------------------------------------------
// Example: CHR Immunization — Phouthasinh Penta Dose 1
// ----------------------------------------------------------------------------

Instance: CHRImmunizationPhouthasinhPenta1
InstanceOf: DHIS2CHRImmunization
Usage: #example
Title: "CHR Immunization — Phouthasinh Penta Dose 1"
Description: "Pentavalent dose 1 administered at a health facility for patient Phouthasinh."

* status = #completed
* vaccineCode.coding[cvx] = http://hl7.org/fhir/sid/cvx#102 "DTP-Hib-Hep B"
* patient = Reference(CHRPatientPhouthasinh) "Phouthasinh Douangmala"
* occurrenceDateTime = "1994-03-17"
* lotNumber = "PENTA-2024-B003"
* protocolApplied[0].doseNumberPositiveInt = 1
* protocolApplied[0].targetDisease[0].coding[0] = $SCT#76902006 "Tetanus"
* protocolApplied[0].targetDisease[+].coding[0] = $SCT#397430003 "Diphtheria caused by Corynebacterium diphtheriae"
* extension[placeOfVaccination].valueCode = #facility


// ----------------------------------------------------------------------------
// Example: CHR Immunization — Somchai BCG
// ----------------------------------------------------------------------------

Instance: CHRImmunizationSomchaiBCG
InstanceOf: DHIS2CHRImmunization
Usage: #example
Title: "CHR Immunization — Somchai BCG"
Description: "BCG birth dose administered at a health facility for patient Somchai."

* status = #completed
* vaccineCode.coding[cvx] = http://hl7.org/fhir/sid/cvx#19 "BCG"
* patient = Reference(CHRPatientSomchai) "Somchai Sisoulith"
* occurrenceDateTime = "1985-03-05"
* lotNumber = "BCG-2024-C001"
* protocolApplied[0].doseNumberPositiveInt = 1
* protocolApplied[0].targetDisease[0].coding[0] = $SCT#56717001 "Tuberculosis"
* extension[placeOfVaccination].valueCode = #facility


// ----------------------------------------------------------------------------
// Example: CHR Immunization — Somchai MR Dose 1
// ----------------------------------------------------------------------------

Instance: CHRImmunizationSomchaiMR1
InstanceOf: DHIS2CHRImmunization
Usage: #example
Title: "CHR Immunization — Somchai MR Dose 1"
Description: "Measles-Rubella dose 1 administered during outreach for patient Somchai."

* status = #completed
* vaccineCode.coding[cvx] = http://hl7.org/fhir/sid/cvx#94 "measles, mumps, rubella, and varicella virus vaccine"
* patient = Reference(CHRPatientSomchai) "Somchai Sisoulith"
* occurrenceDateTime = "1985-12-10"
* lotNumber = "MR-2024-D007"
* protocolApplied[0].doseNumberPositiveInt = 1
* protocolApplied[0].targetDisease[0].coding[0] = $SCT#14189004 "Measles"
* protocolApplied[0].targetDisease[+].coding[0] = $SCT#36653000 "Rubella"
* extension[placeOfVaccination].valueCode = #outreach
