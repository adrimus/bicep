# bicep

Templates for Bicep

## Change Active subscription

```powershell
Get-AzSubscription

$context = Get-AzSubscription -SubscriptionId {Your subscription ID}
Set-AzContext $context
```

## Set the default resource group

```powershell
Set-AzDefault -ResourceGroupName {Resource Group}
```

## Deploy Template

```powershell
# Define parameters
$deploymentParams = @{
    TemplateFile = "main.bicep"
    resourceTags = @{
        StartDate = "2025-12-02"
        CostCentre = 'IT'
        Requester = 'John.McClane@nypd.net'
    }
}

# Deploy the Bicep file using splatting
New-AzResourceGroupDeployment @deploymentParams
```

## Useful commands

```powershell
# Find available api versions for RunBooks

((Get-AzResourceProvider -ProviderNamespace "Microsoft.Automation").ResourceTypes |
  Where-Object -Property ResourceTypeName -EQ -Value "automationAccounts/runbooks").ApiVersions
```

## Get file hash for runbook

```powershell
get-FileHash .\runbook\test.ps1
```
