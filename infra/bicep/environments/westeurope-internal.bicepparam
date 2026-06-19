using '../main.bicep'

param tenantId = '00000000-0000-0000-0000-000000000000'
param frontendClientId = '11111111-1111-1111-1111-111111111111'
param backendClientId = '22222222-2222-2222-2222-222222222222'

param location = 'westeurope'
param namePrefix = 'teamapp'
param environmentName = 'internal'
param nameSuffix = 'weu01'

param vnetAddressSpace = '10.20.0.0/16'
param integrationSubnetPrefix = '10.20.0.0/24'
param privateEndpointsSubnetPrefix = '10.20.1.0/25'

param sqlAdministratorLogin = 'sqladminuser'
param sqlAdministratorPassword = 'Replace-With-Approved-Secret-Only-At-Deploy-Time!'
param keyVaultPrivateEndpoint = false

param diagnosticRetentionInDays = 30
param monthlyBudgetLimit = 60
param budgetContactEmails = []

param tags = {
  costCenter: 'internal-platform'
  dataClassification: 'internal'
  environment: 'internal'
  owner: 'review-required'
  workload: 'azure-web-app'
}
