@description('Data Factory Name')
param datafactoryName string = 'datafactory${uniqueString(resourceGroup().id)}'
param version string
param vNetEnabled bool
param customTags object
param location string

// Create Data Factory
resource datafactoryName_resource 'Microsoft.DataFactory/factories@2018-06-01' = if (version == 'V2') {
  name: datafactoryName
  location: location
  properties: {
    repoConfiguration: json('null')
    publicNetworkAccess: 'Disabled'
    encryption: json('null')
  }
  identity: {
    type: 'SystemAssigned' 
  }
  tags: customTags
}


resource datafactoryName_default 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = if ((version == 'V2') && (vNetEnabled == true)) {
  parent: datafactoryName_resource
  name: 'default'
  properties: {
  }
}

resource datafactoryName_AutoResolveIntegrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if ((version == 'V2') && (vNetEnabled == true)) {
  parent: datafactoryName_resource
  name: 'AutoResolveIntegrationRuntime'
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: 'default'
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
        dataFlowProperties: {
          computeType: 'General'
          coreCount: 8
          timeToLive: 0
        }
      }
    }
  }
  dependsOn: [

    datafactoryName_default
  ]
}

output dataFactory object = reference(datafactoryName_resource.id, '2018-06-01', 'full')
