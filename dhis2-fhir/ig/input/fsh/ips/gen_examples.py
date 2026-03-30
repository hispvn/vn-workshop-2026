#!/usr/bin/env python3
"""Generate 55 IPS example instances as FSH.

Produces:
  - 55 DHIS2IPSPatient instances
  - 200+ DHIS2IPSImmunization instances (3-7 per patient)
  - 55 DHIS2IPSComposition instances
  - 55 DHIS2IPSBundle instances

Run:  python ig/input/fsh/ips/gen_examples.py
Output: ig/input/fsh/ips/examples-generated.fsh
"""

import random
import string
from pathlib import Path

random.seed(99)

# ---------------------------------------------------------------------------
# Data pools
# ---------------------------------------------------------------------------

FEMALE_NAMES = [
    "Khamla",
    "Viengkham",
    "Bouakham",
    "Chansouk",
    "Daovone",
    "Ketsana",
    "Latsamee",
    "Manivan",
    "Nithaya",
    "Phailin",
    "Soukanya",
    "Thipphavanh",
    "Vanida",
    "Chanthaly",
    "Phoutsady",
    "Beatrice",
    "Maria",
    "Grace",
    "Fatou",
    "Nadia",
]
MALE_NAMES = [
    "Somchai",
    "Bounmy",
    "Khamphone",
    "Souliya",
    "Thongchanh",
    "Vilaphone",
    "Anousone",
    "Bounkham",
    "Chanthala",
    "Douangchai",
    "Phouthone",
    "Xaysana",
    "Kaisone",
    "Outhong",
    "Sithong",
    "Emmanuel",
    "Carlos",
    "Ahmed",
    "Felix",
    "Victor",
]
FAMILY_NAMES = [
    "Vongsa",
    "Phommasan",
    "Keomany",
    "Sisoulith",
    "Chanthavong",
    "Douangmala",
    "Intharath",
    "Khamphoui",
    "Latsaphao",
    "Manivong",
    "Phetlasy",
    "Souvannavong",
    "Thammavong",
    "Xayavong",
    "Bounphanith",
    "Garcia",
    "Santos",
    "Kamara",
    "Hernandez",
    "Mensah",
]

LAO_PDR = ("Lao PDR", "LA", ["Vientiane", "Savannakhet", "Luang Prabang", "Pakse", "Thakhek"])
FOREIGN_COUNTRIES = [
    ("Sierra Leone", "SL", ["Freetown", "Bo", "Kenema"]),
    ("Kenya", "KE", ["Nairobi", "Mombasa", "Kisumu"]),
    ("Ghana", "GH", ["Accra", "Kumasi", "Tamale"]),
    ("Thailand", "TH", ["Bangkok", "Chiang Mai", "Phuket"]),
    ("Vietnam", "VN", ["Hanoi", "Ho Chi Minh", "Da Nang"]),
]

# ~90% Lao, ~10% foreign
COUNTRIES = [LAO_PDR] * 9 + FOREIGN_COUNTRIES

# CVX code, display, target disease SNOMED code, target disease display, route
# Display values must match the terminology server's canonical displays exactly.
VACCINES = [
    ("19", "BCG", "56717001", "Tuberculosis", "IM"),
    ("08", "Hep B, adolescent or pediatric", "66071002", "Type B viral hepatitis", "IM"),
    ("02", "trivalent poliovirus vaccine, live, oral", "398102009", "Acute poliomyelitis", "oral"),
    ("10", "poliovirus vaccine, inactivated", "398102009", "Acute poliomyelitis", "IM"),
    (
        "20",
        "diphtheria, tetanus toxoids and acellular pertussis vaccine",
        "397430003",
        "Diphtheria caused by Corynebacterium diphtheriae",
        "IM",
    ),
    (
        "17",
        "Haemophilus influenzae type b vaccine, conjugate unspecified formulation",
        "23511006",
        "Meningococcal infectious disease",
        "IM",
    ),
    ("133", "Pneumococcal conjugate PCV 13", "16814004", "Pneumococcal infectious disease", "IM"),
    ("116", "rotavirus, live, pentavalent vaccine", "18624000", "Disease caused by Rotavirus", "oral"),
    ("03", "measles, mumps and rubella virus vaccine", "14189004", "Measles", "SC"),
    ("21", "varicella virus vaccine", "38907003", "Varicella", "SC"),
    ("83", "Hep A, ped/adol, 2 dose", "40468003", "Viral hepatitis, type A", "IM"),
    ("37", "yellow fever live", "16541001", "Yellow fever", "SC"),
    ("88", "influenza, unspecified formulation", "6142004", "Influenza", "IM"),
    ("62", "HPV, quadrivalent", "240532009", "Human papilloma virus infection", "IM"),
    (
        "115",
        "tetanus toxoid, reduced diphtheria toxoid, and acellular pertussis vaccine, adsorbed",
        "397430003",
        "Diphtheria caused by Corynebacterium diphtheriae",
        "IM",
    ),
    (
        "114",
        "meningococcal polysaccharide (groups A, C, Y and W-135) diphtheria toxoid conjugate vaccine (MCV4P)",
        "23511006",
        "Meningococcal infectious disease",
        "IM",
    ),
    (
        "208",
        "SARS-COV-2 (COVID-19) vaccine, mRNA, spike protein, LNP, preservative free, 30 mcg/0.3mL dose",
        "840539006",
        "Disease caused by severe acute respiratory syndrome coronavirus 2",
        "IM",
    ),
    (
        "207",
        "COVID-19, mRNA, LNP-S, PF, 100 mcg/0.5mL dose or 50 mcg/0.25mL dose",
        "840539006",
        "Disease caused by severe acute respiratory syndrome coronavirus 2",
        "IM",
    ),
    (
        "212",
        "COVID-19 vaccine, vector-nr, rS-Ad26, PF, 0.5 mL",
        "840539006",
        "Disease caused by severe acute respiratory syndrome coronavirus 2",
        "IM",
    ),
    (
        "511",
        "COVID-19 IV Non-US Vaccine (CoronaVac, Sinovac)",
        "840539006",
        "Disease caused by severe acute respiratory syndrome coronavirus 2",
        "IM",
    ),
    ("33", "pneumococcal polysaccharide vaccine, 23 valent", "16814004", "Pneumococcal infectious disease", "IM"),
    ("52", "Hep A, adult", "40468003", "Viral hepatitis, type A", "IM"),
    (
        "09",
        "tetanus and diphtheria toxoids, adsorbed, preservative free, for adult use (2 Lf of tetanus toxoid and 2 Lf of diphtheria toxoid)",
        "76902006",
        "Tetanus",
        "IM",
    ),
    ("25", "typhoid vaccine, live, oral", "4834000", "Typhoid fever", "oral"),
    ("40", "rabies vaccine, for intradermal injection", "14168008", "Rabies", "IM"),
]

ROUTE_MAP = {
    "IM": ("78421000", "Intramuscular route (qualifier value)"),
    "SC": ("34206005", "Subcutaneous route (qualifier value)"),
    "oral": ("26643006", "Oral route (qualifier value)"),
}

SITE_IM = [
    ("368208006", "Left upper arm structure"),
    ("368209003", "Right upper arm structure"),
    ("61396006", "Structure of left thigh"),
    ("11207009", "Structure of right thigh"),
]

LOT_PREFIXES = ["AB", "CD", "EF", "GH", "JK", "LM", "NP", "QR", "ST", "UV"]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def dhis2_uid() -> str:
    first = random.choice(string.ascii_letters)
    rest = "".join(random.choices(string.ascii_letters + string.digits, k=10))
    return first + rest


def make_id(prefix: str) -> str:
    return prefix + "".join(random.choices(string.ascii_lowercase + string.digits, k=6))


def rand_date(y_min: int, y_max: int) -> str:
    y = random.randint(y_min, y_max)
    m = random.randint(1, 12)
    d = random.randint(1, 28)
    return f"{y:04d}-{m:02d}-{d:02d}"


def lot_number() -> str:
    return random.choice(LOT_PREFIXES) + str(random.randint(1000, 9999))


def sanitize(name: str) -> str:
    """Make a valid FSH instance name."""
    return name.replace(" ", "").replace("-", "").replace("'", "")


# ---------------------------------------------------------------------------
# Generate
# ---------------------------------------------------------------------------


def generate() -> str:
    lines: list[str] = []
    w = lines.append

    w("// ============================================================================")
    w("// AUTO-GENERATED IPS Examples — do not edit manually")
    w("// Generated by gen_examples.py with random.seed(99)")
    w("// ============================================================================")
    w("")

    patients_info: list[dict] = []

    for i in range(55):
        gender = random.choice(["male", "female"])
        given = random.choice(MALE_NAMES if gender == "male" else FEMALE_NAMES)
        family = random.choice(FAMILY_NAMES)
        country_name, country_code, cities = random.choice(COUNTRIES)
        city = random.choice(cities)
        uid = dhis2_uid()
        birth = rand_date(1955, 2020)
        pid = f"ips-patient-{i + 1:03d}"
        inst_name = f"IPSPatient{i + 1:03d}"

        patients_info.append(
            {
                "inst": inst_name,
                "pid": pid,
                "given": given,
                "family": family,
                "gender": gender,
                "birth": birth,
                "uid": uid,
                "country_code": country_code,
                "city": city,
                "country_name": country_name,
            }
        )

        # --- Patient instance ---
        w(f"Instance: {inst_name}")
        w("InstanceOf: DHIS2IPSPatient")
        w(f'Title: "IPS Patient — {given} {family}"')
        w(f'Description: "{given} {family}, {gender}, born {birth}, from {city}, {country_name}."')
        w("Usage: #example")
        w(f'* id = "{pid}"')
        w("* identifier[dhis2uid].system = $DHIS2-TEI")
        w("* identifier[dhis2uid].type = $V2-0203#RI")
        w(f'* identifier[dhis2uid].value = "{uid}"')
        if random.random() < 0.7:
            nat_id = f"{country_code}-{''.join(random.choices(string.digits, k=8))}"
            w(f'* identifier[national].system = "urn:oid:2.16.{random.randint(100, 999)}.1"')
            w("* identifier[national].type = $V2-0203#NI")
            w(f'* identifier[national].value = "{nat_id}"')
        w(f'* name[0].family = "{family}"')
        w(f'* name[0].given[0] = "{given}"')
        w("* name[0].use = #official")
        w(f"* gender = #{gender}")
        w(f'* birthDate = "{birth}"')
        w(f'* address[0].city = "{city}"')
        w(f'* address[0].country = "{country_code}"')
        w("* address[0].use = #home")
        w("* active = true")
        w("")

    # --- Immunizations per patient ---
    all_immz: list[dict] = []  # track {inst, patient_inst, immz_ids} for composition

    for pinfo in patients_info:
        n_vaccines = random.randint(3, 7)
        chosen = random.sample(VACCINES, min(n_vaccines, len(VACCINES)))
        patient_immz: list[str] = []
        patient_immz_ids: list[str] = []

        for j, (cvx, display, disease_code, disease_display, route_key) in enumerate(chosen):
            imm_id = f"ips-imm-{pinfo['pid'].split('-')[-1]}-{j + 1:02d}"
            imm_inst = f"IPSImm{pinfo['inst'][10:]}{j + 1:02d}"
            route_code, route_display = ROUTE_MAP[route_key]

            dose = j + 1
            occ_date = rand_date(2018, 2025)
            lot = lot_number()

            patient_immz.append(imm_inst)
            patient_immz_ids.append(imm_id)

            w(f"Instance: {imm_inst}")
            w("InstanceOf: DHIS2IPSImmunization")
            w(f'Title: "Immunization — {pinfo["given"]} {pinfo["family"]} — {display}"')
            w(f'Description: "{display} dose {dose} for {pinfo["given"]} {pinfo["family"]} on {occ_date}."')
            w("Usage: #example")
            w(f'* id = "{imm_id}"')
            w("* status = #completed")
            w('* vaccineCode.coding[cvx].system = "http://hl7.org/fhir/sid/cvx"')
            w(f"* vaccineCode.coding[cvx].code = #{cvx}")
            w(f'* vaccineCode.coding[cvx].display = "{display}"')
            w(f"* patient = Reference({pinfo['inst']})")
            w(f'* occurrenceDateTime = "{occ_date}"')
            w(f'* lotNumber = "{lot}"')
            if route_key != "oral":
                site_code, site_display = random.choice(SITE_IM)
                w('* site.coding[0].system = "http://snomed.info/sct"')
                w(f"* site.coding[0].code = #{site_code}")
                w(f'* site.coding[0].display = "{site_display}"')
            w('* route.coding[0].system = "http://snomed.info/sct"')
            w(f"* route.coding[0].code = #{route_code}")
            w(f'* route.coding[0].display = "{route_display}"')
            w(f"* protocolApplied[0].doseNumberPositiveInt = {dose}")
            w('* protocolApplied[0].targetDisease[0].coding[0].system = "http://snomed.info/sct"')
            w(f"* protocolApplied[0].targetDisease[0].coding[0].code = #{disease_code}")
            w(f'* protocolApplied[0].targetDisease[0].coding[0].display = "{disease_display}"')
            w("")

        all_immz.append({"patient": pinfo, "immz_insts": patient_immz, "immz_ids": patient_immz_ids})

    # --- Compositions ---
    for idx, entry in enumerate(all_immz):
        pinfo = entry["patient"]
        immz_insts = entry["immz_insts"]
        comp_inst = f"IPSComposition{idx + 1:03d}"
        comp_id = f"ips-composition-{idx + 1:03d}"

        w(f"Instance: {comp_inst}")
        w("InstanceOf: DHIS2IPSComposition")
        w(f'Title: "IPS Composition — {pinfo["given"]} {pinfo["family"]}"')
        w(f'Description: "International Patient Summary for {pinfo["given"]} {pinfo["family"]}."')
        w("Usage: #example")
        w(f'* id = "{comp_id}"')
        w("* status = #final")
        w('* type = http://loinc.org#60591-5 "Patient summary Document"')
        w(f"* subject = Reference({pinfo['inst']})")
        w('* date = "2025-01-15"')
        w('* author[0].display = "DHIS2 System"')
        w('* title = "International Patient Summary"')
        w('* section[immunizations].title = "Immunizations"')
        w('* section[immunizations].code = http://loinc.org#11369-6 "History of Immunization note"')
        for k, imm_name in enumerate(immz_insts):
            w(f"* section[immunizations].entry[{k}] = Reference({imm_name})")
        w("")

    # --- Bundles ---
    for idx, entry in enumerate(all_immz):
        pinfo = entry["patient"]
        immz_insts = entry["immz_insts"]
        imm_ids = entry["immz_ids"]
        bundle_inst = f"IPSBundle{idx + 1:03d}"
        bundle_id = f"ips-bundle-{idx + 1:03d}"
        comp_inst = f"IPSComposition{idx + 1:03d}"
        comp_id = f"ips-composition-{idx + 1:03d}"
        base = "http://dhis2.org/fhir/learning"

        w(f"Instance: {bundle_inst}")
        w("InstanceOf: DHIS2IPSBundle")
        w(f'Title: "IPS Bundle — {pinfo["given"]} {pinfo["family"]}"')
        w(f'Description: "Complete IPS document bundle for {pinfo["given"]} {pinfo["family"]}."')
        w("Usage: #example")
        w(f'* id = "{bundle_id}"')
        w("* type = #document")
        w('* identifier.system = "http://dhis2.org/fhir/learning/bundle-id"')
        w(f'* identifier.value = "{bundle_id}"')
        w('* timestamp = "2025-01-15T10:00:00Z"')
        # Entry 0: Composition
        e = 0
        w(f'* entry[{e}].fullUrl = "{base}/Composition/{comp_id}"')
        w(f"* entry[{e}].resource = {comp_inst}")
        e += 1
        # Entry 1: Patient
        w(f'* entry[{e}].fullUrl = "{base}/Patient/{pinfo["pid"]}"')
        w(f"* entry[{e}].resource = {pinfo['inst']}")
        e += 1
        # Remaining: Immunizations
        for imm_name, imm_id in zip(immz_insts, imm_ids):
            w(f'* entry[{e}].fullUrl = "{base}/Immunization/{imm_id}"')
            w(f"* entry[{e}].resource = {imm_name}")
            e += 1
        w("")

    return "\n".join(lines)


if __name__ == "__main__":
    out = Path(__file__).parent / "examples-generated.fsh"
    content = generate()
    out.write_text(content)
    # Count instances
    n_patients = content.count("InstanceOf: DHIS2IPSPatient")
    n_imm = content.count("InstanceOf: DHIS2IPSImmunization")
    n_comp = content.count("InstanceOf: DHIS2IPSComposition")
    n_bundle = content.count("InstanceOf: DHIS2IPSBundle")
    print(f"Generated {out}")
    print(f"  {n_patients} patients, {n_imm} immunizations, {n_comp} compositions, {n_bundle} bundles")
    print(f"  Total: {n_patients + n_imm + n_comp + n_bundle} instances")
