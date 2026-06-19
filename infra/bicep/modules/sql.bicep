metadata name = 'SQL module'
metadata description = 'Deploys the Azure SQL logical server, Basic database, private endpoint, and diagnostics for the approved baseline.'

targetScope = 'resourceGroup'

@description('Name of the SQL database.')
param databaseName string

@description('Azure region for the SQL resources.')
param location string

@description('Resource ID of the SQL private DNS zone.')
param privateDnsZoneId string

@description('Resource ID of the private endpoints subnet.')
param privateEndpointSubnetId string

@description('SQL administrator login used for the logical server.')
param sqlAdministratorLogin string

@secure()
@description('SQL administrator password used for the logical server.')
param sqlAdministratorPassword string

@description('Name of the SQL logical server.')
param sqlServerName string

@description('Tags applied to the SQL resources.')
param tags object

@description('Log Analytics workspace resource ID used by diagnostic settings.')
param workspaceId string

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    version: '12.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    autoPauseDelay: -1
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    zoneRedundant: false
  }
}

resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: take('pep-${sqlServerName}', 80)
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'sqlServerConnection'
        properties: {
          groupIds: [
            'sqlServer'
          ]
          privateLinkServiceId: sqlServer.id
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnetId
    }
  }
}

resource sqlPrivateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: sqlPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'sql'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

resource sqlServerDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${sqlServer.name}-diag'
  scope: sqlServer
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource sqlDatabaseDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${sqlDatabase.name}-diag'
  scope: sqlDatabase
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

@description('Resource ID of the SQL logical server.')
output serverId string = sqlServer.id

@description('Resource ID of the SQL database.')
output databaseId string = sqlDatabase.id
