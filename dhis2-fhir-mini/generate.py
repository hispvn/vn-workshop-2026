"""Generate FSH example instances using Faker."""

from pathlib import Path

from faker import Faker
from jinja2 import Environment, FileSystemLoader

SEED = 42
PATIENT_COUNT = 5
RESPONSES_PER_PATIENT = 5
TEMPLATE = "examples.fsh.j2"
OUTPUT = Path("ig/input/fsh/examples.fsh")

CATEGORIES = ["routine", "followup", "emergency"]


def make_patient(fake: Faker, index: int) -> dict:
    gender = fake.random_element(["male", "female"])
    if gender == "male":
        given = fake.first_name_male()
    else:
        given = fake.first_name_female()

    family = fake.last_name()
    return {
        "instance_id": f"Patient{index:03d}",
        "title": f"Patient {given} {family}",
        "family": family,
        "given": given,
        "gender": gender,
        "birth_date": fake.date_of_birth(minimum_age=1, maximum_age=90).isoformat(),
    }


def classify_bp(systolic: int, diastolic: int) -> str:
    if systolic >= 160 or diastolic >= 100:
        return "emergency"
    if systolic >= 140 or diastolic >= 90:
        return "followup"
    return "routine"


def make_response(fake: Faker, patient_index: int, response_index: int) -> dict:
    systolic = fake.random_int(min=100, max=185)
    diastolic = fake.random_int(min=60, max=115)
    date = fake.date_between(start_date="-1y", end_date="today").isoformat()
    category = classify_bp(systolic, diastolic)

    return {
        "instance_id": f"BP{patient_index:03d}x{response_index:02d}",
        "title": f"BP reading {response_index} for Patient{patient_index:03d}",
        "patient_id": f"Patient{patient_index:03d}",
        "date": date,
        "systolic": systolic,
        "diastolic": diastolic,
        "category": category,
    }


def main() -> None:
    fake = Faker()
    fake.seed_instance(SEED)

    patients = [make_patient(fake, i) for i in range(1, PATIENT_COUNT + 1)]
    responses = [
        make_response(fake, pi, ri)
        for pi in range(1, PATIENT_COUNT + 1)
        for ri in range(1, RESPONSES_PER_PATIENT + 1)
    ]

    env = Environment(loader=FileSystemLoader("templates"), keep_trailing_newline=True)
    template = env.get_template(TEMPLATE)

    OUTPUT.write_text(template.render(patients=patients, responses=responses))
    print(f"Wrote {PATIENT_COUNT} patients and {len(responses)} responses to {OUTPUT}")


if __name__ == "__main__":
    main()
