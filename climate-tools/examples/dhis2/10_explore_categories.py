"""Explore DHIS2 categories and disaggregation.

In DHIS2, data can be disaggregated by categories — for example, a data
element "Population" might be broken down by sex (Male/Female) and age group.

The hierarchy is:
  Category Option  →  a single choice (e.g. "Male", "Female", "0-4 years")
  Category         →  groups options (e.g. "Sex" = {Male, Female})
  Category Combo   →  combines categories (e.g. "Sex" × "Age group")

When a data element has a category combo, each data value must specify which
category option combo it belongs to (e.g. "Male, 0-4 years").

This script lists the category combos in the system and shows how they
decompose into categories and options — useful for understanding what
disaggregations exist before building import pipelines.

Usage:
  uv run python examples/dhis2/10_explore_categories.py
"""

from climate_tools.config import make_client

client = make_client()

# -- List category combos with their categories and options --
response = client.get(
    "/api/categoryCombos.json",
    params={
        "fields": "id,displayName,categories[id,displayName,categoryOptions[id,displayName]]",
        "pageSize": 10,
        "order": "displayName:asc",
    },
)

combos = response["categoryCombos"]
total = response["pager"]["total"]

print(f"Category combos (showing first {len(combos)} of {total}):\n")

for combo in combos:
    categories = combo.get("categories", [])
    n_cats = len(categories)

    # Count total combinations
    n_combos = 1
    for cat in categories:
        n_combos *= len(cat.get("categoryOptions", []))

    print(f"  {combo['displayName']}")
    print(f"    ID: {combo['id']}")
    print(f"    Categories: {n_cats}, Combinations: {n_combos}")

    for cat in categories:
        options = cat.get("categoryOptions", [])
        option_names = [o["displayName"] for o in options]
        if len(option_names) <= 6:
            print(f"      {cat['displayName']}: {', '.join(option_names)}")
        else:
            shown = ", ".join(option_names[:5])
            print(f"      {cat['displayName']}: {shown}, ... (+{len(option_names) - 5} more)")
    print()
