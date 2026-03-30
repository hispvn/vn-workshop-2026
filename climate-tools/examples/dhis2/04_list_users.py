"""Get current user and list first 10 users."""

from climate_tools.config import make_client
from climate_tools.schemas import User

client = make_client()

# Current user
me = User(**client.get_current_user(fields="id,username,firstName,surname"))
print(f"Logged in as: {me.firstName} {me.surname} ({me.username})")

# List first 10 users
response = client.get("/api/users.json", params={"fields": "id,displayName", "pageSize": 10})
users = [User(**u) for u in response["users"]]
print(f"\nFirst 10 users (of {response['pager']['total']}):")
for user in users:
    print(f"  {user.id} - {user.displayName}")
