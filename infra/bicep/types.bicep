metadata name = 'Azure internal web app shared types'
metadata description = 'Exports shared review-oriented types and defaults for the repo-only Azure Bicep artifacts.'

@export()
@description('Deployment naming inputs that reviewers should validate for uniqueness before any live deployment.')
@sealed()
type NamingConfig = {
  @description('Short workload prefix used in resource names.')
  namePrefix: string

  @description('Environment label used in resource names and tags.')
  environmentName: string

  @description('Short suffix used to keep globally unique names deterministic.')
  nameSuffix: string
}

@export()
@description('Microsoft Entra application registration settings for a protected web application.')
@sealed()
type EntraAuthConfig = {
  @description('Microsoft Entra tenant ID.')
  tenantId: string

  @description('Client ID for the application registration.')
  clientId: string
}

@export()
@description('Minimum tag set expected across the repo-only Azure baseline.')
@sealed()
type ResourceTags = {
  @description('Cost center or billing owner for the workload.')
  costCenter: string

  @description('Data classification label for the workload.')
  dataClassification: string

  @description('Environment label for the workload.')
  environment: string

  @description('Owning team or approver alias.')
  owner: string

  @description('Workload label used for governance reviews.')
  workload: string
}

@export()
@description('Default feature toggles for the Azure internal web app baseline.')
var featureDefaults = {
  keyVaultPrivateEndpoint: false
}
