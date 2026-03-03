import os
import sys
import requests
from typing import Optional
from datetime import datetime

KEYCLOAK_URL = os.getenv("KEYCLOAK_URL")
KEYCLOAK_REALM = os.getenv("KEYCLOAK_REALM")
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
API_URL = os.getenv("API_URL")


def get_access_token():
    token_url = f"{KEYCLOAK_URL}/realms/{KEYCLOAK_REALM}/protocol/openid-connect/token"
    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "client_credentials"
    }

    try:
        response = requests.post(token_url, data=data)
        response.raise_for_status()

        return response.json()["access_token"]
    
    except Exception as e:
        print(f"Failed getting access token: {e}")


def test_access_endpoint(token: str):
    print("=" * 70)
    print(f"/access Endpoint With Valid Token")
    print("=" * 70)
    
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(f"{API_URL}/access", headers=headers)
        
        
        if response.status_code == 200:
            print("Successfully accessed protected endpoint")
            print(response.json())
            return True
        else:
            print(f"Unexpected status code: {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
        return False

def test_restricted_access_endpoint(token: str):
    print("=" * 70)
    print(f"/restricted-access Endpoint With Valid Token")
    print("=" * 70)
    
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(f"{API_URL}/restricted-access", headers=headers)
        
        if response.status_code == 200:
            print("Successfully accessed protected endpoint")
            print(response.json())
            return True
        else:
            print(f"Unexpected status code: {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
        return False

def main():
    print("Starting tests...\n")

    token = get_access_token()
    test_access_endpoint(token)
    test_restricted_access_endpoint(token)

if __name__ == "__main__":
    main()