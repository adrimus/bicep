# Create a container registry

Check the parameters file to provide a name for the container registry

## Connect to Azure

```powershell
connect-azAccount -DeviceCode

Get-AzSubscription

$context = Get-AzSubscription -SubscriptionId {Your subscription ID}
Set-AzContext $context
```

## Create Resource group if needed

```powershell
# Define rg
$rg = 'rg-docker-shared-001'

# Create rg
New-AzResourceGroup -Name $rg -Location uksouth
```

## Set default resource group

```powershell
Set-AzDefault -ResourceGroupName $rg
```

## Deploy template make sure you set location relative to files

```powershell
# Might need to change to folder
cd .\ContainerRegistry\
```

Note: Change whatif to $false after verifying

```powershell
# Get users ID
$PrincipalId = Get-AzADUser -UserPrincipalName 'chris.randomuser@contoso.cloud' | select-object -ExpandProperty Id
```

```powershell
$ht = @{
    resourceGroupName = $rg
    TemplateFile = 'main.bicep'
    TemplateParameterFile = 'main.parameters.json'
    resourceTags = @{
        StartDate= '2025-07-18'
        Requester= 'alex.jones@fabrikam.net'
        Environment = "Prod"
        CostCentre =  "IT"
        Application = "docker"
    }
    whatif = $true
    principalId = $PrincipalId
}
New-AzResourceGroupDeployment @ht
```

# Resources
[RBAC for Azure resources using Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-rbac)
[text](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication?tabs=azure-cli)
