// Link schedule to runbook
@minLength(36)
@maxLength(36)
@description('Used to link the schedule to the runbook')
param jobScheduleName string =  guid(resourceGroup().id)

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
  dependsOn: [
    runbook
  ]
}

