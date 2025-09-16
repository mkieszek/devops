# GitHub Copilot Instructions for DevOps Repository

## Repository Purpose
This repository contains DevOps tools, documentation, scripts, and examples to support infrastructure management, automation, and development workflows. The primary focus is on enterprise-grade solutions using Microsoft Azure ecosystem and modern DevOps practices.

## Technology Stack & Context

### Cloud Platform
- **Microsoft Azure**: Primary cloud platform for all resources
- **Azure DevOps**: CI/CD pipelines, repositories, work items, and project management
- **Azure Resource Manager (ARM)**: Infrastructure deployment and management

### Infrastructure & Automation
- **Terraform**: Infrastructure as Code (IaC) for Azure resources
- **PowerShell**: Windows automation, Azure management, and scripting
- **Windows Server**: On-premises and hybrid infrastructure management

### Development Platforms
- **.NET**: Enterprise applications, APIs, and microservices
- **Angular**: Frontend applications and SPAs
- **Python**: Automation scripts, data processing, and DevOps tooling

### Monitoring & Quality
- **Grafana**: Dashboards and observability
- **SonarQube Community & Enterprise**: Code quality analysis and security scanning
- **Elasticsearch**: Log aggregation, search, and analytics

## Code Generation Guidelines

### General Principles
- Prioritize security, maintainability, and enterprise-grade solutions
- Follow infrastructure as code best practices
- Implement proper error handling and logging
- Use configuration-driven approaches where possible
- Include comprehensive documentation and comments

### Azure & Cloud Development
- Use Azure CLI and PowerShell Az modules for Azure automation
- Implement proper Azure Resource Manager template structure
- Follow Azure naming conventions and tagging strategies
- Use Azure Key Vault for secrets management
- Implement proper RBAC and security controls
- Consider cost optimization in all resource deployments

### Terraform Best Practices
- Use proper module structure and versioning
- Implement remote state management with Azure Storage
- Use variables and locals appropriately
- Include proper resource tagging
- Implement terraform validation and formatting
- Use terraform workspaces for environment management

### PowerShell Development
- Use approved verbs and proper cmdlet naming
- Implement proper parameter validation and help documentation
- Use Write-Verbose, Write-Warning, and Write-Error appropriately
- Follow PowerShell best practices for error handling
- Use PowerShell classes and modules for complex functionality
- Implement proper logging with transcript capabilities

### .NET Development
- Follow C# coding standards and conventions
- Use dependency injection and configuration patterns
- Implement proper logging with structured logging (Serilog/NLog)
- Use Entity Framework Core for data access
- Implement proper exception handling and middleware
- Follow SOLID principles and clean architecture patterns
- Include unit tests and integration tests

### Angular Development
- Use Angular CLI for project structure and generation
- Follow Angular style guide and best practices
- Implement proper component architecture and lazy loading
- Use reactive forms and proper validation
- Implement proper error handling and user feedback
- Use TypeScript strictly with proper typing
- Include unit tests with Jasmine/Karma

### Python Development
- Follow PEP 8 style guidelines
- Use virtual environments and requirements.txt
- Implement proper logging with the logging module
- Use type hints for better code documentation
- Include docstrings for all functions and classes
- Implement proper error handling with try/except blocks
- Use pytest for testing

### Monitoring & Observability
- Create Grafana dashboards with proper metrics and alerts
- Implement structured logging for application insights
- Use Elasticsearch queries and mappings efficiently
- Configure SonarQube quality gates and rules
- Implement health checks and monitoring endpoints

## Security Considerations
- Never hardcode credentials or sensitive information
- Use Azure Key Vault for secrets management
- Implement proper authentication and authorization
- Follow principle of least privilege
- Use managed identities where possible
- Implement proper input validation and sanitization
- Regular security scanning with SonarQube

## Documentation Standards
- Include README.md files for all projects and modules
- Use markdown for documentation with proper formatting
- Include architecture diagrams using Mermaid or PlantUML
- Document all APIs with OpenAPI/Swagger specifications
- Include runbooks for operational procedures
- Maintain changelog files for version tracking

## Project Structure Guidelines
```
/
├── docs/                 # Documentation and architecture
├── infrastructure/       # Terraform modules and configurations
├── scripts/             # PowerShell and Python automation scripts
├── applications/        # .NET and Angular applications
├── monitoring/          # Grafana dashboards and alerting
├── pipelines/           # Azure DevOps YAML pipelines
├── configs/             # Configuration files and templates
└── examples/            # Code examples and samples
```

## File Naming Conventions
- Use kebab-case for directories and files
- Use PascalCase for .NET classes and methods
- Use camelCase for JavaScript/TypeScript variables and functions
- Use snake_case for Python variables and functions
- Use descriptive names that reflect functionality
- Include version numbers in configuration files when applicable

## Code Comments & Documentation
- Include header comments with purpose, author, and date
- Document complex business logic and algorithms
- Include TODO comments for future improvements
- Use XML documentation for .NET code
- Include JSDoc comments for TypeScript/JavaScript
- Use docstrings for Python functions and classes

## Environment Management
- Use environment-specific configuration files
- Implement proper development, staging, and production environments
- Use Azure DevOps variable groups for environment configuration
- Implement infrastructure drift detection and remediation
- Use blue-green or canary deployment strategies

## CI/CD Pipeline Considerations
- Include proper build validation and testing stages
- Implement infrastructure validation before deployment
- Use proper branching strategies (GitFlow or GitHub Flow)
- Include security scanning in pipelines
- Implement proper artifact management and versioning
- Include rollback procedures and health checks

## Troubleshooting Guidelines
- Include proper logging at appropriate levels
- Implement health check endpoints for applications
- Create runbooks for common operational issues
- Include diagnostic scripts and tools
- Document known issues and workarounds
- Implement proper alerting and monitoring

When generating code, always consider these guidelines and adapt suggestions to fit the enterprise DevOps context of this repository.