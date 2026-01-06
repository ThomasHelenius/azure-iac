# Deployment Guide

This guide covers deploying the Azure infrastructure using Terraform.

## Prerequisites

### Required Tools

| Tool | Minimum Version | Installation |
|------|-----------------|--------------|
| Terraform | 1.7.0 | [Download](https://www.terraform.io/downloads) |
| Azure CLI | 2.50.0 | [Install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) |

### Azure Permissions

The deploying identity requires:

- `Contributor` role on target subscription
- `User Access Administrator` for RBAC assignments
- `Key Vault Administrator` for Key Vault management

### Generate SSH Key

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -f ~/.ssh/azure-vm -C "azure-vm-key"

# Display public key (needed for deployment)
cat ~/.ssh/azure-vm.pub
```

## Local Deployment

### 1. Clone Repository

```bash
git clone https://github.com/your-org/azure-iac.git
cd azure-iac/terraform
```

### 2. Authenticate to Azure

```bash
# Interactive login
az login

# Set subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify
az account show
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Create Variable File

Create `terraform.tfvars` with required values:

```hcl
vm_admin_username = "azureadmin"
vm_ssh_public_key = "ssh-ed25519 AAAA... your-key"
```

### 5. Deploy Environment

```bash
# Development
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

# Staging
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"

# Production
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

## CI/CD Deployment

### GitHub Actions Setup

#### 1. Configure OIDC Authentication

Create Azure AD application for GitHub Actions:

```bash
# Create app registration
az ad app create --display-name "github-actions-terraform"

# Note the appId from output
APP_ID="<app-id-from-output>"

# Create service principal
az ad sp create --id $APP_ID

# Get object ID
OBJECT_ID=$(az ad sp show --id $APP_ID --query id -o tsv)

# Assign Contributor role
az role assignment create \
  --assignee-object-id $OBJECT_ID \
  --role Contributor \
  --scope /subscriptions/YOUR_SUBSCRIPTION_ID

# Assign User Access Administrator
az role assignment create \
  --assignee-object-id $OBJECT_ID \
  --role "User Access Administrator" \
  --scope /subscriptions/YOUR_SUBSCRIPTION_ID
```

#### 2. Configure Federated Credentials

```bash
# Create federated credential for main branch
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:YOUR_ORG/azure-iac:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Create federated credential for pull requests
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "github-pr",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:YOUR_ORG/azure-iac:pull_request",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

#### 3. Configure GitHub Secrets

Add these secrets in GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | App registration client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID |
| `VM_ADMIN_USERNAME` | VM administrator username |
| `VM_SSH_PUBLIC_KEY` | SSH public key for VMs |

#### 4. Configure Environments

Create GitHub environments with protection rules:

**dev**:

- No required reviewers
- Auto-deploy on merge

**staging**:

- Required reviewers: 1
- Manual trigger only

**prod**:

- Required reviewers: 2
- Manual trigger only
- Environment secrets for production-specific values

### Deployment Workflow

#### Automatic (Dev)

1. Push changes to `main` branch
2. CI validates and plans
3. Dev auto-deploys

#### Manual (Staging/Prod)

1. Go to Actions tab
2. Select "Terraform Apply" workflow
3. Click "Run workflow"
4. Select environment and action
5. Approve deployment (if required)

## Remote State Configuration

### 1. Create Storage Account

```bash
# Create resource group
az group create \
  --name rg-terraform-state \
  --location eastus

# Create storage account
az storage account create \
  --name stterraformstate$(date +%s) \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create \
  --name tfstate \
  --account-name stterraformstate
```

### 2. Enable Backend

Update `terraform/versions.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "azure-iac.tfstate"
  }
}
```

### 3. Migrate State

```bash
terraform init -migrate-state
```

## Post-Deployment

### Connect to VMs

Use Azure Bastion:

```bash
# Via Azure CLI
az network bastion ssh \
  --name bas-workload-dev \
  --resource-group rg-workload-network-dev \
  --target-resource-id /subscriptions/.../virtualMachines/vm-workload-dev-01 \
  --auth-type ssh-key \
  --username azureadmin \
  --ssh-key ~/.ssh/azure-vm
```

Or via Azure Portal:

1. Navigate to VM in portal
2. Click "Connect" → "Bastion"
3. Enter credentials

### Verify Deployment

```bash
# Check resource groups
az group list --query "[?starts_with(name, 'rg-workload')]" -o table

# Check VMs
az vm list -g rg-workload-compute-dev -o table

# Check Key Vault
az keyvault show -n kv-workload-dev -g rg-workload-security-dev
```

## Destroying Infrastructure

### Single Environment

```bash
terraform destroy -var-file="environments/dev.tfvars"
```

### Via CI/CD

1. Go to Actions → Terraform Apply
2. Select environment
3. Choose "destroy" action
4. Confirm destruction

### Important Notes

- Production has purge protection enabled
- Key Vault soft delete retains secrets
- Verify no critical data before destroying
