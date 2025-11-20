# Automated Report Generation Setup Guide

This guide explains how to set up and configure the automated report generation pipeline in Azure DevOps.

## Overview

The automated report generation pipeline runs scheduled tasks to generate reports from various DevOps tools (like SonarQube) and automatically commits the results to the repository.

## Pipeline File

**Location:** `/pipelines/report-generation-pipeline.yml`

## Prerequisites

1. **Azure DevOps Project** with access to the repository
2. **Azure Pipeline** capability enabled
3. **SonarQube Server** accessible from Azure DevOps agents
4. **Service Connection** or authentication token for SonarQube

## Setup Steps

### 1. Create Variable Group in Azure DevOps

Navigate to Azure DevOps → Pipelines → Library → Variable groups

Create a new variable group named: **`sonarqube-config`**

Add the following variables:

| Variable Name | Value | Type | Description |
|---------------|-------|------|-------------|
| `SONARQUBE_URL` | `https://your-sonarqube-server.com` | Plain text | URL of your SonarQube server |
| `SONARQUBE_TOKEN` | `your-sonarqube-token` | Secret | SonarQube authentication token |

**Important:** Mark the `SONARQUBE_TOKEN` as a secret variable.

#### How to Generate SonarQube Token

1. Log in to your SonarQube server
2. Go to: My Account → Security → Generate Tokens
3. Enter a token name (e.g., "Azure DevOps Pipeline")
4. Click "Generate"
5. Copy the token (it won't be shown again)

### 2. Create the Pipeline in Azure DevOps

1. Go to: Pipelines → New Pipeline
2. Select: Azure Repos Git (or GitHub if hosted there)
3. Select your repository
4. Choose: "Existing Azure Pipelines YAML file"
5. Select the pipeline file: `/pipelines/report-generation-pipeline.yml`
6. Click "Continue"

### 3. Configure Pipeline Permissions

The pipeline needs permission to push changes back to the repository.

#### For Azure Repos:
1. Go to: Project Settings → Repositories → Select your repository
2. Navigate to: Security tab
3. Find: "Build Service" account
4. Grant the following permissions:
   - **Contribute:** Allow
   - **Create Branch:** Allow
   - **Contribute to Pull Requests:** Allow (optional)

#### For GitHub:
1. Ensure the Azure Pipeline has a GitHub service connection
2. The service connection should have write permissions to the repository
3. Or use a Personal Access Token (PAT) with `repo` scope

### 4. Enable System.AccessToken

In the pipeline YAML, the `System.AccessToken` is used for git operations.

Ensure this is enabled:
1. Edit the pipeline
2. Click on the three dots (⋯) → Triggers
3. Go to YAML → Get sources
4. Check: "Allow scripts to access the OAuth token"

### 5. Run and Test the Pipeline

#### Manual Run (for testing):
1. Go to: Pipelines → Select the report-generation-pipeline
2. Click "Run pipeline"
3. Monitor the execution
4. Check the "reports" directory for generated files

#### Scheduled Run:
The pipeline is configured to run daily at 2:00 AM UTC via cron schedule:
```yaml
schedules:
- cron: "0 2 * * *"
```

You can modify the schedule by editing the pipeline YAML.

## Pipeline Behavior

### What the Pipeline Does

1. **Checkout:** Clones the repository with persistent credentials
2. **Configure Git:** Sets up git user for automated commits
3. **Create Directory:** Ensures the reports directory exists
4. **Generate Reports:** Runs the PowerShell script to generate SonarQube report
5. **Commit Changes:** If changes are detected, commits them with timestamp
6. **Push to Main:** Pushes the commit to the main branch
7. **Cleanup:** Removes temporary log files

### Commit Message Format

Automated commits use the format:
```
chore: automated report generation - YYYY-MM-DD HH:mm:ss [skip ci]
```

The `[skip ci]` tag prevents the commit from triggering other CI/CD pipelines.

## Customization

### Changing the Schedule

Edit the cron expression in the pipeline YAML:

```yaml
schedules:
- cron: "0 2 * * *"  # Daily at 2:00 AM UTC
```

Common cron patterns:
- `0 2 * * *` - Daily at 2:00 AM
- `0 */6 * * *` - Every 6 hours
- `0 8 * * 1` - Every Monday at 8:00 AM
- `0 0 1 * *` - First day of every month at midnight

### Adding More Reports

To add additional report generation scripts:

1. Add the script to `/scripts/powershell/` or appropriate directory
2. Add a new PowerShell task in the pipeline:

```yaml
- task: PowerShell@2
  displayName: 'Generate Custom Report'
  inputs:
    targetType: 'filePath'
    filePath: '$(Build.SourcesDirectory)/scripts/powershell/Your-Script.ps1'
    arguments: '-Parameter1 "value1" -OutputPath "$(Build.SourcesDirectory)/$(reportDirectory)/custom-report.md"'
```

3. Ensure the commit step includes the new report:

```yaml
git add $(reportDirectory)/*.md
```

### Changing Target Branch

To commit to a different branch (e.g., `reports` branch):

```yaml
- task: PowerShell@2
  displayName: 'Check for changes and commit'
  inputs:
    targetType: 'inline'
    script: |
      # ... existing code ...
      git push origin HEAD:reports  # Change 'main' to 'reports'
```

## Troubleshooting

### Issue: Pipeline fails with "Permission denied" during git push

**Solution:** 
- Ensure "Allow scripts to access the OAuth token" is enabled
- Verify Build Service has Contribute permissions on the repository

### Issue: Pipeline runs but doesn't commit changes

**Solution:**
- Check if changes are actually being generated by the script
- Verify the PowerShell script is outputting to the correct path
- Check pipeline logs for git status output

### Issue: SonarQube connection fails

**Solution:**
- Verify `SONARQUBE_URL` is correct and accessible from Azure DevOps agents
- Verify `SONARQUBE_TOKEN` is valid and has not expired
- Check SonarQube server firewall allows Azure DevOps agent IPs

### Issue: Script generates errors but pipeline continues

**Solution:**
The pipeline uses `continueOnError: true` to prevent script failures from stopping the pipeline. To make it fail on errors:

```yaml
- task: PowerShell@2
  displayName: 'Generate SonarQube Project Report'
  inputs:
    # ... other inputs ...
    errorActionPreference: 'stop'
    failOnStderr: true
  continueOnError: false  # Change to false
```

## Monitoring

### View Generated Reports

Reports are committed to the `reports/` directory in the main branch:
- Latest reports: Browse to `/reports/` in the repository
- Historical reports: Use `git log -- reports/` to see report history

### Pipeline Execution History

1. Go to: Pipelines → report-generation-pipeline
2. View: Runs tab shows all executions
3. Click on a run to see detailed logs

### Email Notifications

Configure pipeline failure notifications:
1. Go to: Project Settings → Notifications
2. Create a new subscription
3. Select: "Build completes" or "Build fails"
4. Add email addresses

## Security Best Practices

1. **Never commit tokens or credentials** to the repository
2. **Always use secret variables** for sensitive data like SONARQUBE_TOKEN
3. **Limit pipeline permissions** to only what's needed
4. **Regularly rotate tokens** used by the pipeline
5. **Review commit history** periodically to ensure only expected changes

## Manual Report Generation

You can also generate reports manually without the pipeline:

```powershell
# Navigate to repository root
cd /path/to/devops

# Generate SonarQube report
.\scripts\powershell\Get-SonarQubeProjectInfo.ps1 `
    -SonarQubeUrl "https://sonarqube.company.com" `
    -Token "your-token-here" `
    -OutputPath "reports/sonarqube-projects-report.md"

# Commit manually
git add reports/sonarqube-projects-report.md
git commit -m "chore: manual report generation"
git push
```

## Additional Resources

- [Azure Pipelines YAML Schema](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
- [Cron Expression Generator](https://crontab.guru/)
- [SonarQube API Documentation](https://docs.sonarqube.org/latest/extend/web-api/)
- [PowerShell Script Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review pipeline execution logs in Azure DevOps
3. Contact the DevOps team

---
*Last updated: 2025-11-12*
