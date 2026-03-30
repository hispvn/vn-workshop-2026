// ============================================================================
// DHIS2 Organization and Location Profiles and Instances
// ============================================================================
//
// This file maps the DHIS2 Organisation Unit hierarchy to FHIR Organization
// and Location resources. In DHIS2, the org unit hierarchy is one of the most
// fundamental concepts — it simultaneously represents:
//
//   1. ADMINISTRATIVE STRUCTURE — the reporting chain from national level
//      (Ministry of Health) down through regions, districts, and facilities.
//
//   2. DATA OWNERSHIP — every piece of data in DHIS2 is tagged with an org
//      unit. Data access control, sharing, and analytics are all scoped by
//      the org unit tree.
//
//   3. GEOGRAPHIC BOUNDARIES — org units can carry GPS coordinates and polygon
//      geometries for GIS/mapping features.
//
// Because FHIR separates the administrative (Organization) and physical
// (Location) aspects into distinct resources, we define two profiles:
//
//   - DHIS2Organization: captures the administrative identity, name, and
//     hierarchical parent-child relationships (via partOf).
//
//   - DHIS2Location: captures the physical/geographic attributes — name,
//     GPS coordinates (latitude/longitude), and a link back to the managing
//     DHIS2Organization.
//
// Dependencies:
//   aliases.fsh — $DHIS2-OU, $V2-0203
// ============================================================================


// ----------------------------------------------------------------------------
// Profile: DHIS2Organization
// ----------------------------------------------------------------------------
// Maps a DHIS2 Organisation Unit to FHIR Organization.
//
// Key DHIS2-to-FHIR mapping decisions:
//   - The DHIS2 org unit UID becomes an identifier with system $DHIS2-OU.
//   - The hierarchy is modeled via Organization.partOf references, forming
//     a tree just like the DHIS2 org unit tree.
//   - Organization.type can represent the org unit level (national, district,
//     facility) or org unit groups (hospital, health center, etc.).
//   - Organization.name is mandatory because every DHIS2 org unit has a name.
// ----------------------------------------------------------------------------
Profile: DHIS2Organization
Parent: Organization
Id: dhis2-organization
Title: "DHIS2 Organization"
Description: """
Represents a DHIS2 Organisation Unit as a FHIR Organization resource. DHIS2
Organisation Units form a hierarchical tree — typically from the national
Ministry of Health down through administrative levels to individual health
facilities. This profile requires the DHIS2 org unit UID and supports the
parent-child hierarchy through Organization.partOf.

Every piece of data in DHIS2 is associated with an org unit. The hierarchy
determines data aggregation (facility data rolls up to district, district to
region, etc.), access control (users are assigned org units and can see data
for their subtree), and analytics dimensions.
"""

// -- Identifiers (sliced) ---------------------------------------------------
// Every DHIS2 org unit has a unique 11-character UID. We require it here.
// Additional identifiers (e.g., facility registry codes) are allowed.
// ----------------------------------------------------------------------------
* identifier 1..* MS
* identifier ^short = "DHIS2 Organisation Unit UID (required)"
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "type"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Separate DHIS2 UID from other identifiers"
* identifier ^slicing.ordered = false

// -- Slice: dhis2uid ---------------------------------------------------------
// The DHIS2 org unit UID — 11 alphanumeric characters, starting with a letter.
// Uses system $DHIS2-OU to clearly identify the namespace.
// ----------------------------------------------------------------------------
* identifier contains dhis2uid 1..1 MS and dhis2code 0..1 MS
* identifier[dhis2uid] ^short = "DHIS2 Organisation Unit UID"
* identifier[dhis2uid] ^definition = """
The unique 11-character identifier for this org unit in DHIS2, used in all
API calls (e.g., /api/organisationUnits/{uid}).
"""
* identifier[dhis2uid].system 1..1
* identifier[dhis2uid].system = $DHIS2-OU (exactly)
* identifier[dhis2uid].type 1..1
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value 1..1

// -- Slice: dhis2code --------------------------------------------------------
// DHIS2 org units have an optional human-readable code (e.g., "OU_559",
// "OU_278247") separate from the auto-generated UID. This code is often used
// in reports, exports, and integrations as a stable reference.
// ----------------------------------------------------------------------------
* identifier[dhis2code] ^short = "DHIS2 Organisation Unit code"
* identifier[dhis2code] ^definition = """
An optional human-readable code for the org unit in DHIS2. Unlike the UID
(which is auto-generated), the code is typically assigned by administrators
and may follow a naming convention (e.g., OU_559).
"""
* identifier[dhis2code].system 1..1
* identifier[dhis2code].system = $DHIS2-OU-CODE (exactly)
* identifier[dhis2code].type 1..1
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value 1..1

// -- Name --------------------------------------------------------------------
// Every DHIS2 org unit has a name. It is displayed in the org unit tree, data
// entry forms, and analytics outputs. In DHIS2 it is a required field.
// ----------------------------------------------------------------------------
* name 1..1 MS
* name ^short = "Organisation Unit name as displayed in DHIS2"

// -- Hierarchy (partOf) ------------------------------------------------------
// In DHIS2, every org unit except the root has a parent. This creates the
// tree structure. FHIR's Organization.partOf models the same parent-child
// relationship. Data aggregation in DHIS2 flows from children to parents:
// a district's totals are the sum of its facilities' data.
// ----------------------------------------------------------------------------
* partOf MS
* partOf ^short = "Parent org unit in the DHIS2 hierarchy"
* partOf ^definition = """
Reference to the parent Organisation Unit. This mirrors the DHIS2 org unit
tree. The root org unit (e.g., Ministry of Health) has no parent.
"""

// -- Type --------------------------------------------------------------------
// The type of organization. This can map to DHIS2 org unit groups (e.g.,
// 'Hospital', 'Health Center', 'CHW Post') or represent the hierarchical
// level (national, provincial, district, facility).
// ----------------------------------------------------------------------------
* type MS
* type ^short = "Organization type (maps to DHIS2 org unit group or level)"
* type ^definition = """
Classifies this organization. Can represent the hierarchical level
(national, district, facility) from DHIS2OrgUnitLevelVS, or the facility
type (hospital, CHC, CHP) from DHIS2OrgUnitGroupVS. Both may be provided
simultaneously — one type for the level, another for the facility group.
"""


// ----------------------------------------------------------------------------
// Profile: DHIS2Location
// ----------------------------------------------------------------------------
// Captures the physical/geographic aspects of a DHIS2 Organisation Unit.
//
// DHIS2 supports two types of coordinates on org units:
//   - POINT: a single latitude/longitude pair (for facilities)
//   - POLYGON: a set of coordinate pairs (for catchment areas/boundaries)
//
// This profile focuses on point coordinates, which are the most common case
// for health facilities. The coordinates enable DHIS2's powerful GIS features:
//   - Facility distribution maps
//   - Thematic maps (coloring facilities by indicator values)
//   - Catchment area analysis
//   - Distance calculations
//
// The managingOrganization reference links back to the DHIS2Organization,
// connecting the physical and administrative representations.
// ----------------------------------------------------------------------------
Profile: DHIS2Location
Parent: Location
Id: dhis2-location
Title: "DHIS2 Location"
Description: """
Represents the physical/geographic attributes of a DHIS2 Organisation Unit.
While DHIS2 combines administrative and geographic aspects in a single
org unit concept, FHIR separates them: Organization handles the institutional
identity and hierarchy, Location handles the physical presence and coordinates.

DHIS2 stores GPS coordinates (latitude/longitude) and optional polygon
geometries on org units. These power the GIS/mapping engine in DHIS2,
enabling spatial analysis and map-based data visualization. This profile
captures point coordinates via Location.position and links to the
corresponding DHIS2Organization via managingOrganization.
"""

// -- Name --------------------------------------------------------------------
// The location name, typically identical to the DHIS2 org unit name.
// ----------------------------------------------------------------------------
* name 1..1 MS
* name ^short = "Location name (usually matches the org unit name)"

// -- Position ----------------------------------------------------------------
// GPS coordinates for this location. In DHIS2, coordinates can be entered
// manually, captured via mobile GPS (Android Capture app), or imported from
// GIS datasets. Latitude and longitude use the WGS84 datum (decimal degrees).
// ----------------------------------------------------------------------------
* position MS
* position ^short = "GPS coordinates from the DHIS2 org unit"
* position ^definition = """
The geographic coordinates (latitude/longitude) of this org unit as stored
in DHIS2. These enable map-based visualization and spatial analysis.
"""
* position.latitude MS
* position.latitude ^short = "Latitude in decimal degrees (WGS84)"
* position.longitude MS
* position.longitude ^short = "Longitude in decimal degrees (WGS84)"

// -- Managing Organization ---------------------------------------------------
// Links this Location to the DHIS2Organization that operates it. In most
// DHIS2 deployments this is a 1:1 relationship.
// ----------------------------------------------------------------------------
* managingOrganization 1..1 MS
* managingOrganization ^short = "The DHIS2Organization managing this location"
* managingOrganization only Reference(DHIS2Organization)
