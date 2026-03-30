// ============================================================================
// INSTANCES — Organisation Unit Hierarchy
// ============================================================================
//
// The following three instances model a simple three-level DHIS2 org unit
// hierarchy, representative of many real-world DHIS2 deployments:
//
//   Level 1: Ministry of Health      (GOLswS44mh8) — national
//     └─ Level 2: District A         (ImspTQPwCqd) — district
//          └─ Level 3: Facility Alpha (DiszpKrYNg8) — facility
//
// This hierarchy demonstrates:
//   - The partOf chain that models parent-child relationships
//   - How DHIS2 UIDs map to FHIR identifiers
//   - The typical national → district → facility structure
//
// The Location instance demonstrates how GPS coordinates from DHIS2 org units
// map to FHIR Location.position.
// ============================================================================


// ============================================================================
// Instance: OrganizationMOH
// ============================================================================
// The Ministry of Health — root of the org unit hierarchy (Level 1).
// In DHIS2, the root org unit has no parent and represents the highest
// aggregation level. Users assigned to this org unit can see all data
// across the entire hierarchy.
//
// DHIS2 API equivalent:
//   GET /api/organisationUnits/GOLswS44mh8
// ============================================================================
Instance: OrganizationMOH
InstanceOf: DHIS2Organization
Title: "Organization — Ministry of Health"
Description: """
The top-level (root) org unit representing the national Ministry of Health.
Level 1 in the DHIS2 hierarchy. All other org units are descendants of this
node. National-level analytics aggregate data from all org units below.
"""
Usage: #example

// -- DHIS2 UID ---------------------------------------------------------------
* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "GOLswS44mh8"

// -- DHIS2 Code --------------------------------------------------------------
* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_525"

// -- Name (displayed in the DHIS2 org unit tree) -----------------------------
* name = "Ministry of Health"

// -- Type: hierarchy level ---------------------------------------------------
* type = DHIS2OrgUnitLevelCS#national "National"

// -- Active ------------------------------------------------------------------
* active = true

// Note: no partOf — this is the root of the hierarchy.


// ============================================================================
// Instance: OrganizationDistrictA
// ============================================================================
// A district-level health office (Level 2). In many DHIS2 deployments,
// districts are the primary level for data review and analysis. District
// Health Management Teams use DHIS2 dashboards to monitor facility
// performance, disease surveillance, and program coverage.
//
// DHIS2 API equivalent:
//   GET /api/organisationUnits/ImspTQPwCqd
//   Response includes: parent.id = "GOLswS44mh8"
// ============================================================================
Instance: OrganizationDistrictA
InstanceOf: DHIS2Organization
Title: "Organization — District A Health Office"
Description: """
A district-level org unit (Level 2) representing District A Health Office.
Reports to the Ministry of Health. Districts aggregate data from their
child facilities and are a key level for health program management.
"""
Usage: #example

// -- DHIS2 UID ---------------------------------------------------------------
* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "ImspTQPwCqd"

// -- DHIS2 Code --------------------------------------------------------------
* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_278371"

// -- Name --------------------------------------------------------------------
* name = "District A Health Office"

// -- Type: hierarchy level ---------------------------------------------------
* type = DHIS2OrgUnitLevelCS#district "District"

// -- Hierarchy: child of the Ministry of Health ------------------------------
// In DHIS2, this relationship is expressed as:
//   { "parent": { "id": "GOLswS44mh8" } }
* partOf = Reference(OrganizationMOH)

// -- Active ------------------------------------------------------------------
* active = true


// ============================================================================
// Instance: OrganizationFacilityA
// ============================================================================
// A health facility (Level 3) — the leaf node where data is collected.
// In DHIS2, facilities are the primary data entry points. Aggregate data
// forms, tracker events, and TEI registrations all happen at this level.
//
// DHIS2 API equivalent:
//   GET /api/organisationUnits/DiszpKrYNg8
//   Response includes: parent.id = "ImspTQPwCqd", level = 3
// ============================================================================
Instance: OrganizationFacilityA
InstanceOf: DHIS2Organization
Title: "Organization — Facility Alpha Health Center"
Description: """
A facility-level org unit (Level 3) representing Facility Alpha Health Center.
This is a leaf node in the hierarchy where clinical data is collected. Patients
are registered here as tracked entity instances, and events (visits) are
captured through DHIS2 Tracker programs.
"""
Usage: #example

// -- DHIS2 UID ---------------------------------------------------------------
* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "DiszpKrYNg8"

// -- DHIS2 Code --------------------------------------------------------------
* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value = "OU_559"

// -- Name --------------------------------------------------------------------
* name = "Facility Alpha Health Center"

// -- Type: hierarchy level + facility group ----------------------------------
// An org unit can have both a level type and a group type. Here we show a
// facility (level) that is classified as a Community Health Centre (group).
* type[0] = DHIS2OrgUnitLevelCS#facility "Facility"
* type[+] = DHIS2OrgUnitGroupCS#CHC "Community Health Centre"

// -- Hierarchy: child of District A ------------------------------------------
* partOf = Reference(OrganizationDistrictA)

// -- Active ------------------------------------------------------------------
* active = true


// ============================================================================
// Instance: LocationFacilityA
// ============================================================================
// The physical location of Facility Alpha Health Center. The GPS coordinates
// (-13.9626, 33.7741) place this facility in Lilongwe, Malawi.
//
// In DHIS2, coordinates can be captured via:
//   - Manual entry in the Maintenance app
//   - GPS capture on the DHIS2 Android Capture app
//   - Bulk import from GIS datasets (shapefiles, CSV)
//
// These coordinates enable DHIS2's mapping features:
//   - Facility distribution maps
//   - Thematic maps (color-coded by indicator values)
//   - Buffer/proximity analysis
//
// DHIS2 API equivalent:
//   GET /api/organisationUnits/DiszpKrYNg8?fields=coordinates
//   Response: { "coordinates": "[-13.9626, 33.7741]" }
//   Note: DHIS2 stores coordinates as [lat, lng] in a JSON array.
// ============================================================================
Instance: LocationFacilityA
InstanceOf: DHIS2Location
Title: "Location — Facility Alpha Health Center"
Description: """
The physical location of Facility Alpha Health Center in Lilongwe, Malawi.
GPS coordinates (-13.9626, 33.7741) enable map-based visualization in DHIS2.
Managed by OrganizationFacilityA.
"""
Usage: #example

// -- Name (matches the org unit name) ----------------------------------------
* name = "Facility Alpha Health Center"

// -- Status ------------------------------------------------------------------
* status = #active

// -- GPS coordinates ---------------------------------------------------------
// Latitude -13.9626: south of the equator (central Malawi)
// Longitude 33.7741: east of the prime meridian (southeastern Africa)
// These coordinates place the facility in Lilongwe, Malawi's capital city.
* position.latitude = -13.9626
* position.longitude = 33.7741

// -- Managing Organization ---------------------------------------------------
// Links this Location to the DHIS2Organization that operates the facility.
* managingOrganization = Reference(OrganizationFacilityA)
