# bicep

## Deployment

Templates for Bicep

### Change Active subscription

```powershell
Get-AzSubscription

$context = Get-AzSubscription -SubscriptionId {Your subscription ID}
Set-AzContext $context
```

### Set the default resource group

```powershell
Set-AzDefault -ResourceGroupName {Resource Group}
```

### Deploy Template

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

### Get file hash for runbook

```powershell
get-FileHash .\runbook\test.ps1
```

## Useful commands

```powershell
# Find available api versions and locations

((Get-AzResourceProvider -ProviderNamespace Microsoft.Automation).ResourceTypes |
Where-Object -Property ResourceTypeName -EQ -Value "automationAccounts").ApiVersions 

((Get-AzResourceProvider -ProviderNamespace Microsoft.Automation).ResourceTypes |
Where-Object -Property ResourceTypeName -EQ -Value "automationAccounts").Locations
```

## Access Policy for Exchange

```powershell
connect-ExchangeOnline -Device

# Create group
$groupParams = @{
         Name = "AAP_NotificationsApp_SG"
         Alias = "AAPNotificationsAppSG"
         Type = "security"
         PrimarySMTPAddress = "AAPNotificationsAppSG@gfhg.onmicrosoft.com"
         Members = @("gdjdgj@gfjfgj.net")
     }
New-DistributionGroup @groupParams


# get Service principal
$app = Get-EntraServicePrincipal -Filter "displayName eq 'aa-Notifications-southuk'"

# assign policyto 

$policyParams = @{
        AppId = $app.appid # example ID
        PolicyScopeGroupId = "AAPNotificationsAppSG@gfhg.onmicrosoft.com"
        AccessRight = "RestrictAccess"
        Description = "Restrict aa-Notifications-southuk Managed identity  to beable to send using members of distribution group AAPNotificationsAppSG."
    }

New-ApplicationAccessPolicy @policyParams

```

## Test access policy

```powershell
# Test Policy
Test-ApplicationAccessPolicy -Identity 'gdjdgj@gfjfgj.net' -AppId $app.id
```
