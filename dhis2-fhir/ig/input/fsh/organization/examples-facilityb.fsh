// ============================================================================
// Facility Beta — a second health facility for Kenyan patients
// ============================================================================
// Adds a second facility under District A to give John Kamau and Amina Hassan
// a registration site. Demonstrates multiple facilities in the same district.
// ============================================================================

Instance: OrganizationFacilityB
InstanceOf: DHIS2Organization
Title: "Organization — Facility Beta Health Center"
Description: """
A health facility in Nairobi, Kenya. John Kamau and Amina Hassan are
registered here. DHIS2 UID: Rp268JB6Ne4.
"""
Usage: #example

* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "Rp268JB6Ne4"
* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_167609"
* name = "Facility Beta Health Center"
* type[0] = DHIS2OrgUnitLevelCS#facility "Facility"
* type[+] = DHIS2OrgUnitGroupCS#CHP "Community Health Post"
* partOf = Reference(OrganizationDistrictA)
* active = true


Instance: LocationFacilityB
InstanceOf: DHIS2Location
Title: "Location — Facility Beta Health Center"
Description: """
Physical location of Facility Beta Health Center in Nairobi, Kenya.
GPS coordinates for the Nairobi area.
"""
Usage: #example

* name = "Facility Beta Health Center"
* status = #active
* position.latitude = -1.2921
* position.longitude = 36.8219
* managingOrganization = Reference(OrganizationFacilityB)
