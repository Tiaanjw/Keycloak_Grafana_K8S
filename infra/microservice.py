#!/usr/bin/env python3
import os, sys, time, requests

KEYCLOAK_URL   = os.getenv("KEYCLOAK_URL")
KEYCLOAK_REALM = os.getenv("KEYCLOAK_REALM")
CLIENT_ID      = os.getenv("CLIENT_ID")
CLIENT_SECRET  = os.getenv("CLIENT_SECRET")

def get_access_token(realm, client_id, client_secret):
    url = f"{KEYCLOAK_URL}/realms/{realm}/protocol/openid-connect/token"

    response = requests.post(url, data={
        "grant_type":    "client_credentials",
        "client_id":     client_id,
        "client_secret": client_secret,
    }, timeout=10)
    response.raise_for_status()

    return response.json()["access_token"]


def get_users(realm, token):
    url = f"{KEYCLOAK_URL}/admin/realms/{realm}/users"
    response = requests.get(url, headers={"Authorization": f"Bearer {token}"}, timeout=10)
    response.raise_for_status()
    
    return response.json()


def get_user_roles(realm, token, user_id):
    url = f"{KEYCLOAK_URL}/admin/realms/{realm}/users/{user_id}/role-mappings/realm"
    response = requests.get(url, headers={"Authorization": f"Bearer {token}"}, timeout=10)
    response.raise_for_status()

    return [role["name"] for role in response.json()]

def main():
    print(f"Connecting to {KEYCLOAK_URL} (realm: {KEYCLOAK_REALM})...\n")

    token = get_access_token(KEYCLOAK_REALM, CLIENT_ID, CLIENT_SECRET)
    print("Authenticated successfully\n")

    users = get_users(KEYCLOAK_REALM, token)
    print(f"Found {len(users)} user(s):\n")

    print(f"{'Username':<20} {'Email':<35} {'Roles'}")
    print("-" * 75)

    for user in users:
        roles = get_user_roles(KEYCLOAK_REALM, token, user["id"])
        print(f"{user.get('username', ''):<20} {user.get('email', ''):<35} {', '.join(roles) or '(none)'}")


if __name__ == "__main__":
    RETRY_MAX_ATTEMPTS = 10
    RETRY_WAIT_TIMEOUT = 10

    for attempt in range(1, RETRY_MAX_ATTEMPTS + 1):
        try:
            main()
            break

        except Exception as e:
            if attempt == RETRY_MAX_ATTEMPTS:
                print(f"Failed after {attempt} attempt(s): {e}")
                sys.exit(1)

            time.sleep(RETRY_WAIT_TIMEOUT)