"""Generate FSH example instances using Faker."""

from pathlib import Path

from faker import Faker
from jinja2 import Environment, FileSystemLoader

SEED = 42
COUNT = 10
TEMPLATE = "examples.fsh.j2"
OUTPUT = Path("ig/input/fsh/examples.fsh")


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


def main() -> None:
    fake = Faker()
    fake.seed_instance(SEED)

    patients = [make_patient(fake, i) for i in range(1, COUNT + 1)]

    env = Environment(loader=FileSystemLoader("templates"), keep_trailing_newline=True)
    template = env.get_template(TEMPLATE)

    OUTPUT.write_text(template.render(patients=patients))
    print(f"Wrote {COUNT} patients to {OUTPUT}")


if __name__ == "__main__":
    main()
