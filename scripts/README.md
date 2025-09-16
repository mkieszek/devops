# Automation Scripts

This directory contains automation scripts for various DevOps tasks.

## Structure

- `powershell/` - PowerShell scripts for Windows and Azure automation
- `python/` - Python scripts for cross-platform automation and tooling

## PowerShell Scripts

### Prerequisites
- PowerShell 7+
- Azure PowerShell module (for Azure scripts)
- Appropriate Azure permissions (for Azure scripts)
- SonarQube authentication token (for SonarQube scripts)

### Available Scripts

#### Get-SonarQubeProjectInfo.ps1
Retrieves project information from SonarQube including Lines of Code (LOC) and last scan dates, then generates a Markdown report.

```powershell
# Basic usage
.\powershell\Get-SonarQubeProjectInfo.ps1 -SonarQubeUrl "https://sonarqube.company.com" -Token "your-token-here"

# Custom output path
.\powershell\Get-SonarQubeProjectInfo.ps1 -SonarQubeUrl "https://sonarqube.company.com" -Token "your-token-here" -OutputPath "reports\sonar-report.md"
```

### Usage
```powershell
# Import modules if needed
Import-Module Az

# Run scripts with parameters
.\powershell\Deploy-Resources.ps1 -Environment "dev" -ResourceGroup "rg-devops-dev"
```

## Python Scripts

### Prerequisites
- Python 3.9+
- Azure CLI
- Required pip packages (see requirements.txt)

### Usage
```bash
# Install dependencies
pip install -r requirements.txt

# Run scripts
python python/azure_automation.py --environment dev
```

## Best Practices

- Include proper error handling
- Use configuration files for environment-specific settings
- Implement logging for all operations
- Include help documentation
- Test scripts in development environment first
- Use version control for script dependencies