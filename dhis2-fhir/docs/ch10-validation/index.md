# Validation and Testing

Every FHIR resource you author in FSH is ultimately a claim: "this data conforms to a particular set of rules." Validation is the process of checking whether that claim holds. Without validation, profiles are just documentation -- they describe what data *should* look like but never enforce it. With validation, profiles become executable contracts that catch errors before they reach production systems.

This matters especially in the DHIS2 context. Data flows between DHIS2 Tracker, aggregate reporting systems, and FHIR-based exchanges. If a Patient resource claims to conform to `DHIS2Patient` but is missing the required DHIS2 UID identifier, a receiving system that depends on that identifier will fail silently or reject the data. Validation catches these problems at authoring time, not deployment time.

## Levels of validation

FHIR validation is not a single check. It operates at four distinct levels, each catching a different class of error.

### 1. Structural validation

The most basic level: does the JSON (or XML) conform to the base FHIR specification?

- Is `resourceType` set to a valid FHIR resource type?
- Are all element names recognized? (A typo like `birhDate` instead of `birthDate` is caught here.)
- Are data types correct? (A string where a date is expected, or a number where a code is expected.)
- Are arrays used where FHIR expects arrays, and scalars where FHIR expects scalars?

Structural validation requires no profiles at all -- it validates against the base FHIR R4 schema. Most JSON/XML parsing errors fall into this category.

### 2. Profile validation

Does the resource satisfy the constraints declared in a StructureDefinition (profile)?

This is where your FSH-authored profiles are tested. The validator checks:

- **Cardinality**: `DHIS2Patient` requires `identifier 1..*`, `name 1..*`, `gender 1..1`, and `birthDate 1..1`. A Patient with no `birthDate` fails.
- **Must Support**: Elements flagged `MS` must be understood by conformant systems. The validator warns if Must Support elements are absent (depending on configuration).
- **Fixed values**: `identifier[dhis2uid].system` is fixed to `http://dhis2.org/fhir/id/tracked-entity`. Any other value is a validation error.
- **Slicing**: The `identifier` element in `DHIS2Patient` is sliced by `type`. The validator checks that the discriminator pattern (`$V2-0203#RI` for the `dhis2uid` slice) matches the instance data. If the discriminator does not match, the instance fails to land in the correct slice.

### 3. Terminology validation

Are coded values drawn from the correct CodeSystem or ValueSet?

Every coded element in FHIR can have a *binding* to a ValueSet with a binding strength:

- **required** -- the code *must* come from the specified ValueSet. Using a code outside the set is an error. Example: `Patient.gender` is bound to `AdministrativeGender` with required strength -- only `male`, `female`, `other`, and `unknown` are valid.
- **extensible** -- the code *should* come from the ValueSet, but if no suitable code exists, an alternative is allowed with a warning.
- **preferred** and **example** -- progressively looser guidance.

In the DHIS2-FHIR IG, custom CodeSystems like `DHIS2DataElementTypeCS` have companion ValueSets with required bindings. If you use a code like `NUMERIC` instead of the correct `NUMBER`, terminology validation catches it.

### 4. Business rule validation (invariants)

Do FHIRPath invariants evaluate to `true`?

Invariants express rules that cannot be captured by cardinality or type constraints alone. The DHIS2-FHIR IG defines several:

- **`dhis2-uid-format`**: Checks that `identifier[dhis2uid].value` matches the regex `^[a-zA-Z][a-zA-Z0-9]{10}$`. A value like `12345678901` (starts with a digit) or `abc` (too short) fails this invariant.
- **`dhis2-birthdate-not-future`**: Ensures `Patient.birthDate` is not in the future using the FHIRPath expression `$this <= today()`.
- **`dhis2-identifier-has-system`**: Verifies that every Identifier carries a `system` URI.

When an invariant with severity `#error` fails, validation fails. Invariants with severity `#warning` produce warnings but do not block.

## Using the IG Publisher for validation

The DHIS2-FHIR project provides two Make targets that run validation at different levels.

### Fast feedback: `make docker-sushi`

SUSHI compiles FSH into FHIR JSON. During compilation it catches:

- FSH syntax errors (missing keywords, unbalanced quotes, bad indentation)
- References to undefined profiles, extensions, or aliases
- Duplicate resource IDs
- Invalid slice names or discriminator configurations

SUSHI does **not** run the full FHIR validator. It checks FSH-level correctness, not FHIR-level conformance. This makes it fast -- typically a few seconds.

```bash
make docker-sushi
```

A successful run produces output like:

```
info  Running SUSHI on /home/publisher/ig ...
info  Imported 8 Aliases
info  Imported 3 Invariants
info  Imported 7 Profiles
info  Imported 3 Extensions
info  Imported 12 ValueSets
info  Imported 12 CodeSystems
info  Imported 22 Instances
...
info  Assembled 22 Instance(s)
```

Errors appear with `error` prefix and a file path. Fix them before proceeding to a full build.

### Full validation: `make docker-build`

The IG Publisher runs SUSHI first, then invokes the FHIR Validator against every generated resource and example instance. It also builds the HTML output and produces a QA report.

```bash
make docker-build
```

This takes longer (minutes, not seconds) because the validator downloads terminology packages, resolves all references, and checks every level of validation described above.

### Reading the QA report

After a successful build, open `ig/output/qa.html` in your browser. The QA report lists:

- **Errors** (red): Must be fixed. The IG is not considered valid with outstanding errors.
- **Warnings** (yellow): Should be reviewed. Some are expected (e.g., "Experimental profile" warnings during development).
- **Information** (blue): Informational messages about best practices.

Each entry links to the specific resource and element that triggered the message.

## Common validation errors

These are the errors you are most likely to encounter when developing the DHIS2-FHIR IG, along with their causes and fixes.

### "No matching discriminator"

**Cause**: A slicing discriminator does not match the instance data. In `DHIS2Patient`, identifiers are sliced by `type` using a pattern discriminator. If an example instance provides an identifier without the expected `type` coding, the validator cannot assign it to a slice.

**Example**: You write an identifier with `system = $DHIS2-TEI` and `value = "DXz2k5eGbri"` but forget to set `type = $V2-0203#RI`. The validator sees an identifier that does not match the `dhis2uid` slice discriminator.

**Fix**: Ensure the discriminator element matches exactly. Using the `DHIS2PatientIdentifiers` RuleSet avoids this problem because it sets `type` automatically.

### "Profile reference could not be resolved"

**Cause**: The resource claims conformance to a profile URL that the validator cannot find. This usually means a typo in the profile URL or a missing dependency.

**Fix**: Verify the profile URL in `meta.profile` or `InstanceOf` matches the actual profile canonical URL defined in `sushi-config.yaml` plus the profile ID.

### "Required element missing"

**Cause**: A cardinality constraint is violated. For example, `DHIS2Patient` requires `birthDate 1..1`. If an example instance omits `birthDate`, this error appears.

**Fix**: Add the missing element to the instance. Check the profile's differential to see which elements are required.

### "Value not in required value set"

**Cause**: A coded element uses a code that is not in the bound ValueSet, and the binding strength is `required`. For instance, setting `gender = #nonbinary` would fail because `AdministrativeGender` (required binding) does not include that code.

**Fix**: Use a code from the bound ValueSet. If the ValueSet is too restrictive, consider whether the binding strength should be `extensible` instead of `required` in your profile.

### "Invariant violation"

**Cause**: A FHIRPath invariant evaluated to `false`. For example, the `dhis2-uid-format` invariant rejects a value like `1234567890a` because it starts with a digit.

**Fix**: Correct the data to satisfy the invariant expression. The error message includes the invariant name and description.

## Common SUSHI errors

SUSHI errors occur during FSH compilation, before the FHIR Validator runs. They appear in the console output of `make docker-sushi`.

### "Cannot find definition for X"

A profile, extension, resource, or alias referenced in FSH is not defined anywhere. Common causes:

- Missing `Alias` declaration -- you used `$SCT` but forgot to define it in `aliases.fsh`.
- Typo in a profile name -- `InstanceOf: DHIS2Patients` instead of `DHIS2Patient`.
- Missing dependency -- referencing a profile from an external IG that is not listed in `sushi-config.yaml` dependencies.

### "Invalid FSH syntax"

The FSH parser could not understand the input. Look for:

- Missing colons after keywords (`Profile DHIS2Patient` instead of `Profile: DHIS2Patient`)
- Unmatched triple-quote strings (`"""`)
- Incorrect rule syntax (e.g., `* identifier 1..*` missing the `MS` flag when intended)

### "Duplicate definition"

Two resources share the same `Id`. Every profile, extension, instance, CodeSystem, and ValueSet must have a unique `Id` within the IG. Check for copy-paste errors where you duplicated a resource but forgot to change the `Id`.

### "Cannot resolve reference"

An instance references another instance (via `Reference()`) that does not exist. For example, `Reference(OrganizationFacilityA)` will fail if there is no `Instance: OrganizationFacilityA` defined in any `.fsh` file.

## Testing strategies

Validation is only as good as the examples you validate against. A profile with no example instances is untested. Here are practical strategies for thorough testing.

### Write examples that exercise all constraints

Every profile should have at least one example instance that populates all required and Must Support elements. In the DHIS2-FHIR IG, `PatientJaneDoe` is the primary example for `DHIS2Patient` -- it exercises both identifier slices (`dhis2uid` and `national`), name, gender, birthDate, address, and the orgUnit extension.

```
Instance: PatientJaneDoe
InstanceOf: DHIS2Patient
Usage: #example

* insert DHIS2PatientIdentifiers(DXz2k5eGbri, 12345678901, urn:oid:2.16.454.1)
* name[0].family = "Doe"
* name[0].given[0] = "Jane"
* gender = #female
* birthDate = "1990-05-15"
* extension[orgUnit].valueReference = Reference(OrganizationFacilityA)
```

Multiple examples (`PatientJohnKamau`, `PatientAminaHassan`) test the same profile with different data, increasing confidence that the constraints work across varied inputs.

### Test boundary cases

Boundary cases are instances that sit at the edge of what the profile allows. They help verify that constraints are neither too strict nor too lenient:

- An identifier value at exactly 11 characters (valid) vs. 10 or 12 characters (should fail `dhis2-uid-format`)
- A `birthDate` set to today's date (valid -- `$this <= today()`) vs. tomorrow (should fail `dhis2-birthdate-not-future`)
- An identifier with only the required `dhis2uid` slice and no `national` slice (valid -- `national` is `0..1`)

Boundary-case instances can use `Usage: #example` so the validator checks them during the build.

### Use ignoreWarnings.txt for known warnings

Some validation warnings are expected and acceptable. The IG Publisher supports an `ignoreWarnings.txt` file in the `ig/input/` directory where you can suppress specific warnings so they do not clutter the QA report. Each line contains a warning message pattern to ignore.

Use this sparingly -- only for warnings you have explicitly reviewed and decided to accept. Do not suppress errors.

### The iterative workflow

The most effective development workflow alternates between fast and full validation:

1. **Edit** `.fsh` files in `ig/input/fsh/`.
2. **Run `make docker-sushi`** for fast feedback. Fix any FSH syntax errors or missing definitions. This takes seconds.
3. **Iterate** on steps 1-2 until SUSHI compiles cleanly.
4. **Run `make docker-build`** for full FHIR validation. Review `ig/output/qa.html` for errors and warnings. This takes minutes.
5. **Fix** any validation errors found in the QA report.
6. **Repeat** from step 1 as needed.

This two-stage approach keeps the feedback loop tight. You only wait for the full IG Publisher build when you are confident the FSH is syntactically correct.

## Summary

Validation turns FHIR profiles from documentation into enforceable contracts. The four levels -- structural, profile, terminology, and business rules -- each catch different classes of errors. The DHIS2-FHIR IG toolchain provides two validation paths: `make docker-sushi` for fast FSH-level checks and `make docker-build` for full FHIR validation via the IG Publisher. Writing thorough example instances and reviewing the QA report are the practical habits that keep an IG correct and interoperable.
