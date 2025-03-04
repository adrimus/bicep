param runbookType string = 'PowerShell'
// Runbook Parameters
param runbookName string
param artifactsLocation string

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  name: runbookName
  parent: automationAccount
  location: location
  properties: {
    runbookType: runbookType
    logVerbose: false
    logProgress: false
    publishContentLink: {
      uri: artifactsLocation
      version: '1.0.0.0'
    }
  }
  tags: resourceTags
}
output runbookId string = runbook.id
