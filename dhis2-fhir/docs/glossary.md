## Glossary

This glossary provides quick definitions for key terms used throughout the DHIS2-FHIR Learning Guide. Terms are sorted alphabetically. Each entry includes a pointer to where the term is covered in more depth.

If you are completely new to FHIR and DHIS2, start by reading the entries for **FHIR**, **Resource**, **Profile**, and **FSH** to build a mental model before diving into the rest.

---

### Aggregate Data

Pre-summarized or counted data, such as "number of malaria cases this month in District X." In DHIS2, aggregate data is collected through Data Sets and stored as Data Value Sets, in contrast to individual-level Tracker Data. See also: Data Set, Data Value Set, Tracker Data. Covered in [DHIS2 and FHIR](ch06-dhis2-fhir/index.md).

### Alias

A shorthand label in FSH that lets you refer to a long URL with a short name, such as `Alias: $loinc = http://loinc.org`. Aliases make FSH files easier to read and maintain. Covered in [Aliases](ch04-fsh-101/aliases.md).

### Base Resource

The original, unconstrained definition of a FHIR resource type as defined in the FHIR specification. When you create a profile, you start from a base resource and add constraints. For example, the DHIS2Patient profile starts from the base Patient resource and adds requirements specific to DHIS2. See also: Profile, Resource. Covered in [Profiles](ch04-fsh-101/profiles.md).

### Binding

A rule that ties a coded element in a FHIR resource to a specific ValueSet, controlling which codes are allowed. Bindings have a **strength** that determines how strictly the ValueSet must be followed:

- **required** -- only codes from the ValueSet are allowed; no exceptions.
- **extensible** -- codes from the ValueSet should be used if a suitable code exists, but other codes are permitted when no match is found.
- **preferred** -- the ValueSet is recommended but not enforced.
- **example** -- the ValueSet is provided purely as an illustration.

See also: ValueSet, CodeSystem. Covered in [Value Sets and Code Systems](ch04-fsh-101/valuesets-codesystems.md).

### Bundle

A FHIR resource that acts as a container for a collection of other resources. Bundles are used to send groups of resources together, for example when returning search results or submitting a transaction to a server. Common bundle types include `searchset` (search results), `transaction` (batch operations), and `document` (clinical documents like IPS). See also: Resource, IPS. Covered in [Bundle](ch01-fhir-overview/bundle.md) and [Bundle Examples](ch08-ig-reference/bundles.md).

### CapabilityStatement

A FHIR resource that declares what a server or client can do -- which resource types it supports, which operations are available, and which search parameters it understands. CapabilityStatements are part of a system's conformance declaration. See also: Conformance, Resource. Covered in [Validation and Testing](ch10-validation/index.md).

### Cardinality

A pair of numbers (like `0..1` or `1..*`) that specifies how many times an element may or must appear. The first number is the minimum and the second is the maximum (`*` means unlimited). Profiles often tighten cardinality to make optional elements required or to remove unwanted elements. See also: Profile, Element. Covered in [Profiles](ch04-fsh-101/profiles.md).

### Category Option Combo

A DHIS2 concept that represents a specific combination of disaggregation categories for a data element -- for example, "Female, 15-24 years." Category option combos allow a single data element to be broken down along multiple dimensions. Covered in [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### CodeableConcept

A FHIR data type used to represent a concept that can be expressed as one or more coded values plus optional text. It allows the same meaning to be conveyed using codes from different code systems simultaneously (e.g., both a LOINC code and a SNOMED CT code). See also: CodeSystem, ValueSet. Covered in [Data Types and Formats](ch01-fhir-overview/data-types.md).

### CodeSystem

A FHIR resource that defines a set of codes and their meanings, such as LOINC for lab tests or SNOMED CT for clinical terms. CodeSystems provide the actual codes; ValueSets select subsets of codes from one or more CodeSystems for use in a particular context. See also: ValueSet, Binding. Covered in [Value Sets and Code Systems](ch04-fsh-101/valuesets-codesystems.md).

### Composition

A FHIR resource that defines the structure of a clinical document by listing its sections and the resources each section references. It acts as a table of contents for a document-type Bundle such as an International Patient Summary. See also: Bundle, IPS. Covered in [IPS Profiles](ch11-ips/profiles.md).

### Conformance

The degree to which a FHIR implementation follows the rules defined in the base specification and any applicable profiles. Conformance resources -- such as StructureDefinitions, ValueSets, and CapabilityStatements -- formally describe what a system must support. See also: Profile, StructureDefinition. Covered in [Validation and Testing](ch10-validation/index.md).

### Data Element

A DHIS2 concept that represents a single piece of data to be collected, such as "Number of confirmed malaria cases" or "Patient weight." Data elements are the building blocks of Data Sets and Program Stages. See also: Data Set, Program Stage. Covered in [DHIS2 and FHIR](ch06-dhis2-fhir/index.md) and [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### Data Set

A DHIS2 collection of data elements that are reported together on a regular schedule (e.g., monthly). Data Sets are used for aggregate data collection and map conceptually to FHIR Measure and MeasureReport resources. See also: Aggregate Data, Data Element. Covered in [DHIS2 Patterns](ch07-measure/dhis2-patterns.md).

### Data Value Set

A DHIS2 payload that contains a set of reported data values for a particular data set, period, and organisation unit. It is the aggregate equivalent of submitting individual records. See also: Data Set, Aggregate Data. Covered in [DHIS2 Patterns](ch07-measure/dhis2-patterns.md).

### DHIS2

District Health Information Software 2, an open-source platform widely used in low- and middle-income countries for health data collection, analysis, and reporting. DHIS2 supports both aggregate data (through Data Sets) and individual-level data (through Tracker programs). This guide focuses on mapping DHIS2 concepts to FHIR. See also: Aggregate Data, Tracker Data. Covered in [DHIS2 and FHIR](ch06-dhis2-fhir/index.md).

### Discriminator

The element used to tell apart different slices within a sliced element. For example, when slicing `Patient.identifier`, the discriminator might be `identifier.system` -- the system URL determines which slice each identifier belongs to. See also: Slice / Slicing, Profile. Covered in [Slicing](ch04-fsh-101/slicing.md).

### Element

A single field within a FHIR resource, such as `Patient.name` or `Observation.value`. Elements have a data type, cardinality, and may be constrained further in profiles. See also: Cardinality, Profile. Covered in [FHIR Resources](ch01-fhir-overview/resources.md) and [Data Types and Formats](ch01-fhir-overview/data-types.md).

### Encounter

A FHIR resource that represents a single interaction between a patient and a healthcare provider, such as a clinic visit, a phone consultation, or a hospital admission. See also: EpisodeOfCare, Patient. Covered in [Encounter](ch01-fhir-overview/encounter.md).

### Enrollment

The act of registering a Tracked Entity Instance into a DHIS2 Program. An enrollment links a person (or other tracked entity) to a specific program and opens a timeline of events and data capture. See also: Program, Tracked Entity Instance. Covered in [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### EpisodeOfCare

A FHIR resource that groups related Encounters and activities under a single care context over a longer period of time, such as an entire pregnancy care episode or a chronic disease management period. See also: Encounter. Covered in [EpisodeOfCare](ch01-fhir-overview/episodeofcare.md).

### Event

A single data-capture occurrence within a DHIS2 Program Stage, representing one form submission (e.g., one ANC visit). Events may be anonymous (event programs) or linked to a Tracked Entity Instance (tracker programs). See also: Program Stage, Tracked Entity Instance. Covered in [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### Extension

A mechanism in FHIR for adding data elements that are not part of the base resource definition. Extensions let you capture information specific to your use case without breaking compatibility with the standard. Each extension has a URL that uniquely identifies it and a value of a specified data type. In FSH, extensions are defined with the `Extension` keyword. See also: Profile, Element. Covered in [Extensions](ch04-fsh-101/extensions.md) and [Extensions Reference](ch08-ig-reference/extensions.md).

### FHIR (Fast Healthcare Interoperability Resources)

An international standard published by HL7 for exchanging healthcare data electronically. FHIR defines a set of resources (Patient, Observation, etc.) and a REST API for reading and writing them. It is designed to be easy to implement and widely adoptable. See also: HL7, Resource, REST API. Covered in [Introduction to FHIR](ch01-fhir-overview/index.md).

### FHIR R4

The fourth major release of the FHIR specification (version 4.0.1), published in 2019. R4 is the first "normatively stable" release, meaning its core resources will not have breaking changes in future versions. This guide uses FHIR R4. See also: FHIR. Covered in [Introduction to FHIR](ch01-fhir-overview/index.md).

### FHIRPath

An expression language used within FHIR for navigating and extracting data from resources. FHIRPath is used in invariants, search parameter definitions, and slicing discriminators. For example, `Patient.name.where(use = 'official').given` selects the given name from the official name entry. See also: Invariant, SearchParameter. Covered in [Invariants](ch04-fsh-101/invariants.md).

### FSH (FHIR Shorthand)

A domain-specific language for writing FHIR conformance resources (profiles, extensions, value sets, etc.) in a concise, human-readable text format. FSH files are compiled into standard FHIR JSON or XML by the SUSHI tool. See also: SUSHI, Profile. Covered in [Introduction to FSH](ch02-fsh-introduction/index.md) and [FSH 101](ch04-fsh-101/index.md).

### HL7

Health Level Seven International, the standards organization that publishes FHIR and other healthcare interoperability standards (including the older HL7 v2 messaging standard). HL7 is responsible for the governance, development, and balloting of the FHIR specification. See also: FHIR.

### Identifier

A FHIR data type that assigns a unique label to a resource, typically consisting of a system (a URI namespace) and a value. Identifiers let you match resources across different systems -- for example, linking a FHIR Patient to a DHIS2 Tracked Entity Instance by their shared national ID. See also: Patient, UID. Covered in [Data Types and Formats](ch01-fhir-overview/data-types.md).

### IG Publisher

The official HL7 tool that takes SUSHI output (and other FHIR artifacts) and produces a complete, browsable HTML website for your Implementation Guide. The IG Publisher validates all resources, generates narrative pages, and creates the downloadable package. See also: Implementation Guide, SUSHI. Covered in [Publishing](ch05-first-ig/publishing.md).

### Implementation Guide (IG)

A published package of FHIR profiles, extensions, value sets, examples, and documentation that describes how FHIR should be used for a specific purpose or in a specific country. Building an IG is the main practical goal of this guide. See also: Profile, SUSHI. Covered in [Building Your First IG](ch05-first-ig/index.md) and [IG Profile Reference](ch08-ig-reference/index.md).

### Indicator

A DHIS2 concept that calculates a derived value from one or more data elements, typically expressed as a numerator and denominator (e.g., "ANC coverage = ANC visits / expected pregnancies"). Indicators map conceptually to FHIR Measure resources. See also: Data Element, Data Set. Covered in [DHIS2 Patterns](ch07-measure/dhis2-patterns.md).

### Instance

In FSH, a concrete example of a resource that conforms to a particular profile. Instances are used to create sample data for testing and documentation within an Implementation Guide. You define them with the `Instance` keyword and provide values for the profile's elements. See also: Profile, Implementation Guide. Covered in [Instances](ch04-fsh-101/instances.md).

### Interoperability

The ability of different health information systems to exchange, interpret, and use data meaningfully. FHIR was designed specifically to lower the barrier to interoperability by using web standards (REST, JSON) and a clear resource model. See also: FHIR, REST API, Implementation Guide.

### Invariant

A formal constraint rule defined in FSH (or in a StructureDefinition) that must evaluate to true for a resource to be valid. Invariants use FHIRPath expressions to express business rules such as "if status is 'completed', an end date must be present." See also: Profile, Conformance. Covered in [Invariants](ch04-fsh-101/invariants.md).

### IPS (International Patient Summary)

A standardized, minimal clinical document defined by HL7 and ISO that summarizes a patient's essential health information for cross-border or unplanned care scenarios. An IPS is represented in FHIR as a Bundle containing a Composition resource. See also: Composition, Bundle. Covered in [International Patient Summary](ch11-ips/index.md).

### JSON

JavaScript Object Notation, a lightweight text format for representing structured data as key-value pairs and arrays. JSON is the most common encoding for FHIR resources and is used throughout this guide for examples and API interactions. See also: FHIR, REST API. Covered in [Data Types and Formats](ch01-fhir-overview/data-types.md).

### Location

A FHIR resource that represents a physical place where healthcare services are provided, such as a building, ward, or room. Location is often used alongside Organization -- an Organization manages the facility while a Location describes where it physically is. See also: Organization, Organisation Unit. Covered in [Organization and Location](ch01-fhir-overview/organization-location.md).

### Logical Model

A FSH construct that defines a data structure without tying it to a specific FHIR resource type. Logical models are useful for representing source-system schemas (like DHIS2 tracker data models) that you then map to FHIR resources. See also: Mapping. Covered in [Logical Models](ch04-fsh-101/logical-models.md) and [Logical Models and Mappings](ch08-ig-reference/logical-models.md).

### LOINC

Logical Observation Identifiers Names and Codes, an international terminology for identifying laboratory and clinical observations. LOINC codes are widely used in FHIR Observation resources to specify what was measured or observed. See also: CodeSystem, SNOMED CT. Covered in [Observation](ch01-fhir-overview/observation.md).

### Mapping

A FSH construct that documents how elements in one data model correspond to elements in another. Mappings can show the relationship between a DHIS2 logical model and FHIR resources, serving as both documentation and a guide for implementers. See also: Logical Model. Covered in [Mappings](ch04-fsh-101/mappings.md) and [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### Measure / MeasureReport

A pair of FHIR resources for defining and reporting population-level metrics. A **Measure** describes what is being measured (e.g., "percentage of children fully immunized"), while a **MeasureReport** contains the actual computed values for a specific period and location. These map naturally to DHIS2 indicators and aggregate reports. See also: Indicator, Data Set, Aggregate Data. Covered in [Measure and MeasureReport](ch07-measure/index.md) and [Measure Profiles](ch08-ig-reference/measure-profiles.md).

### Meta

A FHIR element present on every resource that carries metadata such as the resource's version ID, last-updated timestamp, and the list of profiles it claims to conform to. The `meta.profile` array is how a resource declares which profiles it follows. See also: Profile, Resource.

### Modifier Extension

A special kind of Extension that can change the meaning of the element or resource it appears in. Because modifier extensions can alter interpretation, systems that do not understand them must not process the resource. Regular extensions, by contrast, can be safely ignored. See also: Extension. Covered in [Extensions](ch04-fsh-101/extensions.md).

### Must Support (MS)

A flag on a FHIR element in a profile that indicates implementers must be able to store, display, or otherwise handle that element. The exact meaning of "must support" is defined by each Implementation Guide. See also: Profile, Conformance. Covered in [Profiles](ch04-fsh-101/profiles.md).

### Narrative

A human-readable XHTML summary embedded within a FHIR resource (in the `text` element). Narratives allow clinicians and other users to view resource content even without software that understands the structured data. See also: Resource. Covered in [FHIR Resources](ch01-fhir-overview/resources.md).

### Observation

A FHIR resource used to record a single measurement, test result, or clinical finding about a patient -- for example, a blood pressure reading, a lab result, or a survey answer. Observations are one of the most commonly used FHIR resources. See also: Patient, CodeableConcept. Covered in [Observation](ch01-fhir-overview/observation.md) and [Clinical Profiles](ch08-ig-reference/clinical-profiles.md).

### OperationOutcome

A FHIR resource returned by a server to communicate the result of an operation, especially errors and warnings. When a validation or submission fails, the OperationOutcome tells you what went wrong and where. See also: Conformance. Covered in [Validation and Testing](ch10-validation/index.md).

### Organisation Unit

A DHIS2 concept representing a node in the health system hierarchy, such as a country, region, district, or facility. Organisation units map to FHIR Organization and Location resources. See also: Organization. Covered in [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### Organization

A FHIR resource that represents a formally recognized grouping of people or entities, such as a hospital, government ministry, or NGO. See also: Organisation Unit. Covered in [Organization and Location](ch01-fhir-overview/organization-location.md) and [Organization and Location Profiles](ch08-ig-reference/organization-profiles.md).

### Patient

A FHIR resource that represents a person receiving healthcare services. It holds demographics like name, date of birth, gender, and identifiers. The Patient resource is central to most FHIR workflows. See also: Tracked Entity Instance. Covered in [Patient](ch01-fhir-overview/patient.md) and [DHIS2Patient Profile](ch08-ig-reference/patient-profile.md).

### Period

A FHIR data type consisting of a start and an optional end date/time, used to express a span of time. Periods appear in many resources, such as Encounter (when the visit happened) and EpisodeOfCare (the duration of a care episode). Covered in [Data Types and Formats](ch01-fhir-overview/data-types.md).

### Profile

A set of constraints applied to a base FHIR resource to adapt it for a specific use case. Profiles can tighten cardinality, fix values, add extensions, and restrict value sets. In FSH, you define a profile with the `Profile` keyword. See also: Cardinality, Extension, Must Support. Covered in [Profiles](ch04-fsh-101/profiles.md) and [IG Profile Reference](ch08-ig-reference/index.md).

### Program

A DHIS2 concept for collecting individual-level (tracker) data. A program defines what data is captured for each tracked entity and through which stages. Programs map conceptually to combinations of FHIR resources such as EpisodeOfCare, Encounter, and Questionnaire. See also: Program Stage, Enrollment, Tracker Data. Covered in [DHIS2 and FHIR](ch06-dhis2-fhir/index.md) and [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### Program Stage

A step within a DHIS2 Program that defines a specific data collection form. A program can have one or more stages (e.g., "ANC First Visit," "ANC Follow-up"). Each stage may be repeatable. Program stages map to FHIR Encounters or QuestionnaireResponses. See also: Program, Event. Covered in [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### Quantity

A FHIR data type that represents a measured value with a unit, system, and code -- for example, `72 kg` or `120 mmHg`. Quantity is commonly used in Observation values. See also: Observation, UCUM. Covered in [Data Types and Formats](ch01-fhir-overview/data-types.md).

### Questionnaire / QuestionnaireResponse

A pair of FHIR resources. A **Questionnaire** defines a structured form (questions, answer types, skip logic), while a **QuestionnaireResponse** captures the answers a specific person gave. Together they are a natural fit for representing DHIS2 program stage forms. See also: Program Stage. Covered in [Questionnaire and QuestionnaireResponse](ch01-fhir-overview/questionnaire.md) and [Questionnaire Profiles](ch08-ig-reference/questionnaire-profiles.md).

### Reference

A FHIR data type that creates a link from one resource to another, typically written as `"reference": "Patient/123"`. References are how FHIR expresses relationships -- for example, an Observation references the Patient it belongs to. See also: Resource, Identifier. Covered in [Data Types and Formats](ch01-fhir-overview/data-types.md).

### Resource

The fundamental unit of data in FHIR. Each resource type (Patient, Observation, Bundle, etc.) has a defined structure with specific elements. Resources can be read, created, updated, and deleted via the FHIR REST API. See also: FHIR, Element, REST API. Covered in [FHIR Resources](ch01-fhir-overview/resources.md).

### Resource ID

A server-assigned identifier that uniquely identifies a resource instance within a FHIR server. The resource ID appears in the URL (e.g., `Patient/abc123`) and is different from business Identifiers. Resource IDs are assigned by the server, while Identifiers are assigned by external systems. See also: Identifier, Resource.

### REST API

Representational State Transfer Application Programming Interface. FHIR defines a REST API that uses standard HTTP methods (GET, POST, PUT, DELETE) to interact with resources on a server. This is the primary way systems exchange FHIR data. See also: Resource, JSON. Covered in [FHIR REST API Search](ch12-fhir-search/index.md).

### RuleSet

A reusable block of FSH rules that can be inserted into multiple profiles, extensions, or instances to avoid repetition. RuleSets act like macros -- they are expanded in place wherever you apply them. See also: Profile. Covered in [RuleSets](ch04-fsh-101/rulesets.md).

### SearchParameter

A FHIR resource that defines how a specific element can be searched on a FHIR server. SearchParameters specify the name, path, and data type of a search, enabling queries like `GET /Patient?birthdate=1990-01-01`. See also: REST API, Resource. Covered in [Search Parameters](ch12-fhir-search/search-parameters.md).

### Slice / Slicing

A profiling technique in FHIR that divides a repeating element into named sub-groups, each with its own constraints. For example, you can slice `Patient.identifier` into separate entries for a national ID and a medical record number, each with different cardinality and value requirements. See also: Profile, Cardinality, Discriminator. Covered in [Slicing](ch04-fsh-101/slicing.md).

### SNOMED CT

Systematized Nomenclature of Medicine -- Clinical Terms, a comprehensive international clinical terminology. SNOMED CT provides codes for clinical findings, procedures, body structures, and more. It is one of the most widely used code systems in FHIR. See also: CodeSystem, LOINC. Covered in [Terminology](ch08-ig-reference/terminology.md).

### StructureDefinition

The underlying FHIR resource that formally describes the shape of a resource, profile, or extension. When you write a Profile or Extension in FSH, SUSHI compiles it into a StructureDefinition in JSON format. See also: Profile, Extension, FSH. Covered in [Profiles](ch04-fsh-101/profiles.md).

### SUSHI

The reference compiler for FSH. SUSHI reads `.fsh` files and produces FHIR JSON resources (StructureDefinitions, ValueSets, instances, etc.) that can be fed into the IG Publisher. The name originally stood for "SUSHI Unshortens ShortHand Inputs." See also: FSH, Implementation Guide. Covered in [SUSHI Configuration](ch05-first-ig/sushi-config.md) and [Development Environment](ch03-dev-environment/index.md).

### sushi-config.yaml

The configuration file at the root of an FSH project that tells SUSHI about your Implementation Guide -- its name, version, publisher, FHIR version, and which dependencies it uses. This file controls how SUSHI compiles your FSH definitions. See also: SUSHI, Implementation Guide. Covered in [SUSHI Configuration](ch05-first-ig/sushi-config.md).

### Terminology

In FHIR, a collective term for the resources and infrastructure that manage coded data -- primarily CodeSystems, ValueSets, and ConceptMaps. Good terminology design is essential for interoperability because it ensures that different systems understand codes in the same way. See also: CodeSystem, ValueSet, Binding. Covered in [Terminology](ch08-ig-reference/terminology.md).

### Tracked Entity Attribute (TEA)

A field defined on a DHIS2 tracked entity type that stores demographic or identifying information, such as "First name," "Date of birth," or "National ID." TEAs map to elements on the FHIR Patient resource or to Identifier entries. See also: Tracked Entity Instance, Patient. Covered in [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### Tracked Entity Instance (TEI)

A single record of a tracked entity in DHIS2, typically representing an individual person. A TEI can be enrolled in one or more programs and is the DHIS2 equivalent of a FHIR Patient resource. See also: Patient, Enrollment. Covered in [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### Tracker Data

Individual-level, longitudinal data collected through DHIS2 tracker programs, as opposed to Aggregate Data. Tracker data captures events tied to specific people over time. See also: Aggregate Data, Program, Tracked Entity Instance. Covered in [DHIS2 and FHIR](ch06-dhis2-fhir/index.md).

### UCUM

The Unified Code for Units of Measure, a code system for representing units of measurement in healthcare and science (e.g., `kg`, `mmHg`, `mg/dL`). FHIR requires UCUM codes in Quantity values to ensure units are unambiguous. See also: Quantity, CodeSystem. Covered in [Data Types and Formats](ch01-fhir-overview/data-types.md).

### UID

A DHIS2 unique identifier, an 11-character alphanumeric string (e.g., `Zj7UnCAulEk`) that identifies every metadata and data object in DHIS2. UIDs serve a similar purpose to FHIR resource IDs and are often carried across into FHIR as Identifier values. See also: Identifier. Covered in [Mapping Concepts](ch06-dhis2-fhir/mapping-concepts.md).

### Validation

The process of checking whether a FHIR resource conforms to the base specification and any applicable profiles. Validation catches errors like missing required elements, invalid codes, or cardinality violations. The FHIR Validator and IG Publisher both perform validation automatically. See also: Conformance, OperationOutcome, Profile. Covered in [Validation and Testing](ch10-validation/index.md).

### ValueSet

A FHIR resource that defines a specific selection of codes drawn from one or more CodeSystems. ValueSets are bound to coded elements in profiles to control which values are acceptable. For example, a ValueSet might include only the gender codes "male," "female," and "unknown." See also: CodeSystem, Binding. Covered in [Value Sets and Code Systems](ch04-fsh-101/valuesets-codesystems.md) and [Terminology](ch08-ig-reference/terminology.md).

### XML

Extensible Markup Language, an alternative encoding format for FHIR resources alongside JSON. While both formats are fully supported by the FHIR specification, this guide uses JSON for all examples. See also: JSON, FHIR.
