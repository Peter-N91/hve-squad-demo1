metadata name = 'Azure internal web app baseline'
metadata description = 'Orchestrates the repo-only Azure IaC artifacts for the approved West Europe internal web app shape.'

targetScope = 'resourceGroup'

/* Identity parameters */

@description('Microsoft Entra tenant ID used by the protected frontend and backend applications.')
param tenantId string

@description('Client ID for the frontend Microsoft Entra application registration.')
param frontendClientId string

@description('Client ID for the backend Microsoft Entra application registration.')
param backendClientId string

/* Networking parameters */

@description('Azure region for all regional resources.')
param location string = 'westeurope'

@description('Short workload prefix used in resource names.')
@minLength(2)
param namePrefix string

@description('Environment label used in resource names and tags.')
param environmentName string = 'internal'

@description('Short suffix used to keep globally unique names reviewable and deterministic.')
@minLength(2)
param nameSuffix string

@description('Address space for the shared virtual network.')
param vnetAddressSpace string = '10.20.0.0/16'

@description('Address prefix for the App Service integration subnet.')
param integrationSubnetPrefix string = '10.20.0.0/24'

@description('Address prefix for the private endpoints subnet.')
param privateEndpointsSubnetPrefix string = '10.20.1.0/25'

/* Data and security parameters */

@description('SQL administrator login used for the initial logical server configuration.')
param sqlAdministratorLogin string

@secure()
@description('SQL administrator password used for the initial logical server configuration.')
param sqlAdministratorPassword string

@description('When true, the Key Vault module adds a private endpoint. Public network access remains disabled in the approved baseline.')
param keyVaultPrivateEndpoint bool = false

/* Monitoring and governance parameters */

@description('Retention period, in days, for Log Analytics data.')
@minValue(30)
param diagnosticRetentionInDays int = 30

@description('Monthly subscription budget ceiling in the local billing currency.')
@minValue(1)
param monthlyBudgetLimit int = 60

@description('Email recipients for budget notifications when a reviewer wants explicit contacts instead of role-based alerts.')
param budgetContactEmails array = []

@description('Tags applied to all supported resources created by this template.')
param tags object = {
  costCenter: 'internal-platform'
  dataClassification: 'internal'
  environment: 'internal'
  owner: 'team-identity-required'
  workload: 'azure-web-app'
}

var compactName = toLower(replace('${namePrefix}${environmentName}${nameSuffix}', '-', ''))
var appServicePlanName = take('asp-${namePrefix}-${environmentName}-${nameSuffix}', 40)
var backendAppName = take('app-${namePrefix}-${environmentName}-${nameSuffix}-be', 60)
var frontendAppName = take('app-${namePrefix}-${environmentName}-${nameSuffix}-fe', 60)
var keyVaultName = take('kv-${namePrefix}-${environmentName}-${nameSuffix}', 24)
var logAnalyticsName = take('log-${namePrefix}-${environmentName}-${nameSuffix}', 63)
var sqlDatabaseName = take('sqldb-${namePrefix}-${environmentName}', 128)
var sqlServerName = take('sql-${namePrefix}-${environmentName}-${nameSuffix}', 63)
var storageAccountName = take('st${compactName}', 24)
var vnetName = take('vnet-${namePrefix}-${environmentName}-${nameSuffix}', 64)
var privateDnsZoneNames = {
  keyVault: 'privatelink${environment().suffixes.keyvaultDns}'
  sql: 'privatelink.database${environment().suffixes.sqlServerHostname}'
  storageBlob: 'privatelink.blob.${environment().suffixes.storage}'
}

module monitoring './modules/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    diagnosticRetentionInDays: diagnosticRetentionInDays
    location: location
    logAnalyticsWorkspaceName: logAnalyticsName
    tags: tags
  }
}

module networking './modules/networking.bicep' = {
  name: 'networking'
  params: {
    integrationSubnetPrefix: integrationSubnetPrefix
    location: location
    privateDnsZoneNames: privateDnsZoneNames
    privateEndpointsSubnetPrefix: privateEndpointsSubnetPrefix
    tags: tags
    vnetAddressSpace: vnetAddressSpace
    vnetName: vnetName
    workspaceId: monitoring.outputs.workspaceId
  }
}

module appService './modules/app-service.bicep' = {
  name: 'app-service'
  params: {
    backendAppName: backendAppName
    backendClientId: backendClientId
    frontendAppName: frontendAppName
    frontendClientId: frontendClientId
    keyVaultUri: keyVault.outputs.vaultUri
    location: location
    logAnalyticsWorkspaceId: monitoring.outputs.workspaceId
    planName: appServicePlanName
    subnetId: networking.outputs.integrationSubnetId
    tags: tags
    tenantId: tenantId
  }
}

module sql './modules/sql.bicep' = {
  name: 'sql'
  params: {
    databaseName: sqlDatabaseName
    location: location
    privateDnsZoneId: networking.outputs.sqlPrivateDnsZoneId
    privateEndpointSubnetId: networking.outputs.privateEndpointsSubnetId
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorPassword: sqlAdministratorPassword
    sqlServerName: sqlServerName
    tags: tags
    workspaceId: monitoring.outputs.workspaceId
  }
}

module storage './modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    privateDnsZoneId: networking.outputs.storagePrivateDnsZoneId
    privateEndpointSubnetId: networking.outputs.privateEndpointsSubnetId
    storageAccountName: storageAccountName
    tags: tags
    workspaceId: monitoring.outputs.workspaceId
  }
}

module keyVault './modules/key-vault.bicep' = {
  name: 'key-vault'
  params: {
    keyVaultName: keyVaultName
    location: location
    privateDnsZoneId: networking.outputs.keyVaultPrivateDnsZoneId
    privateEndpointSubnetId: networking.outputs.privateEndpointsSubnetId
    shouldUsePrivateEndpoint: keyVaultPrivateEndpoint
    tags: tags
    tenantId: tenantId
    workspaceId: monitoring.outputs.workspaceId
  }
}

module governance './modules/governance.bicep' = {
  name: 'governance'
  scope: subscription()
  params: {
    budgetContactEmails: budgetContactEmails
    budgetName: take('budget-${namePrefix}-${environmentName}', 63)
    monthlyBudgetLimit: monthlyBudgetLimit
    tags: tags
  }
}

resource resourceGroupLock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: '${resourceGroup().name}-cannot-delete'
  properties: {
    level: 'CanNotDelete'
    notes: 'Applied by the repo-only governance baseline after reviewer approval.'
  }
}

@description('Review-focused naming summary for the approved deployment shape.')
output naming object = {
  appServicePlanName: appServicePlanName
  backendAppName: backendAppName
  frontendAppName: frontendAppName
  keyVaultName: keyVaultName
  logAnalyticsName: logAnalyticsName
  sqlDatabaseName: sqlDatabaseName
  sqlServerName: sqlServerName
  storageAccountName: storageAccountName
  vnetName: vnetName
}

@description('Key resource IDs emitted for review and later deployment wiring.')
output resourceIds object = {
  backendAppId: appService.outputs.backendAppId
  frontendAppId: appService.outputs.frontendAppId
  keyVaultId: keyVault.outputs.vaultId
  logAnalyticsWorkspaceId: monitoring.outputs.workspaceId
  sqlDatabaseId: sql.outputs.databaseId
  sqlServerId: sql.outputs.serverId
  storageAccountId: storage.outputs.storageAccountId
  vnetId: networking.outputs.vnetId
}

@description('Review notes for policy-sensitive or out-of-scope configuration items.')
output reviewNotes object = {
  budgetScope: 'Subscription budget and resource-group lock are modeled only as template resources. Reviewers must decide when to deploy them.'
  keyVaultPrivateEndpoint: keyVaultPrivateEndpoint
  resourceGroupLockName: resourceGroupLock.name
  outOfScope: [
    'Azure login'
    'Deployment execution'
    'Secret population'
    'RBAC approval workflows'
  ]
}
