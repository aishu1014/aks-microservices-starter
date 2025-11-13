AKS Microservices Starter

A simple, assignment-ready implementation for deploying a microservices application on Azure Kubernetes Service (AKS) using Terraform, Helm, and GitHub Actions.
It includes networking, CI security scanning (Checkov), ingress, monitoring (Prometheus + Grafana), and an optional daily Grafana dashboard export.

Repository Structure
.github/workflows   # Terraform CI, App build & deploy, Daily Grafana export
app/                # Demo microservices (api + web) + Dockerfiles
helm/               # Helm charts for app, ingress, monitoring
monitoring/         # Values, dashboards, helpers for Grafana/Prometheus
terraform/          # Full AKS infrastructure provisioning

Requirements

Azure Subscription

GitHub repo with Actions enabled

Azure CLI, Helm, kubectl (Cloud Shell recommended)

(Optional) OIDC-based GitHub → Azure authentication

Terraform remote backend (Azure Storage Account)

Azure Portal Bootstrap (UI)
Create Terraform state backend

Create a Storage Account

Create a Blob Container (example: tfstate)

Optional

Create an ACR (if not using GHCR)

Set up Entra ID groups for RBAC access

2️⃣ GitHub Repository Setup

In Settings → Secrets and variables → Actions, add:

Required for Terraform + Deployment
Secret	Description
AZURE_TENANT_ID	Azure Tenant
AZURE_SUBSCRIPTION_ID	Subscription ID
AZURE_CLIENT_ID	GitHub OIDC App Registration
AZ_RG	Resource group for AKS
AZ_AKS	AKS cluster name
Required after Grafana becomes available
Secret	Description
GRAFANA_API_TOKEN	API token for dashboard export
GRAFANA_HOST	Grafana URL
GRAFANA_DASH_UID	Dashboard UID to export

Ensure GitHub Actions is enabled.

3️⃣ Terraform Setup (Backend + Variables)

Edit terraform/variables.tf and set:

tf_state_rg

tf_state_sa

tf_state_container

cluster name, region, networking values

Push to main → GitHub Actions will run Terraform Plan + Apply
Result: AKS + VNet + Nodepool + supporting resources.

4️⃣ Install Ingress + Monitoring (Cloud Shell)

Open Azure Cloud Shell (Bash):

Connect to AKS
az aks get-credentials -g <rg> -n <aks> --overwrite-existing

Install Ingress-NGINX
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx --create-namespace

Install Monitoring (Prometheus + Grafana)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f helm/monitoring/values-kube-prom-stack.yaml


Grafana + Prometheus become available through your Ingress once hosts are configured.

5️⃣ Deploy the Microservices App (CI/CD)

The Build & Deploy workflow triggers on:

any commit in app/

any commit in helm/app/

Workflow tasks:

Build Docker images

Push images to GHCR (or ACR)

Run helm upgrade --install for the app chart

Once deployed:

Update DNS for your api and web hosts

Update DNS for Grafana host

Verify ingress, services, and pods

6️⃣ Daily Grafana Report (Optional)

After Grafana is running:

Add secrets
GRAFANA_HOST, GRAFANA_API_TOKEN, GRAFANA_DASH_UID

The scheduled workflow exports a daily PNG snapshot of the dashboard

The PNG will appear in Actions → Daily Grafana Report → Artifacts

🔧 Troubleshooting
Ingress shows no EXTERNAL-IP
kubectl get svc -n ingress-nginx
kubectl describe svc ingress-nginx-controller -n ingress-nginx

App unreachable?

Check service names:

kubectl get svc -n app
kubectl get ingress -n app


Verify DNS hostnames match Helm values

Grafana not loading?
kubectl get pods -n monitoring
kubectl get ingress -n monitoring

Terraform backend errors

Ensure Storage Account, container, and key exist

Recheck secrets in GitHub Actions

🧼 Clean-up

To avoid Azure costs:

terraform destroy


Or run the “Terraform Destroy” workflow (if included).

📌 Notes / Recommendations

Replace placeholder hosts in Helm values before exposing to internet

Use ServiceMonitor / PodMonitor to collect app metrics

For production:

use private AKS,

add cert-manager,

switch to AGIC if needed
