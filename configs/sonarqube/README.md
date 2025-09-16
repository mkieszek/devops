# SonarQube Configuration Examples

This directory contains configuration examples for SonarQube integration.

## Authentication

### Personal Access Token
To use the Get-SonarQubeProjectInfo.ps1 script, you'll need a SonarQube personal access token:

1. Log into your SonarQube instance
2. Go to User Settings (click on your avatar)
3. Navigate to Security tab
4. Generate a new token
5. Copy the token for use with the script

### Environment Variables (Recommended)
For security, consider storing the token in environment variables:

```powershell
# Set environment variable (Windows)
$env:SONARQUBE_TOKEN = "your-token-here"

# Use in script
.\scripts\powershell\Get-SonarQubeProjectInfo.ps1 -SonarQubeUrl "https://sonarqube.company.com" -Token $env:SONARQUBE_TOKEN
```

### Azure Key Vault Integration
For enterprise environments, store the token in Azure Key Vault:

```powershell
# Retrieve from Azure Key Vault
$token = Get-AzKeyVaultSecret -VaultName "your-keyvault" -Name "sonarqube-token" -AsPlainText

# Use in script
.\scripts\powershell\Get-SonarQubeProjectInfo.ps1 -SonarQubeUrl "https://sonarqube.company.com" -Token $token
```

## Example Configuration

### sonarqube-config.json
```json
{
    "server": {
        "url": "https://sonarqube.company.com",
        "timeout": 30
    },
    "reporting": {
        "outputPath": "reports/sonarqube",
        "includePrivateProjects": true,
        "dateFormat": "yyyy-MM-dd HH:mm"
    },
    "metrics": [
        "ncloc",
        "lines",
        "last_commit_date"
    ]
}
```

## Best Practices

1. **Never commit tokens or passwords** - Use environment variables or Azure Key Vault
2. **Use HTTPS** - Always connect to SonarQube over HTTPS
3. **Regular token rotation** - Rotate access tokens periodically
4. **Least privilege** - Use tokens with minimal required permissions
5. **Logging** - Enable logging for audit and troubleshooting purposes

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify token is valid and not expired
   - Check user has appropriate permissions

2. **Connection Timeouts**
   - Verify SonarQube URL is accessible
   - Check network connectivity and firewall rules

3. **Missing Projects**
   - Verify user has permissions to view projects
   - Check if projects are private and IncludePrivate parameter is set correctly