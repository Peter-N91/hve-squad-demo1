metadata name = 'Monitoring module'
metadata description = 'Deploys the Log Analytics workspace used by diagnostics across the repo-only Azure baseline.'

targetScope = 'resourceGroup'

@description('Retention period, in days, for Log Analytics data.')
param diagnosticRetentionInDays int

@description('Azure region for the monitoring resources.')
param location string

@description('Name of the Log Analytics workspace.')
param logAnalyticsWorkspaceName string

@description('Tags applied to the monitoring resources.')
param tags object

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    features: {
      searchVersion: 1
    }
    retentionInDays: diagnosticRetentionInDays
    sku: {
      name: 'PerGB2018'
    }
  }
}

@description('Resource ID of the Log Analytics workspace.')
output workspaceId string = workspace.id

@description('Customer ID of the Log Analytics workspace.')
output workspaceCustomerId string = workspace.properties.customerId
