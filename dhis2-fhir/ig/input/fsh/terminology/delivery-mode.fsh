// ----------------------------------------------------------------------------
// Mode of Delivery Option Set
// ----------------------------------------------------------------------------
// Used in maternal health / safe motherhood tracker programs to record how
// a baby was delivered. This is a critical data element for obstetric care
// quality indicators and maternal mortality audits. In FHIR, this would
// typically map to a coded value on a Procedure resource representing the
// delivery, or as an Observation linked to the delivery Encounter.
// ----------------------------------------------------------------------------

CodeSystem: DHIS2DeliveryModeCS
Id: dhis2-delivery-mode
Title: "DHIS2 Mode of Delivery Option Set"
Description: "Mode of delivery for maternal health programs."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #NORMAL "Normal/Vaginal delivery"
    "Spontaneous vaginal delivery without surgical intervention."
* #CAESAREAN "Caesarean section"
    "Delivery by caesarean section (surgical)."
* #ASSISTED "Assisted delivery (vacuum/forceps)"
    "Vaginal delivery assisted by vacuum extraction or forceps."
* #BREECH "Breech delivery"
    "Vaginal delivery of a baby in breech presentation."


ValueSet: DHIS2DeliveryModeVS
Id: dhis2-delivery-mode-vs
Title: "DHIS2 Mode of Delivery Options"
Description: "All options from the DHIS2 mode of delivery option set."
* ^experimental = false
* include codes from system DHIS2DeliveryModeCS
