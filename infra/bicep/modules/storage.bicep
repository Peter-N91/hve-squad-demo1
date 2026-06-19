metadata name = 'Storage module'
metadata description = 'Deploys the private-only storage account, blob private endpoint, and diagnostics for the approved baseline.'

targetScope = 'resourceGroup'

@description('Azure region for the storage resources.')
param location string

@description('Resource ID of the Storage private DNS zone.')
param privateDnsZoneId string

@description('Resource ID of the private endpoints subnet.')
param privateEndpointSubnetId string

@description('Name of the storage account.')
param storageAccountName string

@description('Tags applied to the storage resources.')
param tags object

@description('Log Analytics workspace resource ID used by diagnostic settings.')
param workspaceId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
    isVersioningEnabled: true
  }
}

resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: take('pep-${storageAccount.name}', 80)
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'blob'
        properties: {
          groupIds: [
            'blob'
          ]
          privateLinkServiceId: storageAccount.id
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnetId
    }
  }
}

resource storagePrivateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: storagePrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blob'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

resource storageDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${storageAccount.name}-diag'
  scope: storageAccount
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

@description('Resource ID of the storage account.')
output storageAccountId string = storageAccount.id

@description('Primary blob endpoint of the storage account.')
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
