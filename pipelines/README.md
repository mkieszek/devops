# Azure DevOps Pipeline Examples

This directory contains YAML pipeline definitions for Azure DevOps.

## Pipeline Types

- `ci-*.yml` - Continuous Integration pipelines
- `cd-*.yml` - Continuous Deployment pipelines
- `infrastructure-*.yml` - Infrastructure deployment pipelines
- `quality-*.yml` - Code quality and security scanning pipelines

## Best Practices

- Use templates for reusable pipeline components
- Implement proper variable groups for different environments
- Include security scanning in all pipelines
- Use proper artifact management
- Implement approval gates for production deployments
- Include rollback procedures

## Example Usage

```yaml
# Reference a pipeline template
extends:
  template: templates/dotnet-ci.yml
  parameters:
    projectPath: 'src/MyProject'
    buildConfiguration: 'Release'
```