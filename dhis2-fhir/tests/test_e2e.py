"""End-to-end Playwright tests for the DHIS2-FHIR resource renderer.

Tests cover the main pages, CHR workflow (dashboard → patient list → EIR),
search, and the FHIR REST API.
"""

from __future__ import annotations

import re

from playwright.sync_api import Page, expect

# ---------------------------------------------------------------------------
# Home page
# ---------------------------------------------------------------------------


def test_home_page_loads(page: Page, base_url: str):
    page.goto(base_url)
    expect(page).to_have_title("DHIS2-FHIR Resource Renderer")
    expect(page.get_by_role("heading", name="DHIS2-FHIR Resource Renderer")).to_be_visible()


def test_home_shows_patients_table(page: Page, base_url: str):
    page.goto(base_url)
    expect(page.get_by_role("heading", name="Patients")).to_be_visible()
    rows = page.locator("table").first.locator("tbody tr")
    expect(rows.first).to_be_visible()


def test_home_shows_questionnaires(page: Page, base_url: str):
    page.goto(base_url)
    expect(page.get_by_role("heading", name=re.compile(r"Questionnaires"))).to_be_visible()


def test_home_shows_ips_bundles(page: Page, base_url: str):
    page.goto(base_url)
    expect(page.get_by_role("heading", name="IPS Bundles")).to_be_visible()


# ---------------------------------------------------------------------------
# Navigation sidebar
# ---------------------------------------------------------------------------


def test_sidebar_links(page: Page, base_url: str):
    page.goto(base_url)
    for name in ("Home", "Patients", "CHR", "Forms", "IPS Bundles"):
        expect(page.get_by_role("link", name=name, exact=True)).to_be_visible()


# ---------------------------------------------------------------------------
# Patient list page
# ---------------------------------------------------------------------------


def test_patients_page(page: Page, base_url: str):
    page.goto(f"{base_url}/patients")
    expect(page).to_have_title(re.compile(r"Patients"))
    rows = page.locator("table tbody tr")
    expect(rows.first).to_be_visible()


# ---------------------------------------------------------------------------
# CHR Dashboard
# ---------------------------------------------------------------------------


def test_chr_dashboard_loads(page: Page, base_url: str):
    page.goto(f"{base_url}/chr")
    expect(page).to_have_title("CHR Dashboard — DHIS2-FHIR")
    expect(page.get_by_role("heading", name="Community Health Record")).to_be_visible()


def test_chr_dashboard_stats(page: Page, base_url: str):
    page.goto(f"{base_url}/chr")
    expect(page.get_by_text("CHR Patients")).to_be_visible()
    expect(page.get_by_text("Immunization Records")).to_be_visible()


def test_chr_patients_card_is_clickable(page: Page, base_url: str):
    page.goto(f"{base_url}/chr")
    link = page.get_by_role("link", name=re.compile(r"CHR Patients"))
    expect(link).to_have_attribute("href", "/chr/patients")


def test_chr_dashboard_quick_actions(page: Page, base_url: str):
    page.goto(f"{base_url}/chr")
    expect(page.get_by_role("link", name=re.compile("Search CHR"))).to_be_visible()
    expect(page.get_by_role("link", name=re.compile("Register Patient"))).to_be_visible()


def test_chr_dashboard_org_hierarchy(page: Page, base_url: str):
    page.goto(f"{base_url}/chr")
    expect(page.get_by_text("Vientiane Capital")).to_be_visible()
    expect(page.get_by_text("Savannakhet")).to_be_visible()
    expect(page.get_by_text("Luang Prabang (OU_LPB)")).to_be_visible()


def test_chr_dashboard_fhir_api_table(page: Page, base_url: str):
    page.goto(f"{base_url}/chr")
    expect(page.get_by_role("heading", name="FHIR REST API")).to_be_visible()
    expect(page.locator("code", has_text="/fhir/Patient").first).to_be_visible()


# ---------------------------------------------------------------------------
# CHR Patient List
# ---------------------------------------------------------------------------


def test_chr_patients_list(page: Page, base_url: str):
    page.goto(f"{base_url}/chr/patients")
    expect(page.get_by_role("heading", name="CHR Patients")).to_be_visible()
    expect(page.get_by_text("All registered CHR patients")).to_be_visible()
    expect(page.get_by_role("heading", name=re.compile(r"Results \(\d+\)"))).to_be_visible()


def test_chr_patients_shows_patient_cards(page: Page, base_url: str):
    page.goto(f"{base_url}/chr/patients")
    # Should have at least 2 patients (FSH examples + seed data)
    eir_links = page.get_by_role("link", name="EIR")
    expect(eir_links.first).to_be_visible()
    assert eir_links.count() >= 2


def test_chr_patients_click_through_from_dashboard(page: Page, base_url: str):
    page.goto(f"{base_url}/chr")
    page.get_by_role("link", name=re.compile(r"CHR Patients")).click()
    expect(page).to_have_url(re.compile(r"/chr/patients"))
    expect(page.get_by_role("heading", name="CHR Patients")).to_be_visible()


# ---------------------------------------------------------------------------
# CHR Search
# ---------------------------------------------------------------------------


def test_chr_search_page_loads(page: Page, base_url: str):
    page.goto(f"{base_url}/chr/search")
    expect(page.get_by_role("heading", name="CHR Search")).to_be_visible()
    expect(page.get_by_role("button", name="Search by Identifier")).to_be_visible()
    expect(page.get_by_role("button", name="Search by Demographics")).to_be_visible()


def test_chr_search_by_identifier(page: Page, base_url: str):
    page.goto(f"{base_url}/chr/search")
    page.locator("input[name='id_value']").fill("17011994")
    page.get_by_role("button", name="Search", exact=True).click()
    expect(page.get_by_role("heading", name=re.compile(r"Results"))).to_be_visible()
    expect(page.get_by_text("Phouthasinh")).to_be_visible()


# ---------------------------------------------------------------------------
# CHR Patient EIR
# ---------------------------------------------------------------------------


def test_chr_patient_eir(page: Page, base_url: str):
    page.goto(f"{base_url}/chr/patient/CHRPatientPhouthasinh/eir")
    expect(page).to_have_title(re.compile(r"EIR.*Phouthasinh"))
    expect(page.get_by_role("heading", name="Phouthasinh Douangmala")).to_be_visible()


def test_chr_eir_demographics(page: Page, base_url: str):
    page.goto(f"{base_url}/chr/patient/CHRPatientPhouthasinh/eir")
    expect(page.locator("text=Female").first).to_be_visible()
    expect(page.get_by_text("1994-01-17")).to_be_visible()
    expect(page.get_by_text("Chanthabuly")).to_be_visible()
    expect(page.get_by_text("Anou", exact=True)).to_be_visible()


def test_chr_eir_immunization_table(page: Page, base_url: str):
    page.goto(f"{base_url}/chr/patient/CHRPatientPhouthasinh/eir")
    expect(page.get_by_role("heading", name=re.compile(r"Immunization History"))).to_be_visible()
    table = page.locator("table")
    expect(table.get_by_text("OPV, trivalent")).to_be_visible()


def test_chr_eir_fhir_equivalent(page: Page, base_url: str):
    page.goto(f"{base_url}/chr/patient/CHRPatientPhouthasinh/eir")
    expect(page.get_by_text("FHIR Equivalent")).to_be_visible()


# ---------------------------------------------------------------------------
# CHR Register
# ---------------------------------------------------------------------------


def test_chr_register_form(page: Page, base_url: str):
    page.goto(f"{base_url}/chr/register")
    expect(page).to_have_title(re.compile(r"Register"))
    expect(page.get_by_text("First Name")).to_be_visible()


# ---------------------------------------------------------------------------
# IPS page
# ---------------------------------------------------------------------------


def test_ips_page(page: Page, base_url: str):
    page.goto(f"{base_url}/ips")
    expect(page).to_have_title(re.compile(r"IPS"))


# ---------------------------------------------------------------------------
# FHIR REST API
# ---------------------------------------------------------------------------


def test_fhir_patient_search(page: Page, base_url: str):
    resp = page.request.get(f"{base_url}/fhir/Patient")
    assert resp.status == 200
    body = resp.json()
    assert body["resourceType"] == "Bundle"
    assert body["type"] == "searchset"
    assert len(body["entry"]) > 0


def test_fhir_patient_read(page: Page, base_url: str):
    resp = page.request.get(f"{base_url}/fhir/Patient/CHRPatientPhouthasinh")
    assert resp.status == 200
    body = resp.json()
    assert body["resourceType"] == "Patient"
    assert any("Phouthasinh" in g for n in body["name"] for g in n.get("given", []))


def test_fhir_patient_search_by_identifier(page: Page, base_url: str):
    resp = page.request.get(
        f"{base_url}/fhir/Patient",
        params={"identifier": "http://moh.gov.la/fhir/id/client-health-id|17011994-2-4821"},
    )
    assert resp.status == 200
    body = resp.json()
    assert body["total"] >= 1


def test_fhir_immunization_search(page: Page, base_url: str):
    resp = page.request.get(
        f"{base_url}/fhir/Immunization",
        params={"patient": "Patient/CHRPatientPhouthasinh"},
    )
    assert resp.status == 200
    body = resp.json()
    assert body["resourceType"] == "Bundle"
    assert len(body["entry"]) >= 1


def test_fhir_metadata(page: Page, base_url: str):
    resp = page.request.get(f"{base_url}/fhir/metadata")
    assert resp.status == 200
    body = resp.json()
    assert body["resourceType"] == "CapabilityStatement"
