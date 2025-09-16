<#
.SYNOPSIS
    Example Azure Resource Deployment Script

.DESCRIPTION
    This script demonstrates PowerShell best practices for Azure resource deployment
    including parameter validation, error handling, and logging.

.PARAMETER ResourceGroupName
    The name of the Azure Resource Group

.PARAMETER Location
    The Azure region for resource deployment

.PARAMETER Environment
    The environment type (dev, staging, prod)

.EXAMPLE
    .\Deploy-AzureResources.ps1 -ResourceGroupName "rg-devops-dev" -Location "West Europe" -Environment "dev"

.NOTES
    Author: DevOps Team
    Date: 2024
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("West Europe", "East US", "North Europe")]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment
)

# Enable strict mode and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Import required modules
try {
    Import-Module Az -Force
    Write-Verbose "Successfully imported Az module"
}
catch {
    Write-Error "Failed to import Az module: $($_.Exception.Message)"
    exit 1
}

# Function to write structured logs
function Write-LogMessage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { Write-Host $logMessage -ForegroundColor Green }
        "WARNING" { Write-Warning $logMessage }
        "ERROR" { Write-Error $logMessage }
    }
}

# Main deployment function
function Deploy-Resources {
    try {
        Write-LogMessage "Starting Azure resource deployment"
        Write-LogMessage "Resource Group: $ResourceGroupName"
        Write-LogMessage "Location: $Location"
        Write-LogMessage "Environment: $Environment"

        # Check if resource group exists
        $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
        
        if (-not $resourceGroup) {
            Write-LogMessage "Creating resource group: $ResourceGroupName"
            $resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
            Write-LogMessage "Resource group created successfully"
        } else {
            Write-LogMessage "Resource group already exists"
        }

        # Add resource deployment logic here
        # This is where you would deploy ARM templates, create resources, etc.

        Write-LogMessage "Deployment completed successfully"
        return $true
    }
    catch {
        Write-LogMessage "Deployment failed: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

# Main execution
try {
    # Start transcript for logging
    $logPath = ".\logs\deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    Start-Transcript -Path $logPath -Append

    Write-LogMessage "Script execution started"
    
    # Authenticate to Azure (assumes user is already logged in or using managed identity)
    $context = Get-AzContext
    if (-not $context) {
        Write-LogMessage "No Azure context found. Please run Connect-AzAccount first." -Level "ERROR"
        exit 1
    }

    # Execute deployment
    $result = Deploy-Resources
    
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