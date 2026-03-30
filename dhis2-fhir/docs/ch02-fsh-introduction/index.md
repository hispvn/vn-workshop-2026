# Introduction to FSH

FHIR Shorthand (FSH, pronounced "fish") is a domain-specific language for defining FHIR Implementation Guides. Instead of writing complex JSON or XML StructureDefinitions by hand, FSH lets you express profiles, extensions, value sets, and other FHIR artifacts in a concise, human-readable syntax. It was created to make Implementation Guide authoring accessible to a much wider audience, including clinicians and analysts who may not be comfortable editing raw FHIR JSON.

FSH files are compiled into standard FHIR resources by a tool called **SUSHI** (SUSHI Unshortens ShortHand Inputs). SUSHI reads your `.fsh` files, resolves dependencies, applies rules, and produces the JSON StructureDefinitions, ValueSets, CodeSystems, and other artifacts that the IG Publisher needs. The relationship is straightforward: you write FSH, SUSHI compiles it, and the IG Publisher turns it into a polished, browsable Implementation Guide.

The advantage of FSH over hand-editing JSON is significant. A profile that might take 100 lines of JSON can often be expressed in 10-15 lines of FSH. FSH handles the boilerplate, lets you focus on the constraints that matter, and produces valid, consistent output every time. Throughout this guide, we will write all our FHIR definitions in FSH and use SUSHI (via Docker) to compile them.
