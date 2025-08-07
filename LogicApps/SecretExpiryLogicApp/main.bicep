param logic_App_Name string
param fromMailboxAddress string
param toMailboxAddress string
param warningDays int = 14
param emailSubject string = 'Entra App Registration secret is going to expire!'
param emailImportance string = 'High'
param location string = resourceGroup().location
param resourceTags object = {
  CostCentre: 'IT'
}

resource office365Connection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'office365-${logic_App_Name}'
  location: location
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'office365')
    }
    displayName: 'office365-${logic_App_Name}'
  }
}

resource workflows_logic_App 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logic_App_Name
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            frequency: 'Week'
            interval: 1
          }
          evaluatedRecurrence: {
            frequency: 'Week'
            interval: 1
          }
          type: 'Recurrence'
        }
      }
      actions: {
        For_each_appid: {
          foreach: '@body(\'Parse_JSON_Get_Azure_Applications\')?[\'value\']'
          actions: {
            For_each_passwordCredential: {
              foreach: '@items(\'For_each_appid\')?[\'passwordCredentials\']'
              actions: {
                Condition: {
                  actions: {
                    'Send_an_email_from_a_shared_mailbox_(V2)': {
                      type: 'ApiConnection'
                      inputs: {
                        host: {
                          connection: {
                            name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
                          }
                        }
                        method: 'post'
                        body: {
                          MailboxAddress: fromMailboxAddress
                          To: toMailboxAddress
                          Subject: emailSubject
                          Body: '<p class="editor-paragraph">One of the client secrets is going to expire from Entra App Registration;<br>@{items(\'For_each_appid\')?[\'displayName\']}<br><br>Details:<br>Secret ID: @{items(\'For_each_passwordCredential\')?[\'keyId\']}<br>Display Name: @{items(\'For_each_passwordCredential\')?[\'displayName\']}<br>Expiration date: @{items(\'For_each_passwordCredential\')?[\'endDateTime\']}<br><br>App Registration location;<br>https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/Overview/appId/@{items(\'For_each_appid\')?[\'appId\']}</p><p class="editor-paragraph"><br><br>Please take action as soon as possible.</p>'
                          Importance: emailImportance
                        }
                        path: '/v2/SharedMailbox/Mail'
                      }
                    }
                  }
                  else: {
                    actions: {}
                  }
                  expression: {
                    and: [
                      {
                        less: [
                          '@items(\'For_each_passwordCredential\')?[\'endDateTime\']'
                          '@addToTime(utcNow(),${warningDays},\'day\')'
                        ]
                      }
                    ]
                  }
                  type: 'If'
                }
              }
              runAfter: {
                Set_variable_passwordCredential: [
                  'Succeeded'
                ]
              }
              type: 'Foreach'
            }
            Set_variable_appid: {
              type: 'SetVariable'
              inputs: {
                name: 'appId'
                value: '@items(\'For_each_appid\')?[\'appId\']'
              }
            }
            Set_variable_displayName: {
              runAfter: {
                Set_variable_appid: [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'displayName'
                value: '@items(\'For_each_appid\')?[\'displayName\']'
              }
            }
            Set_variable_passwordCredential: {
              runAfter: {
                Set_variable_displayName: [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'passwordCredential'
                value: '@items(\'For_each_appid\')?[\'passwordCredentials\']'
              }
            }
          }
          runAfter: {
            Parse_JSON_Get_Azure_Applications: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        HTTP_Get_Azure_Applications: {
          runAfter: {
            Initialize_displayName: [
              'Succeeded'
            ]
          }
          type: 'Http'
          inputs: {
            uri: 'https://graph.microsoft.com/v1.0/applications?$select=id,appId,displayName,passwordCredentials'
            method: 'GET'
            authentication: {
              type: 'ManagedServiceIdentity'
              audience: 'https://graph.microsoft.com/'
            }
          }
        }
        Initialize_appid: {
          runAfter: {}
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'appId'
                type: 'string'
              }
            ]
          }
        }
        Initialize_displayName: {
          runAfter: {
            Initialize_passwordCredential: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'displayName'
                type: 'string'
              }
            ]
          }
        }
        Parse_JSON_Get_Azure_Applications: {
          runAfter: {
            HTTP_Get_Azure_Applications: [
              'Succeeded'
            ]
          }
          type: 'ParseJson'
          inputs: {
            content: '@body(\'HTTP_Get_Azure_Applications\')'
            schema: {
              properties: {
                '@@odata.context': {
                  type: 'string'
                }
                value: {
                  items: {
                    properties: {
                      appId: {
                        type: 'string'
                      }
                      displayName: {
                        type: 'string'
                      }
                      id: {
                        type: 'string'
                      }
                      passwordCredentials: {
                        type: 'array'
                      }
                    }
                    required: [
                      'id'
                      'appId'
                      'displayName'
                      'passwordCredentials'
                    ]
                    type: 'object'
                  }
                  type: 'array'
                }
              }
              type: 'object'
            }
          }
        }
        Initialize_passwordCredential: {
          runAfter: {
            Initialize_appid: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'passwordCredential'
                type: 'array'
              }
            ]
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          office365: {
            connectionId: office365Connection.id
            connectionName: office365Connection.name
            id: office365Connection.properties.api.id
          }
        }
      }
    }
  }
}
