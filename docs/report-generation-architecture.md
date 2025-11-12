# Automated Report Generation - Architecture Diagram

## Pipeline Flow

```mermaid
graph TD
    A[Scheduled Trigger<br/>Daily 2:00 AM UTC] --> B[Checkout Repository<br/>with Credentials]
    B --> C[Configure Git User<br/>azure-pipeline@devops.com]
    C --> D[Create/Verify<br/>reports/ Directory]
    D --> E[Execute PowerShell Script<br/>Get-SonarQubeProjectInfo.ps1]
    E --> F{Script<br/>Successful?}
    F -->|Yes| G[Report Generated]
    F -->|No| H[Continue with Warning]
    G --> I{Changes<br/>Detected?}
    H --> I
    I -->|Yes| J[Add Reports to Git]
    I -->|No| K[Skip Commit]
    J --> L[Commit with Timestamp<br/>+ [skip ci] Tag]
    L --> M[Push to Main Branch]
    M --> N[Cleanup Log Files]
    K --> N
    N --> O[Pipeline Complete]
    
    style A fill:#e1f5ff
    style E fill:#fff4e1
    style M fill:#e1ffe1
    style O fill:#f0f0f0
```

## Component Architecture

```mermaid
graph LR
    subgraph "Azure DevOps"
        A[Pipeline<br/>report-generation-pipeline.yml]
        B[Variable Group<br/>sonarqube-config]
        C[Build Service<br/>OAuth Token]
    end
    
    subgraph "Repository"
        D[PowerShell Script<br/>Get-SonarQubeProjectInfo.ps1]
        E[Reports Directory<br/>reports/]
        F[Main Branch]
    end
    
    subgraph "External Systems"
        G[SonarQube Server<br/>API]
    end
    
    A -->|Reads Config| B
    A -->|Uses| C
    A -->|Executes| D
    D -->|Connects to| G
    D -->|Generates| E
    A -->|Commits to| F
    E -->|Stored in| F
    
    style A fill:#4a90e2
    style B fill:#f5a623
    style C fill:#7ed321
    style D fill:#bd10e0
    style E fill:#50e3c2
    style F fill:#f8e71c
    style G fill:#ff6b6b
```

## Data Flow

```mermaid
sequenceDiagram
    participant S as Schedule (Cron)
    participant P as Azure Pipeline
    participant V as Variable Group
    participant G as Git Repository
    participant PS as PowerShell Script
    participant SQ as SonarQube API
    participant R as reports/ Directory
    
    S->>P: Trigger at 2:00 AM UTC
    P->>G: Checkout with credentials
    P->>V: Read SONARQUBE_URL & TOKEN
    P->>G: Configure git user
    P->>R: Ensure directory exists
    P->>PS: Execute Get-SonarQubeProjectInfo.ps1
    PS->>SQ: Authenticate with token
    SQ-->>PS: Return projects data
    PS->>R: Generate sonarqube-projects-report.md
    PS-->>P: Report generation complete
    P->>G: Check for changes (git status)
    alt Changes detected
        P->>G: git add reports/*.md
        P->>G: git commit -m "chore: ..."
        P->>G: git push origin HEAD:main
    else No changes
        P->>P: Skip commit
    end
    P->>P: Cleanup log files
    P-->>S: Pipeline complete
```

## Directory Structure After Pipeline Execution

```
devops/
├── .github/
├── applications/
├── configs/
├── docs/
│   ├── report-generation-setup.md          # Complete setup guide
│   ├── report-generation-quickstart.md     # Quick reference
│   └── IMPLEMENTATION_SUMMARY.md           # Implementation details
├── examples/
├── infrastructure/
├── monitoring/
├── pipelines/
│   ├── README.md                            # Updated with pipeline info
│   └── report-generation-pipeline.yml       # ⭐ Main pipeline
├── reports/                                 # ⭐ New directory
│   ├── README.md                            # Reports documentation
│   └── sonarqube-projects-report.md         # ⭐ Auto-generated report
└── scripts/
    └── powershell/
        └── Get-SonarQubeProjectInfo.ps1     # Existing script
```

## Security Model

```mermaid
graph TB
    subgraph "Secure Variables"
        A[SONARQUBE_URL<br/>Plain Text]
        B[SONARQUBE_TOKEN<br/>🔒 Secret]
    end
    
    subgraph "Pipeline Execution"
        C[Azure Pipeline<br/>Windows Agent]
        D[PowerShell Task]
        E[Git Operations]
    end
    
    subgraph "Authentication"
        F[SonarQube API<br/>Bearer Token]
        G[Git Push<br/>OAuth Token]
    end
    
    subgraph "Repository"
        H[Main Branch<br/>Automated Commits]
    end
    
    A --> D
    B --> D
    D --> F
    C --> E
    E --> G
    G --> H
    
    style B fill:#ff6b6b
    style F fill:#ff6b6b
    style G fill:#7ed321
    style H fill:#4a90e2
```

## Schedule Configuration

```yaml
# Cron Expression: "0 2 * * *"
# Format: minute hour day month weekday

┌───────────── minute (0 - 59)
│ ┌─────────── hour (0 - 23)
│ │ ┌───────── day of month (1 - 31)
│ │ │ ┌─────── month (1 - 12)
│ │ │ │ ┌───── day of week (0 - 6) (Sunday=0)
│ │ │ │ │
0 2 * * *  →  Daily at 2:00 AM UTC

Common Patterns:
- "0 2 * * *"     → Daily at 2:00 AM
- "0 */6 * * *"   → Every 6 hours
- "0 8 * * 1"     → Every Monday at 8:00 AM
- "0 0 1 * *"     → First day of month
- "0 9-17 * * 1-5" → Weekdays 9 AM to 5 PM (hourly)
```

## Commit Message Pattern

```
chore: automated report generation - YYYY-MM-DD HH:mm:ss [skip ci]
                                     └─────┬─────┘         └───┬───┘
                                          Timestamp        Prevents
                                                          CI trigger
Example:
chore: automated report generation - 2025-11-12 02:00:15 [skip ci]
```

## Integration Points

```mermaid
mindmap
  root((Automated<br/>Report<br/>Generation))
    Azure DevOps
      Pipelines
      Variable Groups
      Build Service
      Scheduled Triggers
    Repository
      Main Branch
      reports/ Directory
      Git History
      Documentation
    Scripts
      PowerShell
      Get-SonarQubeProjectInfo.ps1
      Error Handling
      Logging
    External Systems
      SonarQube API
      Authentication
      Project Metrics
      Analysis Data
    Security
      Secret Variables
      OAuth Tokens
      No Hardcoded Credentials
      Least Privilege
```

## Extensibility

```mermaid
graph LR
    A[Current: SonarQube Reports] --> B[Future: More Report Types]
    B --> C[Grafana Dashboards Export]
    B --> D[Elasticsearch Logs Summary]
    B --> E[Azure Resource Inventory]
    B --> F[Security Scan Results]
    B --> G[Cost Analysis Reports]
    
    style A fill:#4a90e2
    style B fill:#f5a623
    style C fill:#e1e1e1
    style D fill:#e1e1e1
    style E fill:#e1e1e1
    style F fill:#e1e1e1
    style G fill:#e1e1e1
```

---

## Legend

- 🔒 = Secret/Encrypted
- ⭐ = New/Modified by pipeline
- ✅ = Completed/Verified
- 📘 = Documentation
- 🔄 = Automated Process

## Notes

1. **Pipeline runs independently** - No manual intervention needed
2. **Version controlled reports** - Full history in git
3. **Secure by design** - No credentials in code
4. **Extensible architecture** - Easy to add more reports
5. **Skip CI tag** - Prevents infinite pipeline loops

---
*Diagrams generated with Mermaid syntax*
*For best viewing, use a Markdown viewer with Mermaid support*
