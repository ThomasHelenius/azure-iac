# Contributing to Azure Infrastructure as Code

Thank you for your interest in contributing to this project. This document provides guidelines and best practices for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions. We are committed to providing a welcoming and inclusive environment.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch from `main`
4. Make your changes
5. Submit a pull request

## Development Setup

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.7.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.50.0
- [Docker](https://docs.docker.com/get-docker/) (for container configurations)
- [pre-commit](https://pre-commit.com/) (optional but recommended)

### Local Development

```bash
# Clone your fork
git clone https://github.com/ThomasHelenius/azure-iac.git
cd azure-iac

# Install pre-commit hooks (optional)
pre-commit install

# Initialize Terraform
cd terraform
terraform init -backend=false

# Validate your changes
terraform validate
terraform fmt -check -recursive
```

## Contribution Guidelines

### Branch Naming

Use descriptive branch names:

- `feature/add-redis-module` - New features
- `fix/keyvault-access-policy` - Bug fixes
- `docs/update-readme` - Documentation updates
- `refactor/networking-module` - Code refactoring

### Commit Messages

Follow conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:

```
feat(networking): add private endpoint support for storage accounts

fix(keyvault): correct RBAC role assignment for managed identities

docs(readme): update deployment instructions
```

### Code Standards

#### Terraform

- Use `terraform fmt` to format all `.tf` files
- Include descriptions for all variables and outputs
- Add validation blocks for input variables where appropriate
- Use meaningful resource names following the naming convention
- Include comments for complex logic
- Group related resources in the same file

#### Naming Convention

Follow the pattern: `{resource-type}-{project}-{component}-{environment}`

| Resource | Pattern | Example |
|----------|---------|---------|
| Resource Group | `rg-{project}-{component}-{env}` | `rg-workload-network-dev` |
| Virtual Network | `vnet-{project}-{env}` | `vnet-workload-dev` |
| Key Vault | `kv-{project}-{env}` | `kv-workload-dev` |

#### Tagging

All resources must include these tags:

- `Project`
- `Environment`
- `ManagedBy` (always "Terraform")
- `Owner`
- `CostCenter`
- `DataClassification`

### Pull Request Process

1. **Ensure CI passes**: All checks must pass before review
2. **Update documentation**: Update README if needed
3. **Add tests**: Include validation for new features
4. **Request review**: Tag relevant maintainers
5. **Address feedback**: Respond to review comments

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Refactoring

## Checklist
- [ ] `terraform fmt` applied
- [ ] `terraform validate` passes
- [ ] Documentation updated
- [ ] No sensitive data committed
```

## Module Development

### Creating New Modules

1. Create directory under `terraform/modules/`
2. Include these files:
   - `main.tf` - Primary resources
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values

3. Follow module structure:

```hcl
# variables.tf - Include descriptions and validation
variable "name" {
  type        = string
  description = "Name of the resource"

  validation {
    condition     = length(var.name) > 0
    error_message = "Name cannot be empty."
  }
}

# outputs.tf - Include descriptions
output "id" {
  description = "ID of the created resource"
  value       = azurerm_resource.main.id
}
```

### Module Best Practices

- Keep modules focused on a single responsibility
- Use sensible defaults for optional variables
- Make modules idempotent
- Include diagnostic settings where applicable
- Support both public and private endpoint scenarios
- Add tags parameter with merge capability

## Security Guidelines

### Never Commit

- `.env` files
- Private keys or certificates
- Access tokens or passwords
- `terraform.tfstate` files
- `.terraform/` directory

### Security Best Practices

- Use managed identities over service principals
- Enable encryption at rest
- Use private endpoints where available
- Apply least-privilege access
- Enable diagnostic logging
- Use Key Vault for secrets

## Testing

### Manual Testing

```bash
# Format check
terraform fmt -check -recursive

# Validate
terraform validate

# Plan (requires Azure auth)
terraform plan -var-file="environments/dev.tfvars"
```

### Automated Testing

CI/CD runs:

- Terraform format validation
- Terraform syntax validation
- Security scanning (tfsec, checkov, trivy)
- Plan generation on PRs

## Getting Help

- Open an [issue](https://github.com/ThomasHelenius/azure-iac/issues) for bugs
- Start a [discussion](https://github.com/ThomasHelenius/azure-iac/discussions) for questions
- Check existing issues before creating new ones

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
