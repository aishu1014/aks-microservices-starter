AKS Microservices Starter 
 
This repository contains a fully working AKS microservices deployment including:
•	Terraform for AKS + VNet + Node Pools
•	Checkov security scanning in CI
•	Helm deployment for api + web
•	Ingress-NGINX setup
•	Prometheus + Grafana monitoring
•	Daily Grafana dashboard export using GitHub Actions
•	GHCR container registry build + push pipeline
________________________________________
Repository Structure

.github/workflows/     # Terraform CI, App Build+Deploy CI, Daily Grafana Report
terraform/             # AKS Infrastructure-as-Code
helm/app/              # Helm chart for api + web microservices
helm/monitoring/       # Monitoring stack values (Prom+Grafana)
app/api/               # Demo API service (Python FastAPI)
app/web/               # Demo web frontend (Nginx static site)
________________________________________
1) Azure Portal Bootstrap
Before running Terraform:
1.	Create a Resource Group
2.	Create a Storage Account
3.	Create a Blob Container
o	Example container name: tfstate
4.	(Optional) Create ACR (if not using GHCR)
5.	(Optional) Configure RBAC / Entra ID Groups
You used the Storage Account to store Terraform state remotely.
________________________________________
2) GitHub Setup
Inside Settings → Secrets & Variables → Actions, add:
Terraform + AKS Access
•	AZURE_TENANT_ID
•	AZURE_SUBSCRIPTION_ID
•	AZURE_CLIENT_ID (OIDC-enabled)
•	AZ_RG → Name of your resource group (example: aks-demo-rg)
•	AZ_AKS → Cluster name (example: aksdemo-aks)
Monitoring / Reporting
Add these once Grafana is deployed:
•	GRAFANA_HOST
•	GRAFANA_API_TOKEN
•	GRAFANA_DASH_UID
These allow GitHub Actions to export daily Grafana PNG reports.
________________________________________
3) Terraform Deployment (via GitHub Actions)
1.	Edit backend values inside:
terraform/variables.tf
2.	Push commit → GitHub Actions automatically runs:
•	terraform init
•	terraform validate
•	terraform plan
•	terraform apply
•	Checkov security scan
Output
✔ AKS Cluster
✔ VNet + subnets
✔ Node pool
✔ RBAC
✔ (Optional) ACR
________________________________________
4) Install Ingress + Monitoring (Azure Cloud Shell)
Open Azure Cloud Shell and run:
az aks get-credentials -g <rg> -n <aks> --overwrite-existing
Install Ingress-NGINX
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx --create-namespace
Install Prometheus + Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f helm/monitoring/values-kube-prom-stack.yaml
Grafana becomes available via Ingress (once DNS is configured).
________________________________________
5) Deploying the Microservices App (CI/CD)
Whenever you push changes to:
•	app/api/
•	app/web/
•	helm/app/
GitHub Actions automatically:
1.	Builds Docker images
2.	Pushes them to GHCR:
 o	ghcr.io/aishu1014/demo-api:latest
 o	ghcr.io/aishu1014/demo-web:latest
3.	Runs:
4.	helm upgrade --install app ./helm/app
5.	Applies ingress rules:
 o	/ → web
 o	/api → api
Result:
 ✔ Web application served via Ingress
 ✔ API reachable at /api/health
________________________________________
6) Daily Grafana Dashboard Export (CI/CD)
A scheduled GitHub Action runs daily:
•	Fetches last 24-hour PNG screenshot from Grafana dashboard
•	Saves it as a workflow artifact
•	Uses:
o	GRAFANA_API_TOKEN
o	GRAFANA_HOST
o	GRAFANA_DASH_UID
This fulfills the report generation requirement.
________________________________________
7) Screenshots 
 Updated the required screenshots in the Git repo.
Terraform & Infrastructure
 ✔ GitHub Actions Terraform plan/apply
 ✔ Terraform Checkov scan results
 ✔ Azure Portal screenshot of AKS cluster
 ✔ Storage account with tfstate
Kubernetes Deployment
 ✔ kubectl get pods -n app
 ✔ kubectl get svc -n app
 ✔ kubectl get ingress -n app
 ✔ Ingress external IP shown
Monitoring
 ✔ Grafana dashboard screenshot
 ✔ Prometheus targets
 ✔ Ingress for Grafana
CI/CD
 ✔ GitHub Actions build + deploy logs
 ✔ Daily report job success
________________________________________
8) Notes & Helpful Tips
•	Replace placeholder ingress hosts when going live
•	Add ServiceMonitor and PodMonitor for custom API metrics
•	For production:
 o	Use private AKS
 o	Use AGIC instead of NGINX
 o	Enable TLS with cert-manager
________________________________________
9) Cleanup (optional)
To avoid Azure costs:
terraform destroy
Or delete the resource group:
az group delete -n <rg>
________________________________________
Your project is fully ready to submit.

