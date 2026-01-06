# Architecture Overview

This document describes the architecture and design decisions for the Azure infrastructure.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Azure Subscription                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                        Resource Groups                                  │ │
│  ├────────────────┬────────────────┬────────────────┬────────────────────┤ │
│  │  rg-network    │  rg-compute    │  rg-security   │  rg-monitor        │ │
│  └────────────────┴────────────────┴────────────────┴────────────────────┘ │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                         Virtual Network                                 │ │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐  │ │
│  │  │   Compute    │ │    Data      │ │   Private    │ │   Bastion    │  │ │
│  │  │   Subnet     │ │   Subnet     │ │  Endpoints   │ │   Subnet     │  │ │
│  │  │              │ │              │ │              │ │              │  │ │
│  │  │  ┌────────┐  │ │  ┌────────┐  │ │  ┌────────┐  │ │  ┌────────┐  │  │ │
│  │  │  │  VMs   │  │ │  │ PgSQL  │  │ │  │   KV   │  │ │  │Bastion │  │  │ │
│  │  │  └────────┘  │ │  │ Redis  │  │ │  │  PE    │  │ │  │  Host  │  │  │ │
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐  │
│  │   Key Vault     │  │  Log Analytics  │  │   Application Insights      │  │
│  │   (Premium)     │  │   Workspace     │  │                             │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Design Principles

### 1. Security First

- **No public IPs on VMs**: All VM access via Azure Bastion
- **Managed identities**: No stored credentials for Azure service access
- **Network segmentation**: Strict NSG rules between subnets
- **Private endpoints**: PaaS services on private IPs (staging/prod)
- **Key Vault**: Premium tier with HSM-backed keys
- **RBAC**: Azure AD role-based access control

### 2. Modularity

Each infrastructure component is a separate Terraform module:

| Module | Purpose |
|--------|---------|
| `networking` | VNet, subnets, NSGs |
| `compute` | VMs, NICs, managed identities |
| `keyvault` | Key Vault, RBAC, private endpoints |
| `bastion` | Azure Bastion, public IP |
| `monitoring` | Log Analytics, App Insights |

### 3. Environment Parity

Consistent configuration across environments with appropriate security controls:

| Aspect | Dev | Staging | Prod |
|--------|-----|---------|------|
| Private Endpoints | No | Yes | Yes |
| Purge Protection | No | No | Yes |
| VM Count | 1 | 1 | 2 |
| Log Retention | 30 days | 60 days | 90 days |

## Network Architecture

### Subnet Design

| Subnet | CIDR (Dev) | Purpose |
|--------|------------|---------|
| Compute | 10.100.1.0/24 | Virtual machines |
| Data | 10.100.2.0/24 | Database services |
| Private Endpoint | 10.100.3.0/24 | PaaS private endpoints |
| Bastion | 10.100.255.0/26 | Azure Bastion |

### Network Security Groups

#### Compute Subnet Rules

| Direction | Port | Source | Destination | Action |
|-----------|------|--------|-------------|--------|
| Inbound | 22 | Bastion Subnet | Compute | Allow |
| Inbound | 443 | VirtualNetwork | Compute | Allow |
| Inbound | 80 | VirtualNetwork | Compute | Allow |
| Inbound | * | Internet | * | Deny |
| Outbound | 5432, 6379 | Compute | Data | Allow |
| Outbound | 443 | Compute | Internet | Allow |

#### Data Subnet Rules

| Direction | Port | Source | Destination | Action |
|-----------|------|--------|-------------|--------|
| Inbound | 5432 | Compute Subnet | Data | Allow |
| Inbound | 6379 | Compute Subnet | Data | Allow |
| Inbound | * | * | * | Deny |

## Security Architecture

### Identity and Access

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure AD                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Users     │  │   Groups    │  │  Service Principals │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
└─────────┼────────────────┼─────────────────────┼────────────┘
          │                │                     │
          ▼                ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    RBAC Assignments                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Key Vault Administrator → Deployer Identity         │   │
│  │  Key Vault Secrets User  → VM Managed Identities     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Secret Management

- All secrets stored in Azure Key Vault (Premium)
- VMs access secrets via managed identity
- No secrets in code or configuration files
- Soft delete protection (7-90 days)
- Purge protection in production

## Monitoring Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Log Analytics Workspace                   │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  VM Logs     │  │ NSG Flow Logs│  │ Key Vault Audit  │   │
│  └──────────────┘  └──────────────┘  └──────────────────┘   │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ Bastion Logs │  │ VNet Metrics │  │ Activity Logs    │   │
│  └──────────────┘  └──────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Application Insights                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Application Performance │  Custom Metrics │ Alerts  │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Deployment Architecture

### CI/CD Pipeline

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Commit    │────▶│  Validate   │────▶│   Scan      │
│             │     │  Format     │     │  Security   │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Deploy    │◀────│   Approve   │◀────│    Plan     │
│             │     │  (Manual)   │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Environment Promotion

1. **Dev**: Auto-deploy on merge to main
2. **Staging**: Manual trigger with approval
3. **Prod**: Manual trigger with approval + additional review

## Resource Naming Convention

Pattern: `{resource-type}-{project}-{component}-{environment}`

| Resource | Pattern | Example |
|----------|---------|---------|
| Resource Group | `rg-{project}-{component}-{env}` | `rg-workload-network-dev` |
| Virtual Network | `vnet-{project}-{env}` | `vnet-workload-dev` |
| Subnet | `snet-{component}-{project}-{env}` | `snet-compute-workload-dev` |
| NSG | `nsg-{component}-{project}-{env}` | `nsg-compute-workload-dev` |
| Key Vault | `kv-{project}-{env}` | `kv-workload-dev` |
| VM | `vm-{project}-{env}-{nn}` | `vm-workload-dev-01` |
| Bastion | `bas-{project}-{env}` | `bas-workload-dev` |

## Disaster Recovery

### Backup Strategy

| Component | Backup Method | Retention |
|-----------|---------------|-----------|
| Key Vault | Soft delete | 7-90 days |
| VMs | Azure Backup (optional) | 7-30 days |
| State | Remote backend | Versioned |

### Recovery Procedures

1. Key Vault: Recover from soft delete
2. VMs: Restore from Azure Backup or redeploy
3. State: Recover from versioned backend

## Future Considerations

- Azure Kubernetes Service (AKS) integration
- Azure Front Door for global load balancing
- Azure Policy for governance
- Azure Defender for enhanced security
- Multi-region deployment for DR
