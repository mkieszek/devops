# DevOps Repository

This repository contains DevOps tools, documentation, scripts, and examples to support infrastructure management, automation, and development workflows in an enterprise environment.

## 🚀 Technology Stack

### Cloud & Infrastructure
- **Microsoft Azure** - Primary cloud platform
- **Azure DevOps** - CI/CD, repositories, and project management
- **Terraform** - Infrastructure as Code (IaC)
- **Windows Server** - On-premises and hybrid infrastructure

### Development Platforms
- **.NET** - Enterprise applications and APIs
- **Angular** - Frontend applications and SPAs
- **Python** - Automation scripts and DevOps tooling
- **PowerShell** - Windows automation and Azure management

### Monitoring & Quality Assurance
- **Grafana** - Dashboards and observability
- **SonarQube** (Community & Enterprise) - Code quality and security
- **Elasticsearch** - Log aggregation and analytics

## 📁 Repository Structure

```
devops/
├── 📂 docs/                     # Documentation and architecture
├── 📂 infrastructure/           # Terraform modules and configurations
├── 📂 scripts/                  # PowerShell and Python automation
├── 📂 applications/             # .NET and Angular applications
├── 📂 monitoring/               # Grafana dashboards and alerting
├── 📂 pipelines/                # Azure DevOps YAML pipelines
├── 📂 configs/                  # Configuration files and templates
├── 📂 examples/                 # Code examples and samples
└── 📂 .github/                  # GitHub configuration and workflows
```

## 🛠️ Getting Started

### Prerequisites
- Azure CLI installed and configured
- Terraform >= 1.0
- PowerShell 7+
- .NET 6+ SDK
- Node.js and npm (for Angular projects)
- Python 3.9+
- Git

### Quick Setup
```bash
# Clone the repository
git clone https://github.com/mkieszek/devops.git
cd devops

# Set up your environment
# Follow specific setup instructions in each project folder
```

## 🔧 Usage Examples

### Infrastructure Deployment
```bash
# Deploy infrastructure with Terraform
cd infrastructure/
terraform init
terraform plan
terraform apply
```

### Script Execution
```powershell
# Run PowerShell automation scripts
.\scripts\Deploy-AzureResources.ps1 -Environment "dev"
```

```python
# Run Python automation tools
python scripts/azure_management.py --action deploy --env development
```

## 📋 Best Practices

- **Security First**: Never commit secrets or credentials
- **Infrastructure as Code**: All infrastructure should be defined in Terraform
- **Documentation**: Maintain clear documentation for all components
- **Testing**: Include tests for scripts and applications
- **Monitoring**: Implement comprehensive logging and monitoring

## 🤝 Contributing

1. Follow the coding standards defined in `.github/copilot-instructions.md`
2. Create feature branches for new functionality
3. Include tests and documentation with your changes
4. Ensure all CI/CD checks pass before merging

## 📖 Documentation

- [GitHub Copilot Instructions](.github/copilot-instructions.md) - Detailed guidelines for AI-assisted development
- [Architecture Documentation](docs/) - System architecture and design documents
- [Runbooks](docs/runbooks/) - Operational procedures and troubleshooting guides

## 🔐 Security

- All secrets are managed through Azure Key Vault
- Code quality is enforced through SonarQube scanning
- Regular security audits and dependency updates
- Follow principle of least privilege for all access controls

## 📞 Support

For questions and support:
- Create an issue in this repository
- Check the documentation in the `docs/` folder
- Review existing examples in the `examples/` folder

---

**Note**: This repository follows enterprise DevOps best practices and is optimized for GitHub Copilot assistance. See [Copilot Instructions](.github/copilot-instructions.md) for detailed AI guidance.
