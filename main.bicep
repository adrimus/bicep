param location string = resourceGroup().location
param automationAccountName string
param runbookName string = 'MyRunbook'
param resourceTags object = {
  CostCentre: 'IT'
}

// Schedule parameters
param baseTime string = utcNow('u')
@description('The start time of the schedule must be at least 5 minutes after the time you create the schedule, PT1H is onehour')
param scheduleStartTime string = dateTimeAdd(baseTime, 'PT1H')
param scheduleName string = 'Weekly'

@minLength(36)
@maxLength(36)
@description('Used to link the schedule to the runbook')
param jobScheduleName string =  guid(resourceGroup().id)

resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  name: automationAccountName
  location: location
  properties: {
    disableLocalAuth: false
    publicNetworkAccess: true
    sku: {
      name: 'Free'
    }
  }
  tags: resourceTags
}

// This is to provide script with a from and bcc email address
resource from 'Microsoft.Automation/automationAccounts/variables@2023-11-01' = {
  parent: automationAccount

  name: 'from'
  properties: {
    value: 'adrian@nypd.net'
    isEncrypted: false
  }
}
resource bcc 'Microsoft.Automation/automationAccounts/variables@2023-11-01' = {
  parent: automationAccount
  name: 'bcc'
  properties: {
    value: 'adrian@nypd.net'
    isEncrypted: false
  }
}

// Add PowerShell runtime Environment
resource PowerShellruntimeEnvironment 'Microsoft.Automation/automationAccounts/runtimeEnvironments@2023-05-15-preview' = {
  parent: automationAccount
  location: location
  name: 'PowerShell-74'
  properties: {
    description: 'PowerShell 7.4 Runtime Environment'
    runtime: {
      language: 'PowerShell'
      version: '7.4'
    }
  }
  tags: resourceTags
}

// Add required modules
resource graphUsersModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  parent: automationAccount
  name: 'Microsoft.Graph.Users'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Users'
    }
  }
}
resource graphAuthModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  parent: automationAccount
  name: 'Microsoft.Graph.Authentication'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Authentication'
    }
  }
}
resource graphMailModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  parent: automationAccount
  name: 'Microsoft.Graph.Users.Actions'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Users.Actions'
    }
  }
}

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-05-15-preview' = {
  parent: automationAccount
  name: runbookName
  location: location
  properties: {
    logVerbose: false
    logProgress: false
    description: 'This is a sample runbook'
    publishContentLink: {
      contentHash: {
        algorithm: 'SHA256'
        value: '715B29F6D7CFCB23DD37C5554380708A0442F641342C8F709EB8ECD047C9D1B9'
      }
      uri: 'https://raw.githubusercontent.com/adrimus/bicep/refs/heads/main/runbook/test.ps1'
      version: '1.0.0'
    }
    runtimeEnvironment: 'PowerShell-74'
    runbookType: 'PowerShell'
  }
}

// Add schedule
resource schedule 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' = {
  parent: automationAccount
  name: scheduleName
  properties: {
    frequency: 'week'
    interval: 1
    startTime: scheduleStartTime
    timeZone: 'CET'
  }
}

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2023-11-01' = {
  parent: automationAccount
  name: jobScheduleName
  properties: {
    runbook: {
      name: runbookName
    }
    schedule: {
      name: schedule.name
    }
  }
}

output automationAccountId string = automationAccount.id
