# Automated Reports

This directory contains automatically generated reports from various DevOps tools and systems.

## Report Types

### SonarQube Project Reports
- **File:** `sonarqube-projects-report.md`
- **Description:** Comprehensive report of all SonarQube projects including lines of code, last scan date, and project metrics
- **Generation Frequency:** Daily at 2:00 AM UTC
- **Pipeline:** `report-generation-pipeline.yml`

## Automated Generation

Reports in this directory are automatically generated and committed by Azure DevOps pipelines. The automation:

1. Runs on a scheduled basis (daily)
2. Executes report generation scripts from `scripts/powershell/`
3. Saves reports to this directory
4. Commits changes back to the main branch

## Pipeline Configuration

The automated report generation is configured in:
- **Pipeline:** `/pipelines/report-generation-pipeline.yml`
- **Schedule:** Daily at 2:00 AM UTC (configurable via cron expression)
- **Required Variables:** 
  - `SONARQUBE_URL` - SonarQube server URL
  - `SONARQUBE_TOKEN` - SonarQube authentication token

These variables should be configured in Azure DevOps variable group: `sonarqube-config`

## Manual Report Generation

You can also generate reports manually by running the scripts directly:

```powershell
# Generate SonarQube project report
.\scripts\powershell\Get-SonarQubeProjectInfo.ps1 `
    -SonarQubeUrl "https://sonarqube.company.com" `
    -Token "your-token-here" `
    -OutputPath "reports/sonarqube-projects-report.md"
```

## Report Retention

- Reports are versioned in git history
- Latest version is always available in this directory
- Historical versions can be accessed via git log and commits

## Adding New Reports

To add a new automated report:

1. Create the report generation script in `scripts/powershell/` or appropriate directory
2. Add a new job or step to `report-generation-pipeline.yml`
3. Configure required variables in Azure DevOps variable groups
4. Update this README with the new report information

## Notes

- Commits from automated report generation include `[skip ci]` to prevent triggering other pipelines
- Git is configured with automated user: `Azure Pipeline Bot <azure-pipeline@devops.com>`
- Reports are committed only when changes are detected
