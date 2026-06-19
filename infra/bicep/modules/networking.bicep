metadata name = 'Networking module'
metadata description = 'Deploys the shared VNet, subnets, NSG, private DNS zones, and VNet links for the approved baseline.'

targetScope = 'resourceGroup'

@description('Address prefix for the App Service integration subnet.')
param integrationSubnetPrefix string

@description('Azure region for the networking resources.')
param location string

@description('Private DNS zone names keyed by service.')
param privateDnsZoneNames object

@description('Address prefix for the private endpoints subnet.')
param privateEndpointsSubnetPrefix string

@description('Tags applied to the networking resources.')
param tags object

@description('Address space for the shared virtual network.')
param vnetAddressSpace string

@description('Name of the shared virtual network.')
param vnetName string

@description('Log Analytics workspace resource ID used by diagnostic settings.')
param workspaceId string

var privateEndpointsNsgName = take('${vnetName}-pe-nsg', 80)

resource privateEndpointsNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: privateEndpointsNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowVnetInbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 100
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyInternetInbound'
        properties: {
          access: 'Deny'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 200
          protocol: '*'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'integration'
        properties: {
          addressPrefix: integrationSubnetPrefix
          delegations: [
            {
              name: 'appServiceDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'private-endpoints'
        properties: {
          addressPrefix: privateEndpointsSubnetPrefix
          networkSecurityGroup: {
            id: privateEndpointsNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZoneNames.sql
  location: 'global'
  tags: tags
}

resource storagePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZoneNames.storageBlob
  location: 'global'
  tags: tags
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZoneNames.keyVault
  location: 'global'
  tags: tags
}

resource sqlPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: sqlPrivateDnsZone
  name: '${vnetName}-sql-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource storagePrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: storagePrivateDnsZone
  name: '${vnetName}-blob-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource keyVaultPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: keyVaultPrivateDnsZone
  name: '${vnetName}-kv-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource vnetDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${vnet.name}-diag'
  scope: vnet
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

resource nsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${privateEndpointsNsg.name}-diag'
  scope: privateEndpointsNsg
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

@description('Resource ID of the VNet.')
output vnetId string = vnet.id

@description('Resource ID of the App Service integration subnet.')
output integrationSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'integration')

@description('Resource ID of the private endpoints subnet.')
output privateEndpointsSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'private-endpoints')

@description('Resource ID of the SQL private DNS zone.')
output sqlPrivateDnsZoneId string = sqlPrivateDnsZone.id

@description('Resource ID of the Storage private DNS zone.')
output storagePrivateDnsZoneId string = storagePrivateDnsZone.id

@description('Resource ID of the Key Vault private DNS zone.')
output keyVaultPrivateDnsZoneId string = keyVaultPrivateDnsZone.id
