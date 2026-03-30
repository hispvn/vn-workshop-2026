// ============================================================================
// DHIS2 IPS — Vaccine Terminology
// ============================================================================
//
// ValueSets for vaccine codes and administration routes used in the IPS
// Immunization profile. These reference standard terminologies (CVX, ATC,
// SNOMED CT) rather than defining custom CodeSystems.
//
// CDC CVX (Vaccine Administered) is the primary coding system for vaccines
// in FHIR. WHO ATC codes provide an alternative international classification.
// ============================================================================


// ----------------------------------------------------------------------------
// ValueSet: DHIS2IPSVaccineVS
// ----------------------------------------------------------------------------
// Common vaccines administered in DHIS2 immunization programs. This is an
// extensible ValueSet — implementations can use any valid CVX code even if
// not listed here. The listed codes cover the most common vaccines in
// low- and middle-income country EPI (Expanded Programme on Immunization)
// schedules.
// ----------------------------------------------------------------------------

ValueSet: DHIS2IPSVaccineVS
Id: dhis2-ips-vaccine-vs
Title: "DHIS2 IPS — Vaccine Codes"
Description: "Common vaccine codes from CDC CVX used in DHIS2 immunization programs. Covers EPI schedule vaccines, COVID-19, and common adult vaccines."
* ^experimental = false

// -- EPI childhood vaccines --
* http://hl7.org/fhir/sid/cvx#20 "DTaP"
* http://hl7.org/fhir/sid/cvx#10 "IPV"
* http://hl7.org/fhir/sid/cvx#03 "MMR"
* http://hl7.org/fhir/sid/cvx#21 "Varicella"
* http://hl7.org/fhir/sid/cvx#19 "BCG"
* http://hl7.org/fhir/sid/cvx#08 "Hep B, adolescent or pediatric"
* http://hl7.org/fhir/sid/cvx#52 "Hep A, adult"
* http://hl7.org/fhir/sid/cvx#83 "Hep A, ped/adol, 2 dose"
* http://hl7.org/fhir/sid/cvx#17 "Hib"
* http://hl7.org/fhir/sid/cvx#133 "PCV13"
* http://hl7.org/fhir/sid/cvx#116 "Rotavirus, pentavalent"
* http://hl7.org/fhir/sid/cvx#89 "Polio, unspecified"
* http://hl7.org/fhir/sid/cvx#02 "OPV, trivalent"
* http://hl7.org/fhir/sid/cvx#62 "HPV, quadrivalent"
* http://hl7.org/fhir/sid/cvx#114 "Meningococcal A"
* http://hl7.org/fhir/sid/cvx#104 "Hep A-Hep B"
* http://hl7.org/fhir/sid/cvx#50 "DTaP-Hib"
* http://hl7.org/fhir/sid/cvx#120 "DTaP-Hib-IPV"
* http://hl7.org/fhir/sid/cvx#110 "DTaP-Hep B-IPV"
* http://hl7.org/fhir/sid/cvx#146 "DTaP-IPV-Hib-Hep B (Vaxelis)"

// -- Adult / travel vaccines --
* http://hl7.org/fhir/sid/cvx#115 "Tdap"
* http://hl7.org/fhir/sid/cvx#09 "Td"
* http://hl7.org/fhir/sid/cvx#33 "Pneumococcal polysaccharide"
* http://hl7.org/fhir/sid/cvx#88 "Influenza, unspecified"
* http://hl7.org/fhir/sid/cvx#37 "Yellow fever"
* http://hl7.org/fhir/sid/cvx#18 "Rabies"
* http://hl7.org/fhir/sid/cvx#39 "Japanese encephalitis"
* http://hl7.org/fhir/sid/cvx#25 "Typhoid, oral"
* http://hl7.org/fhir/sid/cvx#101 "Typhoid, ViCPs"
* http://hl7.org/fhir/sid/cvx#75 "Smallpox"
* http://hl7.org/fhir/sid/cvx#90 "Rabies, unspecified"
* http://hl7.org/fhir/sid/cvx#36 "VZIG"
* http://hl7.org/fhir/sid/cvx#100 "Pneumococcal conjugate PCV 7"
* http://hl7.org/fhir/sid/cvx#152 "Pneumococcal conjugate PCV 20"

// -- COVID-19 vaccines --
* http://hl7.org/fhir/sid/cvx#207 "COVID-19, mRNA, LNP-S, PF, 100 mcg/0.5mL (Moderna)"
* http://hl7.org/fhir/sid/cvx#208 "COVID-19, mRNA, LNP-S, PF, 30 mcg/0.3mL (Pfizer)"
* http://hl7.org/fhir/sid/cvx#210 "COVID-19 vaccine, vector-nr, rS-Ad26 (Janssen)"
* http://hl7.org/fhir/sid/cvx#211 "COVID-19, subunit, rS-nanoparticle+Matrix-M1 (Novavax)"
* http://hl7.org/fhir/sid/cvx#212 "COVID-19 vaccine, vector-nr, rS-ChAdOx1 (AstraZeneca)"
* http://hl7.org/fhir/sid/cvx#213 "SARS-COV-2 (COVID-19), unspecified"
* http://hl7.org/fhir/sid/cvx#510 "COVID-19 IV Non-US (Sinopharm)"
* http://hl7.org/fhir/sid/cvx#511 "COVID-19 IV Non-US (Sinovac)"


// ----------------------------------------------------------------------------
// ValueSet: DHIS2IPSRouteVS
// ----------------------------------------------------------------------------
// Routes of administration for vaccines.
// ----------------------------------------------------------------------------

ValueSet: DHIS2IPSRouteVS
Id: dhis2-ips-route-vs
Title: "DHIS2 IPS — Immunization Route"
Description: "Common routes of administration for vaccines."
* ^experimental = false
* http://snomed.info/sct#78421000 "Intramuscular route"
* http://snomed.info/sct#34206005 "Subcutaneous route"
* http://snomed.info/sct#26643006 "Oral route"
* http://snomed.info/sct#46713006 "Nasal route"
* http://snomed.info/sct#6064005 "Topical route"
* http://snomed.info/sct#47625008 "Intravenous route"


// ----------------------------------------------------------------------------
// ValueSet: DHIS2IPSSiteVS
// ----------------------------------------------------------------------------
// Body sites for vaccine injection.
// ----------------------------------------------------------------------------

ValueSet: DHIS2IPSSiteVS
Id: dhis2-ips-site-vs
Title: "DHIS2 IPS — Injection Site"
Description: "Common body sites for vaccine administration."
* ^experimental = false
* http://snomed.info/sct#61396006 "Left thigh"
* http://snomed.info/sct#11207009 "Right thigh"
* http://snomed.info/sct#368208006 "Left upper arm"
* http://snomed.info/sct#368209003 "Right upper arm"


// ----------------------------------------------------------------------------
// ValueSet: DHIS2IPSTargetDiseaseVS
// ----------------------------------------------------------------------------
// Target diseases for immunization protocols.
// ----------------------------------------------------------------------------

ValueSet: DHIS2IPSTargetDiseaseVS
Id: dhis2-ips-target-disease-vs
Title: "DHIS2 IPS — Target Diseases"
Description: "Diseases targeted by vaccines in the DHIS2 IPS immunization program."
* ^experimental = false
* http://snomed.info/sct#397430003 "Diphtheria"
* http://snomed.info/sct#76902006 "Tetanus"
* http://snomed.info/sct#27836007 "Pertussis"
* http://snomed.info/sct#398102009 "Poliomyelitis"
* http://snomed.info/sct#36989005 "Mumps"
* http://snomed.info/sct#14189004 "Measles"
* http://snomed.info/sct#36653000 "Rubella"
* http://snomed.info/sct#38907003 "Varicella"
* http://snomed.info/sct#66071002 "Hepatitis B"
* http://snomed.info/sct#40468003 "Hepatitis A"
* http://snomed.info/sct#56717001 "Tuberculosis"
* http://snomed.info/sct#840539006 "COVID-19"
* http://snomed.info/sct#6142004 "Influenza"
* http://snomed.info/sct#16541001 "Yellow fever"
* http://snomed.info/sct#14168008 "Rabies"
* http://snomed.info/sct#23511006 "Meningococcal disease"
* http://snomed.info/sct#16814004 "Pneumococcal disease"
* http://snomed.info/sct#240532009 "HPV infection"
* http://snomed.info/sct#18624000 "Rotavirus infection"
* http://snomed.info/sct#4834000 "Typhoid fever"
