// ============================================================================
// Lao PDR ANC Program — Terminology
// ============================================================================
//
// CodeSystems and ValueSets derived from real DHIS2 option sets used in the
// Lao PDR Antenatal Care (ANC) program (program UID: fflLsS1lm3g).
//
// Each CodeSystem corresponds 1:1 to a DHIS2 option set. The codes match the
// option codes in DHIS2, making round-trip mapping straightforward.
//
// Option sets covered:
//   1. Service Cost           (SPkr4SsJO6S) — Paid vs Free
//   2. ANC Visit Number       (Atk12rr4OC9) — Visit 1–16+
//   3. ANC Risk Factor        (B4kJGll4SYt) — Risk classification
//   4. Service Location       (leQqckuY6Cp) — Where the service was provided
//   5. Hemoglobin Result      (eojKm5iAz1o) — >= 11 g/dL vs < 11 g/dL
//   6. HIV Result             (JBgL4GvS91j) — Reactive / Non-Reactive / Other
//   7. Hepatitis B Result     (bUJTzmyripD) — Positive / Negative / Other
//   8. Syphilis Result        (ysHezUWsqEd) — Positive / Negative / Other
//   9. Referred To            (GFID9hwzjVv) — Referral destination
//  10. Blood Group            (F8Fgxp80qp1) — ABO/Rh blood types
//  11. HIV ARV Site           (FlDLyixoe30) — HIV referral sites
// ============================================================================


// ----------------------------------------------------------------------------
// 1. Service Cost (SPkr4SsJO6S)
// ----------------------------------------------------------------------------

CodeSystem: LaoANCServiceCostCS
Id: lao-anc-service-cost
Title: "Lao ANC — Service Cost"
Description: "Whether the ANC service was paid or free of charge."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #Paid "Paid"
* #Free "Free"


ValueSet: LaoANCServiceCostVS
Id: lao-anc-service-cost-vs
Title: "Lao ANC — Service Cost Options"
Description: "Service cost options for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCServiceCostCS


// ----------------------------------------------------------------------------
// 2. ANC Visit Number (Atk12rr4OC9)
// ----------------------------------------------------------------------------

CodeSystem: LaoANCANCVisitNumberCS
Id: lao-anc-visit-number
Title: "Lao ANC — ANC Visit Number"
Description: "Sequential ANC visit number (1–16+). Tracks how many visits the mother has completed."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #1 "1"
* #2 "2"
* #3 "3"
* #4 "4"
* #5 "5"
* #6 "6"
* #7 "7"
* #8 "8"
* #9 "9"
* #10 "10"
* #11 "11"
* #12 "12"
* #13 "13"
* #14 "14"
* #15 "15"
* #16+ "16+"


ValueSet: LaoANCANCVisitNumberVS
Id: lao-anc-visit-number-vs
Title: "Lao ANC — ANC Visit Number Options"
Description: "Visit number options (1–16+) for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCANCVisitNumberCS


// ----------------------------------------------------------------------------
// 3. ANC Risk Factor (B4kJGll4SYt)
// ----------------------------------------------------------------------------

CodeSystem: LaoANCRiskFactorCS
Id: lao-anc-risk-factor
Title: "Lao ANC — Risk Factor"
Description: "Risk classification for ANC visits. Uses a colour-coded system: Green (no risk), Yellow (low), Pink (medium), Red (high)."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #norisk "No Risk - Green"
* #lowrisk "Low Risk - Yellow"
* #medium "Medium Risk - Pink"
* #high "High risk - Red"
* #NA "Not known"


ValueSet: LaoANCRiskFactorVS
Id: lao-anc-risk-factor-vs
Title: "Lao ANC — Risk Factor Options"
Description: "Risk factor classification for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCRiskFactorCS


// ----------------------------------------------------------------------------
// 4. Service Location (leQqckuY6Cp)
// ----------------------------------------------------------------------------

CodeSystem: LaoANCServiceLocationCS
Id: lao-anc-service-location
Title: "Lao ANC — Service Location"
Description: "Where the ANC service was provided: at the facility (Fixed), during outreach, outside the country, or at a private clinic."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #Fixed "Fixed"
    "Service provided at a health facility."
* #Outreach "Outreach"
    "Service provided during an outreach visit."
* #outside_country "Outside country"
    "Service received outside Lao PDR."
* #private_clinic "Private sector"
    "Service provided at a private clinic."


ValueSet: LaoANCServiceLocationVS
Id: lao-anc-service-location-vs
Title: "Lao ANC — Service Location Options"
Description: "Service location options for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCServiceLocationCS


// ----------------------------------------------------------------------------
// 5. Hemoglobin Result (eojKm5iAz1o)
// ----------------------------------------------------------------------------

CodeSystem: LaoANCHemoglobinResultCS
Id: lao-anc-hemoglobin-result
Title: "Lao ANC — Hemoglobin Test Result"
Description: "Simplified hemoglobin result based on the WHO anaemia threshold of 11 g/dL for pregnant women."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #+ "Greater than or equal to 11 g/dL"
    "Hemoglobin >= 11 g/dL (normal)."
* #- "Less than 11 g/dL"
    "Hemoglobin < 11 g/dL (anaemia)."


ValueSet: LaoANCHemoglobinResultVS
Id: lao-anc-hemoglobin-result-vs
Title: "Lao ANC — Hemoglobin Result Options"
Description: "Hemoglobin test result options for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCHemoglobinResultCS


// ----------------------------------------------------------------------------
// 6. HIV Result (JBgL4GvS91j)
// ----------------------------------------------------------------------------
// Used by both "Result of HIV Screening test" and "Result HIV test 2".

CodeSystem: LaoANCHIVResultCS
Id: lao-anc-hiv-result
Title: "Lao ANC — HIV Test Result"
Description: "HIV rapid test result codes used in the Lao PDR MCH program."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #R "Reactive"
* #NR "Non-Reactive"
* #O "Other"


ValueSet: LaoANCHIVResultVS
Id: lao-anc-hiv-result-vs
Title: "Lao ANC — HIV Test Result Options"
Description: "HIV test result options for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCHIVResultCS


// ----------------------------------------------------------------------------
// 7. Hepatitis B Result (bUJTzmyripD)
// ----------------------------------------------------------------------------

CodeSystem: LaoANCHepBResultCS
Id: lao-anc-hepb-result
Title: "Lao ANC — Hepatitis B Test Result"
Description: "Hepatitis B test result codes used in the Lao PDR MCH program."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #P "Positive"
* #N "Negative"
* #O "Other"


ValueSet: LaoANCHepBResultVS
Id: lao-anc-hepb-result-vs
Title: "Lao ANC — Hepatitis B Result Options"
Description: "Hepatitis B test result options for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCHepBResultCS


// ----------------------------------------------------------------------------
// 8. Syphilis Result (ysHezUWsqEd)
// ----------------------------------------------------------------------------

CodeSystem: LaoANCSyphilisResultCS
Id: lao-anc-syphilis-result
Title: "Lao ANC — Syphilis Test Result"
Description: "Syphilis test result codes used in the Lao PDR MCH program."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #P "Positive"
* #N "Negative"
* #O "Other"


ValueSet: LaoANCSyphilisResultVS
Id: lao-anc-syphilis-result-vs
Title: "Lao ANC — Syphilis Result Options"
Description: "Syphilis test result options for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCSyphilisResultCS


// ----------------------------------------------------------------------------
// 9. Referred To (GFID9hwzjVv)
// ----------------------------------------------------------------------------

CodeSystem: LaoANCReferredToCS
Id: lao-anc-referred-to
Title: "Lao ANC — Referred To"
Description: "Referral destination options for the Lao PDR ANC program."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #public_hospital "Public hospital"
* #private_hospital "Private hospital"
* #outside_country "Outside country"


ValueSet: LaoANCReferredToVS
Id: lao-anc-referred-to-vs
Title: "Lao ANC — Referred To Options"
Description: "Referral destination options for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCReferredToCS


// ----------------------------------------------------------------------------
// 10. Blood Group (F8Fgxp80qp1)
// ----------------------------------------------------------------------------
// Tracked entity attribute, but also relevant to maternal health forms.

CodeSystem: LaoANCBloodGroupCS
Id: lao-anc-blood-group
Title: "Lao ANC — Blood Group"
Description: "ABO/Rh blood group classification. Includes N/A and Not Check for cases where blood group is unknown or not tested."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #A "A"
* #A+ "A+"
* #A- "A-"
* #B "B"
* #B+ "B+"
* #B- "B-"
* #O "O"
* #O+ "O+"
* #O- "O-"
* #AB "AB"
* #AB+ "AB+"
* #AB- "AB-"
* #N/A "N/A"
* #NC "Not Check"


ValueSet: LaoANCBloodGroupVS
Id: lao-anc-blood-group-vs
Title: "Lao ANC — Blood Group Options"
Description: "Blood group options for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCBloodGroupCS


// ----------------------------------------------------------------------------
// 11. HIV ARV Site (FlDLyixoe30)
// ----------------------------------------------------------------------------
// Provincial/site codes for HIV ARV referral. Used in the "Refer to confirm"
// data element when HIV screening is reactive.

CodeSystem: LaoANCHIVARVSiteCS
Id: lao-anc-hiv-arv-site
Title: "Lao ANC — HIV ARV Referral Site"
Description: "Referral sites for HIV-positive mothers needing ARV treatment in Lao PDR. Codes represent provincial abbreviations and point-of-care sites."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #BK "BK"
* #CPS "CPS"
* #FS "FS"
* #HP "HP"
* #KM "KM"
* #LNT "LNT"
* #LPB "LPB"
* #MHS "MHS"
* #STT "STT"
* #SVK "SVK"
* #TP "TP"
* #MCH "MCH"
* #Other_site "Other site"
* #00 "Outside of Lao PDR"
* #POC_SRV "POC_SRV"
* #POC_SKh "POC_SKh"
* #POC_XYBL "POC_XYBL"
* #POC_VTP "POC_VTP"
* #POC_BLKX "POC_BLKX"
* #POC_XKH "POC_XKH"
* #POC_ODX "POC_ODX"
* #POC_XK "POC_XK"
* #POC_ATP "POC_ATP"
* #POC_XSB "POC_XSB"
* #POC_PSL "POC_PSL"
* #POC_KHAM_XKH "POC_KHAM(XKH)"


ValueSet: LaoANCHIVARVSiteVS
Id: lao-anc-hiv-arv-site-vs
Title: "Lao ANC — HIV ARV Referral Site Options"
Description: "HIV ARV referral site options for the Lao PDR ANC program."
* ^experimental = false
* include codes from system LaoANCHIVARVSiteCS
