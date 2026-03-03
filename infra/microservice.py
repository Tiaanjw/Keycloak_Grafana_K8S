import os
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from jwt import PyJWKClient
from datetime import datetime

KEYCLOAK_URL = os.getenv("KEYCLOAK_URL")
KEYCLOAK_REALM = os.getenv("KEYCLOAK_REALM")
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SA_ROLE = os.getenv("CLIENT_SA_ROLE")

app = FastAPI(title="Keycloak Protected API", version="1.0.0")

def get_keycloak_public_key():
    jwks_url = f"{KEYCLOAK_URL}/realms/{KEYCLOAK_REALM}/protocol/openid-connect/certs"
    return PyJWKClient(jwks_url)


def verify_token(credentials: HTTPAuthorizationCredentials = Depends(HTTPBearer())):
    token = credentials.credentials
    
    try:
        jwks_client = get_keycloak_public_key()
        signing_key = jwks_client.get_signing_key_from_jwt(token)
    
        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience=[CLIENT_ID],
            options={"verify_exp": True}
        )
        
        return payload
    
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired"
        )
    except jwt.InvalidTokenError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {str(e)}"
        )


def require_role(required_role: str):
    def role_checker(token_payload: dict = Depends(verify_token)):
        client_roles = token_payload.get("resource_access", {}).get(CLIENT_ID, {}).get("roles", [])
        
        if required_role not in client_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Required role '{required_role}' not found"
            )
        
        return token_payload
    
    return role_checker

@app.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}


@app.get("/access")
def get_user_info(token_payload: dict = Depends(verify_token)):
    return {
        "message:": "You have been verified to access this SA restricted endpoint",
        "username": token_payload.get("preferred_username"),
        "payload": token_payload
    }

@app.get("/restricted-access")
def admin_endpoint(token_payload: dict = Depends(require_role(CLIENT_SA_ROLE))):
    return {
        "message": "You have been verified to access this SA and Role restricted endpoint!",
        "username": token_payload.get("preferred_username"),
        "roles:": token_payload.get("resource_access", {}).get(CLIENT_ID, {}).get("roles", []),
        "payload": token_payload
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=9000)