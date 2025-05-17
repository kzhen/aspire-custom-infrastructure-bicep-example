@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

@description('The name of the Health Data Services workspace to be deployed.')
param name string

@description('The name of the storage account where FHIR Server events should be sent to.')
param storageAccountName string = ''

@description('The name of the storage account queue that should be sent events.')
param storageAccountQueueName string = 'fhir'

var workspaceName = take('${name}${uniqueString(resourceGroup().id)}', 24)
var fhirServerName = 'fvr'
var authority = '${environment().authentication.loginEndpoint}${tenant().tenantId}'
var audience = 'https://${workspaceName}-${fhirServerName}.fhir.azurehealthcareapis.com'

// Create an Azure Health Data Services workspace
resource workspace 'Microsoft.HealthcareApis/workspaces@2024-03-31' = {
  name: workspaceName
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// Create FHIR Server
resource fhirServer 'Microsoft.HealthcareApis/workspaces/fhirservices@2024-03-31' = {
  parent: workspace
  name: fhirServerName
  location: location
  kind: 'fhir-R4'
  identity: { type: 'None' }
  properties: {
    authenticationConfiguration: {
      authority: authority
      audience: audience
      smartIdentityProviders: []
      smartProxyEnabled: false
    }
    publicNetworkAccess: 'Enabled'
  }
}


// Create a new a storage queue in the storage account - this should be done in Aspire...however that currently doesn't work
resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: storageAccountName
}

resource qs 'Microsoft.Storage/storageAccounts/queueServices@2024-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource fhirQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2024-01-01' = {
  name: storageAccountQueueName
  parent: qs
}

// Create event grid system topic and subscription for FhirResource events
resource fhirEventsSystemTopic 'Microsoft.EventGrid/systemTopics@2025-02-15' = {
  name: 'fhir-service-events'
  location: 'uksouth'
  properties: {
    source: workspace.id
    topicType: 'Microsoft.HealthcareApis.Workspaces'
  }
}

resource eventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2025-02-15' = {
  parent: fhirEventsSystemTopic
  name: 'test1'
  properties: {
    destination: {
      properties: {
        resourceId: storageAccount.id
        queueName: storageAccountQueueName
        queueMessageTimeToLiveInSeconds: 604800
      }
      endpointType: 'StorageQueue'
    }
    filter: {
      includedEventTypes: [
        'Microsoft.HealthcareApis.FhirResourceCreated'
        'Microsoft.HealthcareApis.FhirResourceUpdated'
        'Microsoft.HealthcareApis.FhirResourceDeleted'
      ]
      enableAdvancedFilteringOnArrays: true
    }
    labels: []
    eventDeliverySchema: 'CloudEventSchemaV1_0'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}


output fhirServerUrl string = 'https://${workspaceName}-${fhirServerName}.fhir.azurehealthcareapis.com/'
output audience string = audience
output storageAccountName string = storageAccountName
