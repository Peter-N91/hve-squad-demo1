metadata name = 'App Service module'
metadata description = 'Deploys the shared B1 App Service plan and the frontend and backend web apps with managed identity and Entra auth.'

targetScope = 'resourceGroup'

@description('Name of the backend App Service web app.')
param backendAppName string

@description('Client ID for the backend Microsoft Entra application registration.')
param backendClientId string

@description('Name of the frontend App Service web app.')
param frontendAppName string

@description('Client ID for the frontend Microsoft Entra application registration.')
param frontendClientId string

@description('URI of the Key Vault used by the applications.')
param keyVaultUri string

@description('Azure region for the App Service resources.')
param location string

@description('Log Analytics workspace resource ID used by diagnostic settings.')
param logAnalyticsWorkspaceId string

@description('Name of the shared App Service plan.')
param planName string

@description('Resource ID of the App Service integration subnet.')
param subnetId string

@description('Tags applied to the App Service resources.')
param tags object

@description('Microsoft Entra tenant ID used by the protected applications.')
param tenantId string

var openIdIssuer = '${environment().authentication.loginEndpoint}${tenantId}/v2.0'

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: planName
  location: location
  tags: tags
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    capacity: 1
  }
  properties: {
    reserved: false
  }
}

resource frontendApp 'Microsoft.Web/sites@2024-04-01' = {
  name: frontendAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    clientAffinityEnabled: false
    httpsOnly: true
    keyVaultReferenceIdentity: 'SystemAssigned'
    serverFarmId: appServicePlan.id
    siteConfig: {
      alwaysOn: false
      appSettings: [
        {
          name: 'KEY_VAULT_URI'
          value: keyVaultUri
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
      ]
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      vnetRouteAllEnabled: true
    }
    virtualNetworkSubnetId: subnetId
  }
}

resource backendApp 'Microsoft.Web/sites@2024-04-01' = {
  name: backendAppName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    clientAffinityEnabled: false
    httpsOnly: true
    keyVaultReferenceIdentity: 'SystemAssigned'
    serverFarmId: appServicePlan.id
    siteConfig: {
      alwaysOn: false
      appSettings: [
        {
          name: 'KEY_VAULT_URI'
          value: keyVaultUri
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
      ]
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      vnetRouteAllEnabled: true
    }
    virtualNetworkSubnetId: subnetId
  }
}

resource frontendAuth 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: frontendApp
  name: 'authsettingsV2'
  properties: {
    globalValidation: {
      redirectToProvider: 'AzureActiveDirectory'
      requireAuthentication: true
      unauthenticatedClientAction: 'RedirectToLoginPage'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          clientId: frontendClientId
          openIdIssuer: openIdIssuer
        }
        validation: {
          allowedAudiences: [
            frontendClientId
          ]
        }
      }
    }
    login: {
      tokenStore: {
        enabled: true
      }
    }
    platform: {
      enabled: true
    }
  }
}

resource backendAuth 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: backendApp
  name: 'authsettingsV2'
  properties: {
    globalValidation: {
      redirectToProvider: 'AzureActiveDirectory'
      requireAuthentication: true
      unauthenticatedClientAction: 'Return401'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          clientId: backendClientId
          openIdIssuer: openIdIssuer
        }
        validation: {
          allowedAudiences: [
            backendClientId
          ]
        }
      }
    }
    login: {
      tokenStore: {
        enabled: true
      }
    }
    platform: {
      enabled: true
    }
  }
}

resource frontendDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${frontendApp.name}-diag'
  scope: frontendApp
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

resource backendDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${backendApp.name}-diag'
  scope: backendApp
  properties: {
    workspaceId: logAnalyticsWorkspaceId
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

@description('Resource ID of the App Service plan.')
output appServicePlanId string = appServicePlan.id

@description('Resource ID of the frontend web app.')
output frontendAppId string = frontendApp.id

@description('Resource ID of the backend web app.')
output backendAppId string = backendApp.id

@description('System-assigned managed identity principal ID for the frontend web app.')
output frontendPrincipalId string = frontendApp.identity.principalId

@description('System-assigned managed identity principal ID for the backend web app.')
output backendPrincipalId string = backendApp.identity.principalId
