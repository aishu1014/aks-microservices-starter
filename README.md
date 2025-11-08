# AKS Microservices Starter (UI-assisted)

This repo is a minimal, assignment-ready starter:
- **Terraform** for AKS + networking
- **Checkov** scanning in CI
- **Helm**-deployed demo app (api + web)
- **Prometheus + Grafana** via Helm
- **Daily dashboard export** via GitHub Actions

## 1) Azure Portal (UI) bootstrap
1. Create a **Storage Account** and **Blob Container** (e.g., `tfstate`) for Terraform state.
2. (Optional) Create an **ACR** if you don't want GHCR (set `acr_name` in Terraform).
3. (Optional) Create Entra ID groups and plan RBAC.

## 2) GitHub UI setup
- Create repo and **enable Actions**.
- In **Settings → Secrets and variables → Actions**, add:
  - `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_CLIENT_ID` (OIDC-enabled app)
  - `AZ_RG` (resource group name for AKS), `AZ_AKS` (cluster name)
  - `GRAFANA_API_TOKEN`, `GRAFANA_HOST`, `GRAFANA_DASH_UID` (after Grafana is up)

## 3) Terraform (run from Actions UI)
- Update `terraform/variables.tf` for backend vars (`tf_state_*`).
- Push to `main` to trigger **plan/apply** from Actions.
- Outputs: AKS cluster provisioned.

## 4) Install ingress & monitoring (Cloud Shell UI)
```bash
# In Azure Portal → Cloud Shell
az aks get-credentials -g <rg> -n <aks> --overwrite-existing

# Ingress-NGINX
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace

# Monitoring stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack   -n monitoring --create-namespace   -f helm/monitoring/values-kube-prom-stack.yaml
```

## 5) Deploy the app (from Actions UI)
- Push any change under `app/` or `helm/app/` → **Build & Deploy** workflow builds images and does `helm upgrade --install`.
- Update DNS for your Ingress hosts (app + Grafana).

## 6) Daily report
- Configure a Grafana dashboard with UID set in `GRAFANA_DASH_UID`.
- The scheduled workflow fetches the last 24h as a PNG artifact.

## Notes
- Replace placeholder hosts in Helm values.
- Consider private AKS + AGIC if needed.
- Add **ServiceMonitor**/`PodMonitor` for the API as you expand metrics.
