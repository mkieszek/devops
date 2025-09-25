# Azure DevOps Configuration Examples

This directory contains configuration examples for Azure DevOps integration.

## Authentication

### Personal Access Token (PAT)
To use the Get-AzureDevOpsProjectInfo.ps1 script, you'll need an Azure DevOps Personal Access Token:

1. Sign in to your Azure DevOps organization
2. Go to User Settings (click on your avatar in top-right corner)
3. Select Personal Access Tokens
4. Click "New Token"
5. Configure the token:
   - **Name**: DevOps Reporting Script
   - **Organization**: Select your organization
   - **Expiration**: Set appropriate expiration date
   - **Scopes**: Select the following minimum permissions:
     - **Project and Team**: Read
     - **Identity**: Read
     - **Graph**: Read
6. Click "Create" and copy the token immediately (it won't be shown again)

### Required Permissions
The Personal Access Token needs the following scopes:
- **Project and Team (Read)**: To list projects and teams
- **Identity (Read)**: To retrieve user and group information  
- **Graph (Read)**: To access group memberships and security descriptors

### Environment Variables (Recommended)
For security, consider storing the token in environment variables:

```powershell
# Set environment variable (Windows PowerShell)
$env:AZURE_DEVOPS_PAT = "your-pat-here"

# Use in script
.\scripts\powershell\Get-AzureDevOpsProjectInfo.ps1 -OrganizationUrl "https://dev.azure.com/yourorg" -PersonalAccessToken $env:AZURE_DEVOPS_PAT
```

### Azure Key Vault Integration
For enterprise environments, store the token in Azure Key Vault:

```powershell
# Retrieve from Azure Key Vault
$pat = Get-AzKeyVaultSecret -VaultName "your-keyvault" -Name "azuredevops-pat" -AsPlainText

# Use in script
.\scripts\powershell\Get-AzureDevOpsProjectInfo.ps1 -OrganizationUrl "https://dev.azure.com/yourorg" -PersonalAccessToken $pat
```

## Example Configuration

### Basic Usage
```powershell
# Generate report for all projects
.\scripts\powershell\Get-AzureDevOpsProjectInfo.ps1 `
    -OrganizationUrl "https://dev.azure.com/yourorganization" `
    -PersonalAccessToken "your-personal-access-token-here"
```

### Advanced Usage
```powershell
# Generate report with custom output path and project filter
.\scripts\powershell\Get-AzureDevOpsProjectInfo.ps1 `
    -OrganizationUrl "https://dev.azure.com/yourorganization" `
    -PersonalAccessToken $env:AZURE_DEVOPS_PAT `
    -OutputPath "C:\Reports\DevOpsReport-$(Get-Date -Format 'yyyy-MM-dd').md" `
    -ProjectFilter "Production*"
```

## Best Practices

### Token Security
- Never commit Personal Access Tokens to source code
- Use environment variables or Azure Key Vault for token storage
- Set minimum required permissions for tokens
- Regularly rotate tokens (recommended: every 90 days)
- Monitor token usage through Azure DevOps security logs

### Script Execution
- Run scripts from a secure, controlled environment
- Use service accounts with limited permissions when possible
- Enable PowerShell execution policy appropriately: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Log script executions for audit purposes

### Error Handling
- The script includes comprehensive error handling and logging
- Review log messages for troubleshooting authentication issues
- Verify organization URL format: `https://dev.azure.com/yourorganization`

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify PAT is valid and not expired
   - Check token has required permissions (Project/Team Read, Identity Read, Graph Read)
   - Ensure organization URL is correct format

2. **Permission Denied**
   - Verify user account has access to projects and groups
   - Check if projects are private and user has appropriate access
   - Confirm token scopes include necessary permissions

3. **Connection Timeouts**
   - Verify organization URL is accessible from your network
   - Check firewall rules and proxy settings
   - Test connection manually: `Invoke-WebRequest -Uri "https://dev.azure.com/yourorg"`

4. **Empty or Missing Data**
   - Verify projects exist and are accessible
   - Check if project has security groups configured
   - Confirm user permissions to view group memberships

### API Rate Limits
Azure DevOps API has rate limits:
- Personal Access Tokens: 200 requests per user per hour
- Service Principal: Higher limits available
- The script includes delays between API calls to respect rate limits

### Support Resources
- [Azure DevOps REST API Documentation](https://docs.microsoft.com/en-us/rest/api/azure/devops/)
- [Personal Access Tokens Documentation](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
- [Azure DevOps Security and Permissions](https://docs.microsoft.com/en-us/azure/devops/organizations/security/)