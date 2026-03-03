# Keycloak + Grafana + Microservice on Kubernetes (K8S)

A minimal proof-of-concept deployment of Keycloak, Grafana and a simple microservice on Kubernetes, with Keycloak acting as the OIDC identity provider for Grafana and the microservice. This project uses Terraform for automated infrastructure provisioning and configuration.

**IMPORTANT:** This repository contains hardcoded secrets and credentials for convenience during POC development. These secrets are **NOT suitable for production environments** and should **NEVER** be used in production.

**Before using this in any production setting:**
- Replace all hardcoded credentials with secure secret management (e.g., HashiCorp Vault, AWS Secrets Manager, Kubernetes Secrets with encryption)
- Implement proper RBAC and access controls
- Use TLS/SSL certificates from a trusted Certificate Authority

## Prerequisites

Before you begin, ensure you have the following installed:

- **Terraform** (>= 1.14.0)
- **kubectl** - Kubernetes command-line tool
- **A running Kubernetes cluster** (e.g., minikube, kind, or a cloud provider cluster)

## Architecture

This project deploys:
- **Keycloak**: Open-source Identity and Access Management solution
- **Grafana**: Observability and visualization platform
- **Microservice**: A simple python FastAPI service that verifies the service account token and returns the token body
- **Microservice-test**: A simple python script to run tests against the Microservice API, it gets an access token from keycloak to run the tests with

## Deployment Instructions

This project must be deployed using Terraform in the following order:

### 1. Deploy Infrastructure

First, deploy the base Kubernetes infrastructure (Keycloak Grafana and Microservice deployments):

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### 2. Port Forward Services

After the infrastructure is deployed, you need to forward the services to your local machine to access them, this is only required because it's a POC, in the real world you would have an ingress with proper TLS certificates configured:

```bash
# Forward Keycloak
kubectl port-forward -n apps svc/keycloak 8080:8080

# Forward Grafana
kubectl port-forward -n apps svc/grafana 3000:3000

# Forward Grafana
kubectl port-forward -n apps svc/microservice 9000:9000
```

### 3. Configure Keycloak, Grafana, Microservice Integration

Once the services are accessible via port forwarding, apply the configuration to set up the OIDC integration:

```bash
cd config
terraform init
terraform plan
terraform apply
```

## 4. Accessing the Services

After successful deployment:

### Keycloak Admin Console
- **URL**: http://localhost:8080
- **Username**: admin
- **Password**: admin

### Grafana
- **URL**: http://localhost:3000
- **Login**: Click "Sign in with Keycloak" and use one of the users that was in the outputs of the terraform script

### Microservice
- **URL**: http://localhost:9000
- **Client_ID**: microservice
- **Client_Secret**: kc_ms_1234
- **Client SA Role**: ms_api_access


#### 1. Retrieving an access token:
```
curl -X POST "http://localhost:8080/realms/app-realm/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=microservice" \
  -d "client_secret=kc_ms_1234" \
  -d "grant_type=client_credentials"
```

#### 2. Testing an access token:
```
curl -X GET "http://localhost:9000/access" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>"
```
## Cleanup

To destroy all resources:

```bash
# Remove configuration first
cd config
terraform destroy

# Then remove infrastructure
cd infra
terraform destroy
```