"""Generate FSH example QuestionnaireResponses for OPD Consultation."""

from pathlib import Path

from faker import Faker
from jinja2 import Environment, FileSystemLoader

SEED = 42
COUNT = 10
TEMPLATE = "examples.fsh.j2"
OUTPUT = Path("ig/input/fsh/examples.fsh")

# Option sets matching opd-terminology.fsh (code: display)
AGE_UNITS = ["RYRJrC9ebY2", "jKI0L42xLyM", "GIIVmQJm4TL"]
SEX = ["AcdAzPoqdtd", "WpIoypMriD6"]
COVERAGE = ["znSFaG832Lw", "FMUrjjDrO4B"]
LOCATION = ["CyTaWxO8Ic9", "szcYsrBhIpu", "wFwaPU2AkIw"]
REFERRED_FROM = ["GsoObvSPVDI", "zghKLfh82Gc"]
FACILITY_LEVEL = ["cWglQELq7KS", "QxMZqiW5fSr", "uj77N5tNi5l", "BrGurQC6ZCi", "JZ6rVDBxj4g"]
CASE_TYPE = ["YfGEESX0zGV", "vNPIbFnlcHt"]
MAIN_DIAGNOSIS = [
    "W9pD2EW9HYJ", "KGMmdS5Oqgt", "NwUvvEhycN3", "P1cPL54m5XK",
    "yE8CIb9CtkH", "ZWV0ipiMH5k", "aU8L0KI6ROw", "E3vmQcS5PM5",
    "Q9bY3nKWwvx", "FVZz2gSTE9b", "EGWrVB7qA71", "MkarPGn2h0H",
    "BShkJ03tHus", "AOOvLYXJZcx",
]
REFERRED_TO = [
    "Ezvd70uvyqp", "YwEx3MLKuLM", "ej1nRa3zned", "XVGaNE9w8Tx",
    "BTNx1xqjdjw", "thLVceTH3fN",
]
PAYMENT = [
    "ba1MIzCptbx", "GvSpVDo8osh", "DoFN0qb7dma",
    "KqvnLOr4bi7", "hSVmzHTAawr", "XnyjiHuWuKg",
]
VULNERABLE = ["f3OTsJ2SOxQ", "tc2ipE3OvGW", "xNcdlx6FOql"]
SPO2 = ["whA1J3hDAUd", "SCpP8oUNy5N", "fkJKom0OPwz"]


def make_response(fake: Faker, index: int) -> dict:
    age_unit = fake.random_element(AGE_UNITS)
    if age_unit == "RYRJrC9ebY2":
        age = fake.random_int(min=1, max=90)
    elif age_unit == "jKI0L42xLyM":
        age = fake.random_int(min=1, max=11)
    else:
        age = fake.random_int(min=1, max=28)

    referred = fake.boolean(chance_of_getting_true=20)

    return {
        "instance_id": f"OPDVisit{index:03d}",
        "title": f"OPD Visit {index}",
        "register_no": fake.numerify("####"),
        "age_unit": age_unit,
        "age": age,
        "birth_date": fake.date_of_birth(minimum_age=1, maximum_age=90).isoformat(),
        "sex": fake.random_element(SEX),
        "coverage": fake.random_element(COVERAGE),
        "location": fake.random_element(LOCATION),
        "referred_from": fake.random_element(REFERRED_FROM),
        "facility_level": fake.random_element(FACILITY_LEVEL),
        "case_type": fake.random_element(CASE_TYPE),
        "main_diagnosis": fake.random_element(MAIN_DIAGNOSIS),
        "diagnosis_text": fake.sentence(nb_words=3),
        "referred_to": referred,
        "referred_to_detail": fake.random_element(REFERRED_TO) if referred else None,
        "payment": fake.random_element(PAYMENT),
        "vulnerable": fake.random_element(VULNERABLE) if fake.boolean(chance_of_getting_true=15) else None,
        "spo2": fake.random_element(SPO2),
        "received_oxygen": fake.boolean(chance_of_getting_true=10),
        "age_decimal": round(age + fake.random_int(min=0, max=11) / 12, 1),
    }


def main() -> None:
    fake = Faker()
    fake.seed_instance(SEED)

    responses = [make_response(fake, i) for i in range(1, COUNT + 1)]

    env = Environment(loader=FileSystemLoader("templates"), keep_trailing_newline=True)
    template = env.get_template(TEMPLATE)

    OUTPUT.write_text(template.render(responses=responses))
    print(f"Wrote {COUNT} OPD responses to {OUTPUT}")


if __name__ == "__main__":
    main()
