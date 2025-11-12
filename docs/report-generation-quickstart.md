# Quick Setup Guide - Automated Report Generation

This is a quick reference for setting up the automated report generation pipeline.

## ⚡ Quick Steps

### 1. Create Variable Group
In Azure DevOps → Pipelines → Library:
- Create variable group: `sonarqube-config`
- Add: `SONARQUBE_URL` = `https://your-sonarqube-server.com`
- Add: `SONARQUBE_TOKEN` = `your-token` (mark as secret ✓)

### 2. Create Pipeline
In Azure DevOps → Pipelines → New pipeline:
- Select repository
- Choose "Existing Azure Pipelines YAML file"
- Select: `/pipelines/report-generation-pipeline.yml`

### 3. Configure Permissions
**Option A - Azure Repos:**
Project Settings → Repositories → [Your Repo] → Security:
- Find "Build Service" account
- Set "Contribute" to **Allow** ✓

**Option B - GitHub:**
- Ensure service connection has write access
- Or use PAT with `repo` scope

### 4. Enable OAuth Token
Edit pipeline → ⋯ (three dots) → Triggers → YAML → Get sources:
- Check ✓ "Allow scripts to access the OAuth token"

### 5. Test Run
- Go to Pipelines → report-generation-pipeline
- Click "Run pipeline"
- Monitor execution
- Check `reports/` directory for generated files

## 📅 Default Schedule
Daily at 2:00 AM UTC

Change in `report-generation-pipeline.yml`:
```yaml
schedules:
- cron: "0 2 * * *"  # Modify this line
```

## 📚 Full Documentation
See [docs/report-generation-setup.md](report-generation-setup.md) for complete details.

## ❓ Common Issues

| Issue | Solution |
|-------|----------|
| Permission denied on git push | Enable OAuth token + Contribute permission |
| SonarQube connection fails | Check URL and token in variable group |
| No changes committed | Verify script is generating output |

## 🔍 Monitoring
- View reports: Browse `reports/` in main branch
- Pipeline history: Pipelines → report-generation-pipeline → Runs
- Commit history: `git log -- reports/`

---
*For detailed setup instructions, see [report-generation-setup.md](report-generation-setup.md)*
