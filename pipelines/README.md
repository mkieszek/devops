# Azure DevOps Pipeline Examples

This directory contains YAML pipeline definitions for Azure DevOps.

## Pipeline Types

- `ci-*.yml` - Continuous Integration pipelines
- `cd-*.yml` - Continuous Deployment pipelines
- `infrastructure-*.yml` - Infrastructure deployment pipelines
- `quality-*.yml` - Code quality and security scanning pipelines
- `report-generation-pipeline.yml` - Automated report generation and commit pipeline

## Best Practices

- Use templates for reusable pipeline components
- Implement proper variable groups for different environments
- Include security scanning in all pipelines
- Use proper artifact management
- Implement approval gates for production deployments
- Include rollback procedures

## Available Pipelines

### Report Generation Pipeline
**File:** `report-generation-pipeline.yml`  
**Purpose:** Automatically generates reports from DevOps tools and commits them to the repository  
**Schedule:** Daily at 2:00 AM UTC  
**Documentation:** See [Report Generation Setup Guide](../docs/report-generation-setup.md)

**Required Variables:**
- Variable group: `sonarqube-config`
  - `SONARQUBE_URL` - SonarQube server URL
  - `SONARQUBE_TOKEN` - SonarQube authentication token (secret)

## Example Usage

```yaml
# Reference a pipeline template
extends:
  template: templates/dotnet-ci.yml
  parameters:
    projectPath: 'src/MyProject'
    buildConfiguration: 'Release'
```