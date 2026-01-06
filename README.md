# Azure Infrastructure as Code

Production-ready Infrastructure as Code (IaC) templates for deploying secure, scalable Azure infrastructure using Terraform.

## Overview

This repository provides modular, reusable Terraform configurations for deploying:

- **Networking**: Virtual networks, subnets, NSGs, and private endpoints
- **Compute**: Ubuntu VMs with managed identities
- **Security**: Azure Key Vault with RBAC and HSM support
- **Access**: Azure Bastion for secure SSH/RDP access
- **Monitoring**: Log Analytics, Application Insights, and diagnostics
- **Containers**: Docker Compose configurations for application workloads

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Azure Subscription                          │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Virtual Network                           │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │   │
│  │  │   Compute   │  │    Data     │  │  Private Endpoints  │  │   │
│  │  │   Subnet    │  │   Subnet    │  │      Subnet         │  │   │
│  │  │             │  │             │  │                     │  │   │
│  │  │  ┌───────┐  │  │  ┌───────┐  │  │   ┌─────────────┐   │  │   │
│  │  │  │  VM   │  │  │  │ PgSQL │  │  │   │  Key Vault  │   │  │   │
│  │  │  └───────┘  │  │  └───────┘  │  │   │  (Private)  │   │  │   │
│  │  │             │  │  ┌───────┐  │  │   └─────────────┘   │  │   │
│  │  │             │  │  │ Redis │  │  │                     │  │   │
│  │  │             │  │  └───────┘  │  │                     │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘  │   │
│  │                                                              │   │
│  │  ┌─────────────────────────────────────────────────────────┐ │   │
│  │  │              AzureBastionSubnet                         │ │   │
│  │  │                  ┌─────────┐                            │ │   │
│  │  │                  │ Bastion │                            │ │   │
│  │  │                  └─────────┘                            │ │   │
│  │  └─────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │  Key Vault   │  │     Log      │  │    Application           │  │
│  │  (Premium)   │  │   Analytics  │  │    Insights              │  │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.7.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.50.0
- Azure subscription with appropriate permissions
- SSH key pair for VM access

### Required Azure Permissions

The identity deploying this infrastructure needs:

- `Contributor` on the target subscription or resource groups
- `User Access Administrator` for RBAC role assignments
- `Key Vault Administrator` for Key Vault management

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/ThomasHelenius/azure-iac.git
cd azure-iac
```

### 2. Authenticate to Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

### 4. Deploy Development Environment

```bash
# Review the plan
terraform plan -var-file="environments/dev.tfvars"

# Apply the configuration
terraform apply -var-file="environments/dev.tfvars"
```

## Project Structure

```
azure-iac/
├── terraform/
│   ├── main.tf                 # Root module - orchestrates all modules
│   ├── variables.tf            # Input variable definitions
│   ├── outputs.tf              # Output value definitions
│   ├── versions.tf             # Provider and version constraints
│   ├── locals.tf               # Local value definitions
│   ├── environments/
│   │   ├── dev.tfvars          # Development environment values
│   │   ├── staging.tfvars      # Staging environment values
│   │   └── prod.tfvars         # Production environment values
│   └── modules/
│       ├── networking/         # VNet, subnets, NSGs
│       ├── compute/            # VMs and managed identities
│       ├── keyvault/           # Key Vault with RBAC
│       ├── bastion/            # Azure Bastion
│       └── monitoring/         # Log Analytics, App Insights
├── docker/
│   ├── docker-compose.yml      # Container orchestration
│   └── config/                 # Application configurations
├── .github/
│   └── workflows/              # CI/CD pipelines
└── docs/                       # Additional documentation
```

## Modules

### Networking

Creates the foundational network infrastructure:

- Virtual Network with configurable address space
- Subnets: compute, data, private-endpoint, bastion
- Network Security Groups with least-privilege rules
- Service endpoints for Azure services

### Compute

Provisions compute resources:

- Ubuntu 24.04 LTS virtual machines
- System-assigned managed identities
- Premium SSD storage
- Accelerated networking
- Auto-shutdown scheduling

### Key Vault

Secure secrets management:

- Premium tier with HSM support
- RBAC authorization mode
- Soft delete and purge protection
- Private endpoint support
- Diagnostic logging

### Bastion

Secure remote access:

- Azure Bastion (Basic or Standard SKU)
- No public IPs on VMs
- Native client support (Standard)
- Audit logging

### Monitoring

Observability infrastructure:

- Log Analytics workspace
- Application Insights
- Diagnostic settings for all resources
- Configurable retention periods

## Environment Configuration

| Setting | Dev | Staging | Prod |
|---------|-----|---------|------|
| VNet CIDR | 10.100.0.0/16 | 10.200.0.0/16 | 10.0.0.0/16 |
| VM Count | 1 | 1 | 2 |
| Private Endpoints | No | Yes | Yes |
| Soft Delete Days | 7 | 30 | 90 |
| Purge Protection | No | No | Yes |
| Log Retention | 30 days | 60 days | 90 days |

## Security Features

- **No Public IPs**: VMs accessible only via Azure Bastion
- **Managed Identities**: No stored credentials for Azure service access
- **Network Segmentation**: Strict NSG rules between subnets
- **Private Endpoints**: PaaS services on private IPs (staging/prod)
- **Key Vault**: Premium tier with HSM-backed keys
- **RBAC**: Fine-grained access control
- **Audit Logging**: All access logged to Log Analytics

## Remote State Configuration

For team environments, configure remote state backend:

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

## CI/CD

GitHub Actions workflows are provided for:

- **Terraform Validation**: Syntax and format checks
- **Security Scanning**: tfsec and checkov analysis
- **Plan on PR**: Automatic plan generation for pull requests
- **Apply on Merge**: Controlled deployment to environments

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## Support

- Open an [issue](https://github.com/ThomasHelenius/azure-iac/issues) for bug reports
- Start a [discussion](https://github.com/ThomasHelenius/azure-iac/discussions) for questions
