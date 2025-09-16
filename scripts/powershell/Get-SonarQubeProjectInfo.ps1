<#
.SYNOPSIS
    Retrieves SonarQube project information and generates Markdown report

.DESCRIPTION
    This script connects to SonarQube server, retrieves all projects with their 
    Lines of Code (LOC) and last scan date information, then generates a 
    Markdown table report.

.PARAMETER SonarQubeUrl
    The URL of the SonarQube server (e.g., https://sonarqube.company.com)

.PARAMETER Token
    SonarQube authentication token for API access

.PARAMETER OutputPath
    Path where the Markdown report will be saved (default: sonarqube-projects-report.md)

.PARAMETER IncludePrivate
    Include private projects in the report (default: $true)

.EXAMPLE
    .\Get-SonarQubeProjectInfo.ps1 -SonarQubeUrl "https://sonarqube.company.com" -Token "your-token-here"

.EXAMPLE
    .\Get-SonarQubeProjectInfo.ps1 -SonarQubeUrl "https://sonarqube.company.com" -Token "your-token-here" -OutputPath "reports\sonar-report.md"

.NOTES
    Author: DevOps Team
    Date: 2025
    Version: 1.0
    Requires: PowerShell 5.1 or higher
    Dependencies: Invoke-RestMethod (built-in)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SonarQubeUrl,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Token,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = "sonarqube-projects-report.md",

    [Parameter(Mandatory = $false)]
    [bool]$IncludePrivate = $true
)

# Enable strict mode and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Global variables
$script:logLevel = "INFO"

#region Helper Functions

function Write-LogMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("DEBUG", "INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "DEBUG" { Write-Debug $logMessage }
        "INFO" { Write-Information $logMessage -InformationAction Continue }
        "WARNING" { Write-Warning $logMessage }
        "ERROR" { Write-Error $logMessage }
    }
}

function Test-SonarQubeConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        
        [Parameter(Mandatory = $true)]
        [string]$AuthToken
    )
    
    try {
        Write-LogMessage "Testing SonarQube connection to: $Url"
        
        $headers = @{
            'Authorization' = "Bearer $AuthToken"
            'Accept' = 'application/json'
        }
        
        $testUrl = "$Url/api/system/status"
        $response = Invoke-RestMethod -Uri $testUrl -Headers $headers -Method Get -TimeoutSec 30
        
        if ($response.status -eq "UP") {
            Write-LogMessage "SonarQube connection successful. Status: $($response.status)"
            return $true
        } else {
            Write-LogMessage "SonarQube connection test failed. Status: $($response.status)" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-LogMessage "Failed to connect to SonarQube: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Get-SonarQubeProjects {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        
        [Parameter(Mandatory = $true)]
        [string]$AuthToken,
        
        [Parameter(Mandatory = $false)]
        [bool]$IncludePrivateProjects = $true
    )
    
    try {
        Write-LogMessage "Retrieving SonarQube projects list"
        
        $headers = @{
            'Authorization' = "Bearer $AuthToken"
            'Accept' = 'application/json'
        }
        
        $projectsUrl = "$Url/api/projects/search"
        $params = @{
            'ps' = 500  # Page size (max 500)
            'p' = 1     # Page number
        }
        
        $allProjects = @()
        $page = 1
        
        do {
            $params['p'] = $page
            $queryString = ($params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
            $requestUrl = "$projectsUrl?$queryString"
            
            Write-LogMessage "Fetching page $page of projects"
            $response = Invoke-RestMethod -Uri $requestUrl -Headers $headers -Method Get -TimeoutSec 60
            
            $allProjects += $response.components
            $page++
            
        } while ($response.components.Count -eq $params['ps'] -and $page -le 10) # Safety limit
        
        Write-LogMessage "Retrieved $($allProjects.Count) projects from SonarQube"
        return $allProjects
    }
    catch {
        Write-LogMessage "Failed to retrieve SonarQube projects: $($_.Exception.Message)" -Level "ERROR"
        return @()
    }
}

function Get-ProjectMetrics {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        
        [Parameter(Mandatory = $true)]
        [string]$AuthToken,
        
        [Parameter(Mandatory = $true)]
        [string]$ProjectKey
    )
    
    try {
        $headers = @{
            'Authorization' = "Bearer $AuthToken"
            'Accept' = 'application/json'
        }
        
        # Get project metrics (LOC, last analysis date, etc.)
        $metricsUrl = "$Url/api/measures/component"
        $metrics = "ncloc,lines,last_commit_date"
        $params = @{
            'component' = $ProjectKey
            'metricKeys' = $metrics
        }
        
        $queryString = ($params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
        $requestUrl = "$metricsUrl?$queryString"
        
        $response = Invoke-RestMethod -Uri $requestUrl -Headers $headers -Method Get -TimeoutSec 30
        
        # Get project analysis history for last scan date
        $analysisUrl = "$Url/api/project_analyses/search"
        $analysisParams = @{
            'project' = $ProjectKey
            'ps' = 1
        }
        
        $analysisQueryString = ($analysisParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
        $analysisRequestUrl = "$analysisUrl?$analysisQueryString"
        
        $analysisResponse = Invoke-RestMethod -Uri $analysisRequestUrl -Headers $headers -Method Get -TimeoutSec 30
        
        # Process metrics
        $metrics = @{
            'LinesOfCode' = 'N/A'
            'TotalLines' = 'N/A'
            'LastScanDate' = 'N/A'
        }
        
        if ($response.component.measures) {
            foreach ($measure in $response.component.measures) {
                switch ($measure.metric) {
                    'ncloc' { $metrics['LinesOfCode'] = $measure.value }
                    'lines' { $metrics['TotalLines'] = $measure.value }
                }
            }
        }
        
        if ($analysisResponse.analyses -and $analysisResponse.analyses.Count -gt 0) {
            $lastAnalysis = $analysisResponse.analyses[0]
            $metrics['LastScanDate'] = $lastAnalysis.date
        }
        
        return $metrics
    }
    catch {
        Write-LogMessage "Failed to retrieve metrics for project '$ProjectKey': $($_.Exception.Message)" -Level "WARNING"
        return @{
            'LinesOfCode' = 'Error'
            'TotalLines' = 'Error'
            'LastScanDate' = 'Error'
        }
    }
}

function Format-Date {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DateString
    )
    
    try {
        if ($DateString -eq 'N/A' -or $DateString -eq 'Error') {
            return $DateString
        }
        
        $date = [DateTime]::Parse($DateString)
        return $date.ToString("yyyy-MM-dd HH:mm")
    }
    catch {
        return $DateString
    }
}

function Generate-MarkdownReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$ProjectsData,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputFilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$SonarUrl
    )
    
    try {
        Write-LogMessage "Generating Markdown report at: $OutputFilePath"
        
        $reportContent = @"
# SonarQube Projects Report

**Generated on:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**SonarQube Server:** $SonarUrl  
**Total Projects:** $($ProjectsData.Count)

## Projects Overview

| Project Name | Project Key | Lines of Code | Total Lines | Last Scan Date |
|--------------|-------------|---------------|-------------|----------------|
"@

        foreach ($project in $ProjectsData) {
            $formattedDate = Format-Date -DateString $project.LastScanDate
            $reportContent += "`n| $($project.Name) | $($project.Key) | $($project.LinesOfCode) | $($project.TotalLines) | $formattedDate |"
        }
        
        $reportContent += @"


## Summary Statistics

- **Total Projects Analyzed:** $($ProjectsData.Count)
- **Total Lines of Code:** $(($ProjectsData | Where-Object { $_.LinesOfCode -match '^\d+$' } | ForEach-Object { [int]$_.LinesOfCode } | Measure-Object -Sum).Sum)
- **Projects with Recent Scans (last 30 days):** $(($ProjectsData | Where-Object { 
    try { 
        $_.LastScanDate -ne 'N/A' -and $_.LastScanDate -ne 'Error' -and 
        [DateTime]::Parse($_.LastScanDate) -gt (Get-Date).AddDays(-30) 
    } catch { 
        $false 
    } 
}).Count)

---
*Report generated by Get-SonarQubeProjectInfo.ps1*
"@

        # Ensure output directory exists
        $outputDir = Split-Path -Path $OutputFilePath -Parent
        if ($outputDir -and -not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        $reportContent | Out-File -FilePath $OutputFilePath -Encoding UTF8 -Force
        Write-LogMessage "Report successfully saved to: $OutputFilePath"
        
        return $true
    }
    catch {
        Write-LogMessage "Failed to generate report: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

#endregion

#region Main Execution

function Get-SonarQubeProjectInformation {
    [CmdletBinding()]
    param()
    
    try {
        Write-LogMessage "Starting SonarQube project information retrieval"
        Write-LogMessage "SonarQube URL: $SonarQubeUrl"
        Write-LogMessage "Output Path: $OutputPath"
        Write-LogMessage "Include Private Projects: $IncludePrivate"
        
        # Test SonarQube connection
        if (-not (Test-SonarQubeConnection -Url $SonarQubeUrl -AuthToken $Token)) {
            Write-LogMessage "Cannot proceed without valid SonarQube connection" -Level "ERROR"
            return $false
        }
        
        # Get all projects
        $projects = Get-SonarQubeProjects -Url $SonarQubeUrl -AuthToken $Token -IncludePrivateProjects $IncludePrivate
        
        if ($projects.Count -eq 0) {
            Write-LogMessage "No projects found in SonarQube" -Level "WARNING"
            return $false
        }
        
        # Collect project data with metrics
        $projectsData = @()
        $progressCount = 0
        
        foreach ($project in $projects) {
            $progressCount++
            Write-Progress -Activity "Collecting project metrics" -Status "Processing $($project.name)" -PercentComplete (($progressCount / $projects.Count) * 100)
            
            Write-LogMessage "Processing project: $($project.name) ($($project.key))"
            
            $metrics = Get-ProjectMetrics -Url $SonarQubeUrl -AuthToken $Token -ProjectKey $project.key
            
            $projectData = [PSCustomObject]@{
                Name = $project.name
                Key = $project.key
                LinesOfCode = $metrics.LinesOfCode
                TotalLines = $metrics.TotalLines
                LastScanDate = $metrics.LastScanDate
            }
            
            $projectsData += $projectData
        }
        
        Write-Progress -Activity "Collecting project metrics" -Completed
        
        # Generate report
        $reportGenerated = Generate-MarkdownReport -ProjectsData $projectsData -OutputFilePath $OutputPath -SonarUrl $SonarQubeUrl
        
        if ($reportGenerated) {
            Write-LogMessage "SonarQube project information retrieval completed successfully"
            Write-LogMessage "Report location: $(Resolve-Path $OutputPath -ErrorAction SilentlyContinue)"
            return $true
        } else {
            Write-LogMessage "Failed to generate report" -Level "ERROR"
            return $false
        }
    }
    catch {
        Write-LogMessage "Unexpected error during execution: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

# Main execution
try {
    # Start transcript for logging
    $logPath = "sonarqube-script-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    Start-Transcript -Path $logPath -Append
    
    Write-LogMessage "Script execution started"
    
    # Execute main function
    $result = Get-SonarQubeProjectInformation
    
    if ($result) {
        Write-LogMessage "Script completed successfully"
        exit 0
    } else {
        Write-LogMessage "Script completed with errors" -Level "ERROR"
        exit 1
    }
}
catch {
    Write-LogMessage "Unexpected error: $($_.Exception.Message)" -Level "ERROR"
    exit 1
}
finally {
    Stop-Transcript
}

#endregion