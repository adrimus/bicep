## Create resource group if it doesn't exist

```powershell
New-AzResourceGroup -Name $rgName -Location $location -Force
```

## Deploy using parameter file

```powershell
# Define deployment parameters
$deploymentParams = @{
    TemplateFile         = "./main.bicep"
    TemplateParameterFile = "./main.parameters.json"
    Verbose              = $true
}

# Deploy using splatting
New-AzResourceGroupDeployment @deploymentParams
```
