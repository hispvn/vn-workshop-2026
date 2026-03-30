// ----------------------------------------------------------------------------
// Pregnancy Outcome Option Set
// ----------------------------------------------------------------------------
// Used in maternal health and reproductive health tracker programs to record
// the outcome of a pregnancy. This data element is typically captured at
// the point of delivery or pregnancy termination. It feeds into key maternal
// health indicators such as stillbirth rate, neonatal mortality, and
// institutional delivery rate. In FHIR, this would map to
// Observation.value[x] or a Condition resource linked to the pregnancy
// episode.
// ----------------------------------------------------------------------------

CodeSystem: DHIS2PregnancyOutcomeCS
Id: dhis2-pregnancy-outcome
Title: "DHIS2 Pregnancy Outcome Option Set"
Description: "Outcome of pregnancy for maternal health tracking."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #LIVE_BIRTH "Live birth"
    "The pregnancy resulted in a live birth."
* #STILLBIRTH "Stillbirth"
    "The pregnancy resulted in a stillbirth (fetal death after 28 weeks gestation)."
* #MISCARRIAGE "Miscarriage"
    "Spontaneous loss of pregnancy before 28 weeks gestation."
* #ABORTION "Abortion"
    "Induced termination of pregnancy."
* #ECTOPIC "Ectopic pregnancy"
    "Pregnancy implanted outside the uterine cavity."


ValueSet: DHIS2PregnancyOutcomeVS
Id: dhis2-pregnancy-outcome-vs
Title: "DHIS2 Pregnancy Outcome Options"
Description: "All options from the DHIS2 pregnancy outcome option set."
* ^experimental = false
* include codes from system DHIS2PregnancyOutcomeCS
