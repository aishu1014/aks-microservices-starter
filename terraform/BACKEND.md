# Terraform backend (remote state)
This project expects an Azure Storage Account backend. Create (via Portal):
- Resource Group (for state), Storage Account, Container (e.g., `tfstate`)

Then pass these to Terraform (via GitHub Actions variables/secrets):
- `tf_state_rg`
- `tf_state_sa`
- `tf_state_container`
