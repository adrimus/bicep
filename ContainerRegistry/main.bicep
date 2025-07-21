@description('Provide a date and requester email when you deploy template')
param resourceTags object

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param containerRegistryName string

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Optional. Tier of your Azure container registry.')
@allowed([
  'Basic'
  'Classic'
  'Premium'
  'Standard'
])
param acrSku string = 'Basic'

@description('GUID that represents the Microsoft Entra identifier for the principal.')
param principalId string // Object ID of the user

@description('This is the built-in Contributor role. See https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#contributor. You can not ')
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}


resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
  tags: resourceTags
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  
name: guid(acrResource.id, principalId, contributorRoleDefinition.id)
  scope: acrResource
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: principalId
    principalType: 'User' // or 'ServicePrincipal', 'Group', etc.
  }

}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
