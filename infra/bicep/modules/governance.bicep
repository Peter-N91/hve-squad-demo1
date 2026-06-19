metadata name = 'Governance module'
metadata description = 'Deploys the subscription budget definitions for the approved baseline.'

targetScope = 'subscription'

@description('Optional email recipients for budget notifications.')
param budgetContactEmails array

@description('Name of the subscription budget resource.')
param budgetName string

@description('Monthly subscription budget ceiling in the local billing currency.')
param monthlyBudgetLimit int

@description('Tags retained for reviewer context in module outputs.')
param tags object

var budgetStartDate = '2026-01-01'
var budgetEndDate = '2030-12-31'

resource monthlyBudget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: budgetName
  properties: {
    amount: monthlyBudgetLimit
    category: 'Cost'
    notifications: {
      actual80: {
        contactEmails: budgetContactEmails
        contactRoles: [
          'Owner'
        ]
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
      }
      actual100: {
        contactEmails: budgetContactEmails
        contactRoles: [
          'Owner'
        ]
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
      }
    }
    timeGrain: 'Monthly'
    timePeriod: {
      endDate: budgetEndDate
      startDate: budgetStartDate
    }
  }
}

@description('Budget resource ID for reviewer reference.')
output budgetId string = monthlyBudget.id

@description('Tag values passed into the governance module for review context.')
output reviewTags object = tags
