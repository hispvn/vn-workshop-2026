# Introduction to FHIR

FHIR (Fast Healthcare Interoperability Resources, pronounced "fire") is a standard for exchanging healthcare information electronically. Developed by HL7 International, FHIR defines a set of data models called "resources" and a RESTful API for reading, writing, and searching health data. It was designed from the ground up to be easy to implement, leveraging modern web technologies like JSON, HTTP, and OAuth.

At its core, FHIR is built around a RESTful API paradigm. Each resource type (Patient, Observation, Encounter, and so on) has a well-defined URL endpoint. You interact with these endpoints using standard HTTP methods: `GET` to read, `POST` to create, `PUT` to update, and `DELETE` to remove. For example, retrieving a patient might look like `GET /Patient/123`, while searching for all observations for that patient could be `GET /Observation?subject=Patient/123`. This simplicity is what makes FHIR accessible to any developer familiar with web APIs.

FHIR matters for health data exchange because it provides a common language. Before FHIR, integrating health systems often meant writing custom point-to-point interfaces -- expensive, fragile, and hard to maintain. FHIR gives systems a shared set of resource definitions and interaction patterns, dramatically reducing the effort required to connect systems. It is now the mandated standard in many countries and is supported by major EHR vendors, public health systems, and platforms like DHIS2.

In the following sections, we will look at the building blocks of FHIR: resources, data types, and serialization formats. Understanding these fundamentals is essential before moving on to authoring your own FHIR profiles with FSH.
