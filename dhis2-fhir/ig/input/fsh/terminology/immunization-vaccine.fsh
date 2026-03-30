// ----------------------------------------------------------------------------
// Vaccine Type Option Set (Immunization / EPI)
// ----------------------------------------------------------------------------
// Used in DHIS2 immunization (EPI) tracker programs to record which vaccine
// was administered during a visit. The codes here reflect the standard
// Expanded Programme on Immunization (EPI) schedule used in many low- and
// middle-income countries. Real-world implementations may extend this list
// with additional vaccines (e.g., COVID-19, cholera). In FHIR, this maps
// to Immunization.vaccineCode, ideally with a ConceptMap linking these
// DHIS2 codes to CVX or ICD-11 vaccine codes.
// ----------------------------------------------------------------------------

CodeSystem: DHIS2ImmunizationVaccineCS
Id: dhis2-immunization-vaccine
Title: "DHIS2 Vaccine Type Option Set"
Description: "Vaccine types commonly tracked in DHIS2 immunization programs (EPI schedule)."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #BCG "BCG"
    "Bacillus Calmette-Guerin vaccine against tuberculosis, typically given at birth."
* #OPV "Oral Polio Vaccine"
    "Oral polio vaccine (Sabin), given in multiple doses during infancy."
* #IPV "Inactivated Polio Vaccine"
    "Inactivated polio vaccine (Salk), given by injection."
* #PENTA "Pentavalent (DPT-HepB-Hib)"
    "Combined vaccine against diphtheria, pertussis, tetanus, hepatitis B, and Haemophilus influenzae type b."
* #PCV "Pneumococcal Conjugate Vaccine"
    "Vaccine against Streptococcus pneumoniae, given in multiple doses."
* #ROTA "Rotavirus Vaccine"
    "Vaccine against rotavirus, a leading cause of severe diarrhoea in children."
* #MEASLES "Measles vaccine"
    "Monovalent measles vaccine."
* #MEASLES_RUBELLA "Measles-Rubella"
    "Combined measles and rubella vaccine (MR)."
* #YELLOW_FEVER "Yellow Fever"
    "Yellow fever vaccine, typically given as a single dose."
* #HPV "Human Papillomavirus"
    "HPV vaccine for prevention of cervical cancer, given to adolescent girls."
* #TETANUS_TOXOID "Tetanus Toxoid"
    "Tetanus toxoid vaccine, given to pregnant women and women of childbearing age."


ValueSet: DHIS2ImmunizationVaccineVS
Id: dhis2-immunization-vaccine-vs
Title: "DHIS2 Vaccine Type Options"
Description: "All options from the DHIS2 vaccine type option set."
* ^experimental = false
* include codes from system DHIS2ImmunizationVaccineCS
