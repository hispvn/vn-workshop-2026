"""
Seed script — generates 120 realistic FHIR Patient resources and immunizations.

Usage:
    uv run python -m dhis2_fhir.seed

Generates patients with realistic names, randomized demographics,
DHIS2 UIDs, national IDs, and addresses across several countries commonly
using DHIS2. Includes 20 Lao PDR patients with additional identifier types,
phone numbers, district data, and clientHealthId. Also generates immunization
records for Lao patients following the national EPI schedule.
"""

from __future__ import annotations

import logging
import random
import string
from typing import Any

from .store import save_resource

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Name pools (common names from DHIS2-using countries)
# ---------------------------------------------------------------------------

GIVEN_NAMES_FEMALE = [
    "Amina",
    "Fatima",
    "Aisha",
    "Mariam",
    "Zainab",
    "Hawa",
    "Bintu",
    "Isatu",
    "Kadiatu",
    "Mariama",
    "Adama",
    "Fanta",
    "Salimata",
    "Aminata",
    "Nana",
    "Grace",
    "Esther",
    "Agnes",
    "Rose",
    "Mary",
    "Sarah",
    "Ruth",
    "Joyce",
    "Eunice",
    "Patience",
    "Abigail",
    "Comfort",
    "Mercy",
    "Dorcas",
    "Gladys",
    "Beatrice",
    "Dorothy",
    "Catherine",
    "Margaret",
    "Elizabeth",
    "Nyarai",
    "Tendai",
    "Rumbidzai",
    "Chipo",
    "Tsitsi",
    "Ama",
    "Akua",
    "Adjoa",
    "Efua",
    "Esi",
    "Wanjiku",
    "Njeri",
    "Akinyi",
    "Atieno",
    "Nafula",
]

GIVEN_NAMES_MALE = [
    "Mohamed",
    "Ibrahim",
    "Abdulai",
    "Alhaji",
    "Sorie",
    "Musa",
    "Alpha",
    "Brima",
    "Foday",
    "Komba",
    "Lansana",
    "Samuel",
    "Joseph",
    "James",
    "John",
    "David",
    "Daniel",
    "Peter",
    "Paul",
    "Stephen",
    "Andrew",
    "Emmanuel",
    "Charles",
    "Francis",
    "George",
    "Patrick",
    "Michael",
    "Robert",
    "Thomas",
    "William",
    "Kwame",
    "Kofi",
    "Yaw",
    "Kwesi",
    "Osei",
    "Kamau",
    "Mwangi",
    "Ochieng",
    "Otieno",
    "Kipchoge",
    "Tendai",
    "Tatenda",
    "Farai",
    "Simba",
    "Takudzwa",
    "Oumar",
    "Mamadou",
    "Boubacar",
    "Sekou",
    "Ibrahima",
]

FAMILY_NAMES = [
    "Kamara",
    "Sesay",
    "Koroma",
    "Bangura",
    "Conteh",
    "Turay",
    "Kargbo",
    "Mansaray",
    "Jalloh",
    "Bah",
    "Diallo",
    "Sow",
    "Barry",
    "Conde",
    "Keita",
    "Traore",
    "Coulibaly",
    "Ouattara",
    "Toure",
    "Camara",
    "Okafor",
    "Adeyemi",
    "Okonkwo",
    "Mensah",
    "Asante",
    "Boateng",
    "Owusu",
    "Amponsah",
    "Agyemang",
    "Nkrumah",
    "Mwangi",
    "Kamau",
    "Ochieng",
    "Wanjiku",
    "Njoroge",
    "Kimani",
    "Moyo",
    "Banda",
    "Phiri",
    "Mwale",
    "Chikwanda",
    "Dlamini",
    "Nkosi",
    "Zulu",
    "Ndlovu",
    "Hassan",
    "Omar",
    "Ali",
    "Ahmed",
    "Mohammed",
]

LAO_GIVEN_NAMES_FEMALE = [
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
]

LAO_GIVEN_NAMES_MALE = [
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
]

LAO_FAMILY_NAMES = [
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
]

COUNTRIES: list[dict[str, Any]] = [
    {"country": "Sierra Leone", "code": "SL", "cities": ["Freetown", "Bo", "Kenema", "Makeni", "Koidu"]},
    {"country": "Kenya", "code": "KE", "cities": ["Nairobi", "Mombasa", "Kisumu", "Nakuru", "Eldoret"]},
    {"country": "Malawi", "code": "MW", "cities": ["Lilongwe", "Blantyre", "Mzuzu", "Zomba", "Mangochi"]},
    {"country": "Ghana", "code": "GH", "cities": ["Accra", "Kumasi", "Tamale", "Cape Coast", "Takoradi"]},
    {"country": "Tanzania", "code": "TZ", "cities": ["Dar es Salaam", "Dodoma", "Arusha", "Mwanza", "Mbeya"]},
    {"country": "Uganda", "code": "UG", "cities": ["Kampala", "Gulu", "Mbarara", "Jinja", "Lira"]},
    {"country": "Guinea", "code": "GN", "cities": ["Conakry", "Nzerekore", "Kankan", "Kindia", "Labe"]},
    {"country": "Mozambique", "code": "MZ", "cities": ["Maputo", "Beira", "Nampula", "Quelimane", "Tete"]},
]

LAO_COUNTRY = {
    "country": "Lao PDR",
    "code": "LA",
    "cities": ["Vientiane", "Savannakhet", "Luang Prabang", "Pakse", "Thakhek"],
    "districts": ["Chanthabuly", "Sisattanak", "Xaysetha", "Kaysone", "Luang Prabang"],
}

# Org unit hierarchy: (province, province_code, district, district_code, village, village_code)
LAO_ORG_UNITS = [
    ("Vientiane Capital", "OU_VTE", "Chanthabuly", "OU_VTE_CTB", "Anou", "OU_VTE_CTB_ANU"),
    ("Vientiane Capital", "OU_VTE", "Chanthabuly", "OU_VTE_CTB", "Hatsady", "OU_VTE_CTB_HSD"),
    ("Vientiane Capital", "OU_VTE", "Sisattanak", "OU_VTE_SSN", "Thongkhankham", "OU_VTE_SSN_TKK"),
    ("Savannakhet", "OU_SVK", "Kaysone Phomvihane", "OU_SVK_KPV", "Naxeng", "OU_SVK_KPV_NXG"),
    ("Savannakhet", "OU_SVK", "Kaysone Phomvihane", "OU_SVK_KPV", "Phonsavang", "OU_SVK_KPV_PSV"),
    ("Savannakhet", "OU_SVK", "Outhoumphone", "OU_SVK_OTP", "Nakham", "OU_SVK_OTP_NKM"),
    ("Savannakhet", "OU_SVK", "Atsaphangthong", "OU_SVK_APT", "Dongsavanh", "OU_SVK_APT_DSV"),
    ("Luang Prabang", "OU_LPB", "Luang Prabang", "OU_LPB_LPB", "Xiengthong", "OU_LPB_LPB_XTG"),
    ("Luang Prabang", "OU_LPB", "Chomphet", "OU_LPB_CPT", "Chomphet", "OU_LPB_CPT_CPT"),
    ("Luang Prabang", "OU_LPB", "Pak Ou", "OU_LPB_PKO", "Pak Ou", "OU_LPB_PKO_PKO"),
]

# Phone number prefixes by country code
PHONE_PREFIXES = {
    "SL": "+232",
    "KE": "+254",
    "MW": "+265",
    "GH": "+233",
    "TZ": "+255",
    "UG": "+256",
    "GN": "+224",
    "MZ": "+258",
    "LA": "+856-20",
}


def _generate_dhis2_uid() -> str:
    """Generate a DHIS2-style 11-character UID (letter + 10 alphanumeric)."""
    first = random.choice(string.ascii_letters)
    rest = "".join(random.choices(string.ascii_letters + string.digits, k=10))
    return first + rest


def _generate_national_id(country: str, birth_year: int) -> str:
    """Generate a plausible national ID for a given country."""
    prefix = country[:2].upper()
    seq = random.randint(10000, 99999)
    return f"{prefix}-{birth_year}-{seq}"


def _generate_phone(country_code: str) -> str:
    """Generate a plausible phone number."""
    prefix = PHONE_PREFIXES.get(country_code, "+1")
    digits = "".join(str(random.randint(0, 9)) for _ in range(7))
    return f"{prefix}-{digits}"


def _make_identifier(
    system: str, value: str, code: str, display: str, code_system: str = "http://terminology.hl7.org/CodeSystem/v2-0203"
) -> dict:
    """Build a FHIR Identifier dict."""
    return {
        "system": system,
        "value": value,
        "type": {"coding": [{"system": code_system, "code": code, "display": display}]},
    }


def generate_patient(index: int) -> dict:
    """Generate a single realistic FHIR Patient resource."""
    gender = random.choice(["male", "female"])
    if gender == "female":
        given = random.choice(GIVEN_NAMES_FEMALE)
    else:
        given = random.choice(GIVEN_NAMES_MALE)
    family = random.choice(FAMILY_NAMES)

    # Random birth date between 1960 and 2020
    year = random.randint(1960, 2020)
    month = random.randint(1, 12)
    day = random.randint(1, 28)
    birth_date = f"{year:04d}-{month:02d}-{day:02d}"

    location = random.choice(COUNTRIES)
    city = random.choice(location["cities"])
    country = location["country"]
    country_code = location.get("code", country[:2].upper())

    dhis2_uid = _generate_dhis2_uid()
    patient_id = f"seed-patient-{index:03d}"

    # 70% chance of having a national ID
    has_national_id = random.random() < 0.7

    identifiers = [
        _make_identifier(
            "http://dhis2.org/fhir/id/tracked-entity",
            dhis2_uid,
            "RI",
            "Resource identifier",
        )
    ]

    if has_national_id:
        identifiers.append(
            _make_identifier(
                f"http://example.org/{country.lower().replace(' ', '-')}/national-id",
                _generate_national_id(country, year),
                "NI",
                "National identifier",
            )
        )

    address: dict = {"use": "home", "city": city, "country": country}

    # ~70% of patients get a phone number
    telecom: list[dict] = []
    if random.random() < 0.7:
        telecom.append(
            {
                "system": "phone",
                "value": _generate_phone(country_code),
                "use": "mobile",
            }
        )

    resource: dict = {
        "resourceType": "Patient",
        "id": patient_id,
        "meta": {
            "profile": ["http://dhis2.org/fhir/learning/StructureDefinition/dhis2-patient"],
        },
        "identifier": identifiers,
        "name": [{"use": "official", "family": family, "given": [given]}],
        "gender": gender,
        "birthDate": birth_date,
        "active": random.random() < 0.95,
        "address": [address],
    }

    if telecom:
        resource["telecom"] = telecom

    return resource


def _generate_client_health_id(birth_date: str, gender: str) -> str:
    """Generate a CHR clientHealthId: DDMMYYYY-SexCode-NNNN."""
    parts = birth_date.split("-")
    if len(parts) == 3:
        dd, mm, yyyy = parts[2], parts[1], parts[0]
    else:
        dd, mm, yyyy = "01", "01", "2000"
    sex_code = "1" if gender == "male" else "2"
    seq = f"{random.randint(0, 9999):04d}"
    return f"{dd}{mm}{yyyy}-{sex_code}-{seq}"


def generate_lao_patient(index: int) -> dict:
    """Generate a Lao PDR patient with additional identifier types."""
    gender = random.choice(["male", "female"])
    if gender == "female":
        given = random.choice(LAO_GIVEN_NAMES_FEMALE)
    else:
        given = random.choice(LAO_GIVEN_NAMES_MALE)
    family = random.choice(LAO_FAMILY_NAMES)

    year = random.randint(1960, 2020)
    month = random.randint(1, 12)
    day = random.randint(1, 28)
    birth_date = f"{year:04d}-{month:02d}-{day:02d}"

    org_unit = random.choice(LAO_ORG_UNITS)
    province, province_code, district, district_code, village, village_code = org_unit

    dhis2_uid = _generate_dhis2_uid()
    patient_id = f"seed-patient-{index:03d}"

    lao_cs = "http://moh.gov.la/fhir/CodeSystem/chr-identifier-type"

    identifiers = [
        _make_identifier(
            "http://dhis2.org/fhir/id/tracked-entity",
            dhis2_uid,
            "RI",
            "Resource identifier",
        )
    ]

    # National ID — all Lao patients get one
    identifiers.append(
        _make_identifier(
            "http://moh.gov.la/fhir/id/green-national-id",
            _generate_national_id("LA", year),
            "NI",
            "National identifier",
        )
    )

    # Client Health ID — all Lao patients get one
    chr_id = _generate_client_health_id(birth_date, gender)
    identifiers.append(
        _make_identifier(
            "http://moh.gov.la/fhir/id/client-health-id",
            chr_id,
            "CHR",
            "Community Health Record ID",
            lao_cs,
        )
    )

    # CVID (~40%)
    if random.random() < 0.4:
        identifiers.append(
            _make_identifier(
                "http://moh.gov.la/fhir/id/cvid",
                f"CVID-{random.randint(10000000, 99999999)}",
                "CVID",
                "Civil Registration and Vital Statistics ID",
                lao_cs,
            )
        )

    # Insurance (~30%)
    if random.random() < 0.3:
        identifiers.append(
            _make_identifier(
                "http://moh.gov.la/fhir/id/insurance",
                f"INS-LA-{random.randint(10000, 99999)}",
                "INS",
                "Insurance Number",
                lao_cs,
            )
        )

    # Green Card (~50%)
    if random.random() < 0.5:
        identifiers.append(
            _make_identifier(
                "http://moh.gov.la/fhir/id/green-national-id",
                f"GC-{random.randint(100000000000, 999999999999)}",
                "GREENCARD",
                "Lao Green National ID Card",
                lao_cs,
            )
        )

    # Passport (~10%)
    if random.random() < 0.1:
        identifiers.append(
            _make_identifier(
                "http://example.org/passport",
                f"LA-P{random.randint(100000, 999999)}",
                "PPN",
                "Passport",
            )
        )

    # Family Book (~20%)
    if random.random() < 0.2:
        identifiers.append(
            _make_identifier(
                "http://moh.gov.la/fhir/id/family-book",
                f"FB-{random.randint(10000, 99999)}",
                "FAMILYBOOK",
                "Family Book Number",
                lao_cs,
            )
        )

    # Phone — 80% of Lao patients
    telecom: list[dict] = []
    if random.random() < 0.8:
        telecom.append(
            {
                "system": "phone",
                "value": _generate_phone("LA"),
                "use": "mobile",
            }
        )

    # Coded demographic extensions
    chr_base = "http://moh.gov.la/fhir/CodeSystem"

    ethnicities = [
        ("ລາວ", "Lao"),
        ("ກຶມມຸ", "Khmou"),
        ("ມົ້ງ", "Hmong"),
        ("ຜູ້ໄທ", "Phouthai"),
        ("ໄຕ", "Tai"),
        ("ລື້", "Lue"),
        ("ອາຄາ", "Akha"),
        ("ມະກອງ", "Makong"),
    ]
    eth_code, eth_display = random.choice(ethnicities)

    occupations = [
        ("Farmer", "Farmer"),
        ("House_wife", "House wife"),
        ("Student", "Student"),
        ("Factory_worker", "Factory worker"),
        ("Driver", "Driver"),
        ("Merchant", "Merchant"),
        ("Health_Worker", "Health Worker"),
        ("Government", "Government"),
    ]
    occ_code, occ_display = random.choice(occupations)

    educations = [
        ("NONE", "None"),
        ("KDER", "Kindergarten"),
        ("PRI", "Primary"),
        ("2ND", "Secondary"),
        ("UNI", "University/College"),
    ]
    edu_code, edu_display = random.choice(educations)

    blood_groups = [
        ("A+", "A+"),
        ("A-", "A-"),
        ("B+", "B+"),
        ("B-", "B-"),
        ("O+", "O+"),
        ("O-", "O-"),
        ("AB+", "AB+"),
        ("AB-", "AB-"),
    ]
    bg_code, bg_display = random.choice(blood_groups)

    extensions = [
        {
            "url": "http://moh.gov.la/fhir/StructureDefinition/chr-nationality",
            "valueCodeableConcept": {
                "coding": [{"system": f"{chr_base}/chr-nationality", "code": "LA", "display": "Laos"}],
            },
        },
        {
            "url": "http://moh.gov.la/fhir/StructureDefinition/chr-ethnicity",
            "valueCodeableConcept": {
                "coding": [{"system": f"{chr_base}/chr-ethnicity", "code": eth_code, "display": eth_display}],
            },
        },
        {
            "url": "http://moh.gov.la/fhir/StructureDefinition/chr-occupation",
            "valueCodeableConcept": {
                "coding": [{"system": f"{chr_base}/chr-occupation", "code": occ_code, "display": occ_display}],
            },
        },
        {
            "url": "http://moh.gov.la/fhir/StructureDefinition/chr-education",
            "valueCodeableConcept": {
                "coding": [{"system": f"{chr_base}/chr-education", "code": edu_code, "display": edu_display}],
            },
        },
        {
            "url": "http://moh.gov.la/fhir/StructureDefinition/chr-blood-group",
            "valueCodeableConcept": {
                "coding": [{"system": f"{chr_base}/chr-blood-group", "code": bg_code, "display": bg_display}],
            },
        },
    ]

    resource: dict = {
        "resourceType": "Patient",
        "id": patient_id,
        "meta": {
            "profile": ["http://dhis2.org/fhir/learning/StructureDefinition/dhis2-chr-patient"],
        },
        "identifier": identifiers,
        "name": [{"use": "official", "family": family, "given": [given]}],
        "gender": gender,
        "birthDate": birth_date,
        "active": random.random() < 0.95,
        "address": [
            {
                "use": "home",
                "city": village,
                "district": district,
                "state": province,
                "country": "Lao PDR",
                "extension": [
                    {
                        "url": "http://moh.gov.la/fhir/StructureDefinition/chr-province-code",
                        "valueString": province_code,
                    },
                    {
                        "url": "http://moh.gov.la/fhir/StructureDefinition/chr-district-code",
                        "valueString": district_code,
                    },
                    {
                        "url": "http://moh.gov.la/fhir/StructureDefinition/chr-village-code",
                        "valueString": village_code,
                    },
                ],
            }
        ],
        "extension": extensions,
    }

    if telecom:
        resource["telecom"] = telecom

    return resource


# ---------------------------------------------------------------------------
# Immunization generation for Lao EPI schedule
# ---------------------------------------------------------------------------

# Lao EPI schedule: vaccine name, CVX code, CVX display, target SNOMED, target display
LAO_EPI_SCHEDULE = [
    ("BCG", "19", "BCG", "56717001", "Tuberculosis", 1),
    ("HepB0", "45", "Hepatitis B (birth dose)", "66071002", "Hepatitis B", 1),
    ("OPV1", "2", "Trivalent OPV", "398102009", "Poliomyelitis", 1),
    ("OPV2", "2", "Trivalent OPV", "398102009", "Poliomyelitis", 2),
    ("OPV3", "2", "Trivalent OPV", "398102009", "Poliomyelitis", 3),
    ("Penta1", "102", "DTP-Hib-HepB (Pentavalent)", "76902006", "Tetanus", 1),
    ("Penta2", "102", "DTP-Hib-HepB (Pentavalent)", "76902006", "Tetanus", 2),
    ("Penta3", "102", "DTP-Hib-HepB (Pentavalent)", "76902006", "Tetanus", 3),
    ("PCV1", "152", "Pneumococcal conjugate (PCV13)", "233604007", "Pneumonia", 1),
    ("PCV2", "152", "Pneumococcal conjugate (PCV13)", "233604007", "Pneumonia", 2),
    ("PCV3", "152", "Pneumococcal conjugate (PCV13)", "233604007", "Pneumonia", 3),
    ("IPV1", "10", "Inactivated poliovirus (IPV)", "398102009", "Poliomyelitis", 1),
    ("MR1", "94", "Measles-Rubella (MR)", "14189004", "Measles", 1),
    ("MR2", "94", "Measles-Rubella (MR)", "14189004", "Measles", 2),
    ("JE", "134", "Japanese Encephalitis", "52947006", "Japanese encephalitis", 1),
]


def _generate_immunization(
    patient_id: str, patient_name: str, birth_date: str, vaccine_info: tuple, index: int
) -> dict:
    """Generate a single Immunization resource."""
    short_name, cvx_code, cvx_display, snomed_code, snomed_display, dose_num = vaccine_info

    # Calculate occurrence: birth dose at birth, then spaced by months
    parts = birth_date.split("-")
    if len(parts) == 3:
        byear, bmonth, bday = int(parts[0]), int(parts[1]), int(parts[2])
    else:
        byear, bmonth, bday = 2000, 1, 1

    # Approximate vaccine timing by schedule position
    month_offset = {
        "BCG": 0,
        "HepB0": 0,
        "OPV1": 2,
        "Penta1": 2,
        "PCV1": 2,
        "OPV2": 4,
        "Penta2": 4,
        "PCV2": 4,
        "OPV3": 6,
        "Penta3": 6,
        "PCV3": 6,
        "IPV1": 4,
        "MR1": 9,
        "JE": 9,
        "MR2": 18,
    }
    offset_months = month_offset.get(short_name, 0)
    occ_month = bmonth + offset_months
    occ_year = byear + (occ_month - 1) // 12
    occ_month = ((occ_month - 1) % 12) + 1
    occ_date = f"{occ_year:04d}-{occ_month:02d}-{min(bday, 28):02d}"

    lot_prefix = short_name.replace(" ", "").upper()[:4]
    lot_number = f"{lot_prefix}-{random.randint(2020, 2025)}-{random.choice('ABCDEF')}{random.randint(100, 999)}"

    places = ["facility", "facility", "facility", "outreach", "mass"]
    place = random.choice(places)

    imm_id = f"imm-{patient_id}-{index:02d}"

    return {
        "resourceType": "Immunization",
        "id": imm_id,
        "meta": {
            "profile": ["http://dhis2.org/fhir/learning/StructureDefinition/dhis2-chr-immunization"],
        },
        "status": "completed",
        "vaccineCode": {
            "coding": [
                {
                    "system": "http://hl7.org/fhir/sid/cvx",
                    "code": cvx_code,
                    "display": cvx_display,
                }
            ]
        },
        "patient": {
            "reference": f"Patient/{patient_id}",
            "display": patient_name,
        },
        "occurrenceDateTime": occ_date,
        "lotNumber": lot_number,
        "protocolApplied": [
            {
                "doseNumberPositiveInt": dose_num,
                "targetDisease": [
                    {
                        "coding": [
                            {
                                "system": "http://snomed.info/sct",
                                "code": snomed_code,
                                "display": snomed_display,
                            }
                        ]
                    }
                ],
            }
        ],
        "extension": [
            {
                "url": "http://moh.gov.la/fhir/StructureDefinition/chr-place-of-vaccination",
                "valueCode": place,
            }
        ],
    }


def generate_immunizations_for_patient(patient: dict) -> list[dict]:
    """Generate 2-5 immunization records for a Lao patient."""
    pid = patient["id"]
    name_obj = patient.get("name", [{}])[0]
    given = " ".join(name_obj.get("given", []))
    family = name_obj.get("family", "")
    display_name = f"{given} {family}".strip()
    birth_date = patient.get("birthDate", "2000-01-01")

    # Pick a random subset of vaccines (2-5)
    num_vaccines = random.randint(2, 5)
    selected = random.sample(LAO_EPI_SCHEDULE, min(num_vaccines, len(LAO_EPI_SCHEDULE)))

    immunizations = []
    for idx, vaccine in enumerate(selected, 1):
        imm = _generate_immunization(pid, display_name, birth_date, vaccine, idx)
        immunizations.append(imm)

    return immunizations


def seed_patients(count: int = 5, lao_count: int = 115) -> None:
    """Generate and save seed patients and immunizations."""
    random.seed(42)  # Deterministic for reproducibility
    for i in range(1, count + 1):
        patient = generate_patient(i)
        save_resource(patient)

    lao_patients = []
    for i in range(count + 1, count + lao_count + 1):
        patient = generate_lao_patient(i)
        save_resource(patient)
        lao_patients.append(patient)

    # Generate immunizations for Lao patients
    imm_count = 0
    for patient in lao_patients:
        immunizations = generate_immunizations_for_patient(patient)
        for imm in immunizations:
            save_resource(imm)
            imm_count += 1

    logger.info("Created %d seed patients in data/Patient/", count + lao_count)
    logger.info("Created %d immunizations in data/Immunization/", imm_count)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    seed_patients()
