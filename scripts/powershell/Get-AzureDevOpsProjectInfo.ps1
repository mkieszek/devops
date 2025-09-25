<#
.SYNOPSIS
    Retrieves Azure DevOps project, group, and member information and generates Markdown report

.DESCRIPTION
    This script connects to Azure DevOps server, retrieves all projects with their 
    groups and group members information, then generates a Markdown table report.
    The report includes project name, group name, and members list as a single field.

.PARAMETER OrganizationUrl
    The URL of the Azure DevOps organization (e.g., https://dev.azure.com/yourorg)

.PARAMETER PersonalAccessToken
    Azure DevOps Personal Access Token (PAT) for API access

.PARAMETER OutputPath
    Path where the Markdown report will be saved (default: azuredevops-projects-report.md)

.PARAMETER ProjectFilter
    Optional filter for specific project names (supports wildcards)

.PARAMETER ApiVersion
    Azure DevOps REST API version to use (default: "6.0")

.EXAMPLE
    .\Get-AzureDevOpsProjectInfo.ps1 -OrganizationUrl "https://dev.azure.com/yourorg" -PersonalAccessToken "your-pat-here"

.EXAMPLE
    .\Get-AzureDevOpsProjectInfo.ps1 -OrganizationUrl "https://dev.azure.com/yourorg" -PersonalAccessToken "your-pat-here" -OutputPath "reports\devops-report.md"

.EXAMPLE
    .\Get-AzureDevOpsProjectInfo.ps1 -OrganizationUrl "https://dev.azure.com/yourorg" -PersonalAccessToken "your-pat-here" -ProjectFilter "DevOps*"

.EXAMPLE
    .\Get-AzureDevOpsProjectInfo.ps1 -OrganizationUrl "https://dev.azure.com/yourorg" -PersonalAccessToken "your-pat-here" -ApiVersion "7.0"

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
    [string]$OrganizationUrl,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PersonalAccessToken,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputPath = "azuredevops-projects-report.md",

    [Parameter(Mandatory = $false)]
    [string]$ProjectFilter = "*",

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiVersion = "6.0"
)

# Enable strict mode and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Global variables
$script:LogMessages = @()
$script:BaseApiUrl = ""
$script:ApiVersion = $ApiVersion
$script:GraphApiVersion = "$ApiVersion-preview.1"

function Write-LogMessage {
    <#
    .SYNOPSIS
        Writes log message with timestamp
    #>
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { Write-Host $logEntry -ForegroundColor Green }
        "WARNING" { Write-Warning $logEntry }
        "ERROR" { Write-Error $logEntry }
    }
    
    $script:LogMessages += $logEntry
}

function Initialize-AzureDevOpsApi {
    <#
    .SYNOPSIS
        Initialize Azure DevOps API connection and validate parameters
    #>
    param(
        [string]$OrgUrl,
        [string]$PAT
    )
    
    try {
        # Normalize organization URL
        $OrgUrl = $OrgUrl.TrimEnd('/')
        if (-not $OrgUrl.StartsWith('https://')) {
            throw "Organization URL must start with https://"
        }
        
        $script:BaseApiUrl = "$OrgUrl/_apis"
        
        # Create authorization header
        $encodedPAT = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PAT"))
        $headers = @{
            "Authorization" = "Basic $encodedPAT"
            "Content-Type" = "application/json"
        }
        
        # Test connection by getting organization info
        $testUrl = "$script:BaseApiUrl/connectionData?api-version=$script:ApiVersion"
        $response = Invoke-RestMethod -Uri $testUrl -Headers $headers -Method Get
        
        Write-LogMessage "Successfully connected to Azure DevOps organization: $($response.authenticatedUser.displayName)"
        return $headers
    }
    catch {
        Write-LogMessage "Failed to initialize Azure DevOps API connection: $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function Get-AzureDevOpsProjects {
    <#
    .SYNOPSIS
        Retrieves all projects from Azure DevOps organization
    #>
    param(
        [hashtable]$Headers,
        [string]$Filter = "*"
    )
    
    try {
        Write-LogMessage "Retrieving Azure DevOps projects..."
        
        $projectsUrl = "$script:BaseApiUrl/projects?api-version=$script:ApiVersion&`$top=1000"
        $response = Invoke-RestMethod -Uri $projectsUrl -Headers $Headers -Method Get
        
        $projects = $response.value
        
        # Apply filter if specified
        if ($Filter -ne "*") {
            $projects = $projects | Where-Object { $_.name -like $Filter }
        }
        
        Write-LogMessage "Found $($projects.Count) projects"
        return $projects
    }
    catch {
        Write-LogMessage "Failed to retrieve projects: $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function Get-AzureDevOpsGroups {
    <#
    .SYNOPSIS
        Retrieves security groups for a specific project
    #>
    param(
        [hashtable]$Headers,
        [string]$ProjectId
    )
    
    try {
        Write-LogMessage "Retrieving groups for project ID: $ProjectId"
        
        # Get project security groups
        $groupsUrl = "$script:BaseApiUrl/graph/groups?scopeDescriptor=$ProjectId&api-version=$script:GraphApiVersion"
        $response = Invoke-RestMethod -Uri $groupsUrl -Headers $Headers -Method Get
        
        $groups = $response.value | Where-Object { $_.principalName -match "\\[.*\\]" }
        
        Write-LogMessage "Found $($groups.Count) groups for project"
        return $groups
    }
    catch {
        Write-LogMessage "Failed to retrieve groups for project $ProjectId : $($_.Exception.Message)" -Level "WARNING"
        return @()
    }
}

function Get-AzureDevOpsGroupMembers {
    <#
    .SYNOPSIS
        Retrieves members of a specific group
    #>
    param(
        [hashtable]$Headers,
        [string]$GroupDescriptor
    )
    
    try {
        $membersUrl = "$script:BaseApiUrl/graph/memberships/$GroupDescriptor?direction=down&api-version=$script:GraphApiVersion"
        $response = Invoke-RestMethod -Uri $membersUrl -Headers $Headers -Method Get
        
        $members = @()
        foreach ($membership in $response.value) {
            if ($membership.memberDescriptor) {
                try {
                    # Get member details
                    $memberUrl = "$script:BaseApiUrl/graph/subjects/$($membership.memberDescriptor)?api-version=$script:GraphApiVersion"
                    $memberResponse = Invoke-RestMethod -Uri $memberUrl -Headers $Headers -Method Get
                    
                    if ($memberResponse.displayName) {
                        $members += $memberResponse.displayName
                    }
                }
                catch {
                    Write-LogMessage "Failed to get member details for descriptor $($membership.memberDescriptor)" -Level "WARNING"
                }
            }
        }
        
        return $members
    }
    catch {
        Write-LogMessage "Failed to retrieve group members for descriptor $GroupDescriptor : $($_.Exception.Message)" -Level "WARNING"
        return @()
    }
}

function Format-Date {
    <#
    .SYNOPSIS
        Formats date string for display
    #>
    param([string]$DateString)
    
    if ([string]::IsNullOrEmpty($DateString)) {
        return "Never"
    }
    
    try {
        $date = [DateTime]::Parse($DateString)
        return $date.ToString("yyyy-MM-dd HH:mm")
    }
    catch {
        return "Invalid Date"
    }
}

function Generate-MarkdownReport {
    <#
    .SYNOPSIS
        Generates markdown report from collected data
    #>
    param(
        [array]$ProjectData,
        [string]$OutputFilePath,
        [string]$OrgUrl
    )
    
    try {
        Write-LogMessage "Generating Markdown report at: $OutputFilePath"
        
        $reportContent = @"
# Azure DevOps Projects, Groups and Members Report

**Generated on:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Azure DevOps Organization:** $OrgUrl  
**Total Projects:** $($ProjectData.Count)

## Projects, Groups and Members Overview

| Project | Group | Members |
|---------|-------|---------|
"@

        foreach ($project in $ProjectData) {
            if ($project.Groups.Count -eq 0) {
                $reportContent += "`n| $($project.Name) | No groups found | - |"
            }
            else {
                foreach ($group in $project.Groups) {
                    $membersList = if ($group.Members.Count -gt 0) {
                        ($group.Members -join ", ")
                    } else {
                        "No members"
                    }
                    $reportContent += "`n| $($project.Name) | $($group.Name) | $membersList |"
                }
            }
        }
        
        $totalGroups = ($ProjectData | ForEach-Object { $_.Groups.Count } | Measure-Object -Sum).Sum
        $totalMembers = ($ProjectData | ForEach-Object { 
            $_.Groups | ForEach-Object { $_.Members.Count } 
        } | Measure-Object -Sum).Sum
        
        $reportContent += @"


## Summary Statistics

- **Total Projects Analyzed:** $($ProjectData.Count)
- **Total Groups Found:** $totalGroups
- **Total Members Found:** $totalMembers

---
*Report generated by Get-AzureDevOpsProjectInfo.ps1*
"@

        # Write report to file
        $reportContent | Out-File -FilePath $OutputFilePath -Encoding UTF8
        
        Write-LogMessage "Report successfully generated at: $OutputFilePath"
        return $true
    }
    catch {
        Write-LogMessage "Failed to generate report: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Get-AzureDevOpsProjectInfo {
    <#
    .SYNOPSIS
        Main function to collect Azure DevOps project information
    #>
    
    try {
        Write-LogMessage "Starting Azure DevOps project information retrieval"
        Write-LogMessage "Organization URL: $OrganizationUrl"
        Write-LogMessage "Output Path: $OutputPath"
        Write-LogMessage "Project Filter: $ProjectFilter"
        Write-LogMessage "API Version: $ApiVersion"
        
        # Initialize API connection
        $headers = Initialize-AzureDevOpsApi -OrgUrl $OrganizationUrl -PAT $PersonalAccessToken
        
        # Get all projects
        $projects = Get-AzureDevOpsProjects -Headers $headers -Filter $ProjectFilter
        
        if ($projects.Count -eq 0) {
            Write-LogMessage "No projects found matching filter: $ProjectFilter" -Level "WARNING"
            return $false
        }
        
        $projectsData = @()
        $projectCounter = 0
        
        foreach ($project in $projects) {
            $projectCounter++
            Write-Progress -Activity "Processing projects" -Status "Processing $($project.name)" -PercentComplete (($projectCounter / $projects.Count) * 100)
            
            Write-LogMessage "Processing project: $($project.name)"
            
            # Get groups for this project
            $groups = Get-AzureDevOpsGroups -Headers $headers -ProjectId $project.id
            
            $groupsData = @()
            foreach ($group in $groups) {
                Write-LogMessage "Processing group: $($group.displayName)"
                
                # Get members for this group
                $members = Get-AzureDevOpsGroupMembers -Headers $headers -GroupDescriptor $group.descriptor
                
                $groupData = [PSCustomObject]@{
                    Name = $group.displayName
                    Descriptor = $group.descriptor
                    Members = $members
                }
                
                $groupsData += $groupData
            }
            
            $projectData = [PSCustomObject]@{
                Name = $project.name
                Id = $project.id
                Description = $project.description
                Groups = $groupsData
            }
            
            $projectsData += $projectData
        }
        
        Write-Progress -Activity "Processing projects" -Completed
        
        # Generate report
        $reportGenerated = Generate-MarkdownReport -ProjectData $projectsData -OutputFilePath $OutputPath -OrgUrl $OrganizationUrl
        
        if ($reportGenerated) {
            Write-LogMessage "Azure DevOps project information retrieval completed successfully"
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
    $result = Get-AzureDevOpsProjectInfo
    
    if ($result) {
        Write-Host "`nScript completed successfully!" -ForegroundColor Green
        Write-Host "Report available at: $OutputPath" -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "`nScript completed with errors. Check the log messages above." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "`nScript failed with error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}