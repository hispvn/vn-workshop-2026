"""Walk the org unit hierarchy tree.

DHIS2 org units form a tree — typically: Country → Region → District → Facility.
Understanding this hierarchy is essential for knowing at which level to aggregate
data and which org units to target in pipelines.

This script fetches the tree starting from the root and prints it with
indentation to show the parent-child relationships.

Usage:
  uv run python examples/dhis2/11_org_unit_tree.py
"""

from climate_tools.config import make_client

client = make_client()

# -- Find the root org unit (level 1) --
roots = list(client.get_organisation_units(level=1, fields="id,name"))
if not roots:
    print("No root org unit found.")
    raise SystemExit(1)

root = roots[0]
print(f"Org unit hierarchy for: {root['name']}\n")

# -- Fetch tree using children relationships --
# We fetch 3 levels deep to show Country → Region → District
response = client.get(
    f"/api/organisationUnits/{root['id']}",
    params={
        "fields": "id,name,level,children[id,name,level,children[id,name,level]]",
    },
)


def print_tree(node: dict, indent: int = 0) -> None:
    """Recursively print org unit tree."""
    prefix = "  " * indent
    level = node.get("level", "?")
    n_children = len(node.get("children", []))
    suffix = f" ({n_children} children)" if n_children > 0 else ""
    print(f"{prefix}L{level}  {node['name']}{suffix}")

    for child in sorted(node.get("children", []), key=lambda c: c["name"]):
        print_tree(child, indent + 1)


print_tree(response)

# -- Summary by level --
print("\n\nSummary by level:")
for level_num in range(1, 5):
    ous = list(client.get_organisation_units(level=level_num, fields="id"))
    if not ous:
        break
    print(f"  Level {level_num}: {len(ous)} org unit(s)")
