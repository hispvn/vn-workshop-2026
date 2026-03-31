# Hands-on Exercises

Exercises 1–5:

| # | Topic | What you'll build |
|---|-------|-------------------|
| 01 | Profiles | Constrain Patient for DHIS2 |
| 02 | Extensions | Add Organisation Unit |
| 03 | Value Sets & Code Systems | Define coded vocabularies |
| 04 | Instances | Create example data |
| 05 | Logical Models | Model a DHIS2 Tracked Entity |

Each has `instructions.md`, `starter.fsh`, and `solution.fsh`. Compile with `make docker-sushi`.

---

# Exercises 6–10

| # | Topic | What you'll build |
|---|-------|-------------------|
| 06 | Mappings | Map Tracked Entity → Patient |
| 07 | RuleSets | Reusable rule patterns |
| 08 | Aliases | URI shorthand |
| 09 | Invariants | FHIRPath validation rules |
| 10 | Slicing | Split identifiers (DHIS2 UID vs National ID) |

---

# Summary

### What we covered

<v-clicks>

- **FHIR basics** — resources, JSON structure, REST API
- **DHIS2 ↔ FHIR mapping** — why Questionnaire, how linkId works
- **Profiles & terminology** — constraining resources, extensions, ValueSets
- **The pipeline** — DHIS2 metadata → FSH → SUSHI → FHIR API
- **Lao EIR** — CHR patients, organizations, IPS cross-border

</v-clicks>

---

# Try It Yourself

### Run the app
```sh
make seed    # generate test data
make run     # http://localhost:8000
```

### Do the exercises
```sh
exercises/01-profiles/instructions.md
```

### Read the docs
```sh
make docs-serve
```

---

# Resources & Questions

### Links
- **FHIR spec:** https://hl7.org/fhir/
- **FSH/SUSHI:** https://fshschool.org/
- **DHIS2 + FHIR:** https://dhis2.org/integration/fhir/

<div class="text-center mt-12 text-2xl">

### Questions?

</div>
