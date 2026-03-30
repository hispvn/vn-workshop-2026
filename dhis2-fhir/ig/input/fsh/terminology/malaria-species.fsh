// ----------------------------------------------------------------------------
// Malaria Species Option Set
// ----------------------------------------------------------------------------
// Used in malaria case management and surveillance programs. Species
// identification is essential for treatment decisions (e.g., P. vivax
// requires primaquine for radical cure) and for epidemiological reporting
// to the WHO. DHIS2 malaria modules typically capture this via a data
// element bound to this option set, populated after microscopy or RDT.
// ----------------------------------------------------------------------------

CodeSystem: DHIS2MalariaSpeciesCS
Id: dhis2-malaria-species
Title: "DHIS2 Malaria Species Option Set"
Description: "Plasmodium species identification for malaria case management."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #P_FALCIPARUM "P. falciparum"
    "Plasmodium falciparum, the most lethal malaria species, predominant in sub-Saharan Africa."
* #P_VIVAX "P. vivax"
    "Plasmodium vivax, capable of forming dormant liver stages (hypnozoites)."
* #P_MALARIAE "P. malariae"
    "Plasmodium malariae, causes quartan malaria with 72-hour fever cycles."
* #P_OVALE "P. ovale"
    "Plasmodium ovale, similar to P. vivax with potential for relapse."
* #MIXED "Mixed infection"
    "Co-infection with two or more Plasmodium species."


ValueSet: DHIS2MalariaSpeciesVS
Id: dhis2-malaria-species-vs
Title: "DHIS2 Malaria Species Options"
Description: "All options from the DHIS2 malaria species option set."
* ^experimental = false
* include codes from system DHIS2MalariaSpeciesCS
