metadata name = 'Key Vault module'
metadata description = 'Deploys the Key Vault, optional private endpoint, and diagnostics for the approved baseline.'

targetScope = 'resourceGroup'

@description('Name of the Key Vault.')
param keyVaultName string

@description('Azure region for the Key Vault resources.')
param location string

@description('Resource ID of the Key Vault private DNS zone.')
param privateDnsZoneId string

@description('Resource ID of the private endpoints subnet.')
param privateEndpointSubnetId string

@description('When true, deploy a private endpoint for the Key Vault. Public network access remains disabled in all cases.')
param shouldUsePrivateEndpoint bool

@description('Tags applied to the Key Vault resources.')
param tags object

@description('Microsoft Entra tenant ID for the Key Vault.')
param tenantId string

@description('Log Analytics workspace resource ID used by diagnostic settings.')
param workspaceId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    enablePurgeProtection: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
    publicNetworkAccess: 'Disabled'
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 90
    tenantId: tenantId
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = if (shouldUsePrivateEndpoint) {
  name: take('pep-${keyVault.name}', 80)
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'vault'
        properties: {
          groupIds: [
            'vault'
          ]
          privateLinkServiceId: keyVault.id
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnetId
    }
  }
}

resource keyVaultPrivateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = if (shouldUsePrivateEndpoint) {
  parent: keyVaultPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'vault'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${keyVault.name}-diag'
  scope: keyVault
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

@description('Resource ID of the Key Vault.')
output vaultId string = keyVault.id

@description('URI of the Key Vault for application configuration.')
output vaultUri string = keyVault.properties.vaultUri
