@description('The name of the environment. This must be dev, test, tst or prod.')
@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string = 'dev'

@description('Your SubscriptionId')
param subscriptionId string = subscription().id

@description('Location abbreviation example: East US 2 = eus2')
param location string = resourceGroup().location
param locationabbrev string = 'eus2'

@description('The billing tags.')
param tags object = {
  CapitalProjectName: 'My Project Name'
  CostCenter: '123'
}

@description('The resource group name')
param resourceGroupName string = 'datafactory-rg'

@description('The Vnet name and Id')
param vnetName string = 'Your Vnet Name'
param vnetId string = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vnetName}'

@description('Private endpoint details')
param endpointgroupName string = 'dataFactory'
param dnsgroupzoneName string = 'privatelink.datafactory.azure.net'
param privatednszoneId string = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/privateDnsZones/privatelink.datafactory.azure.net'
param privateendpointName string = 'pe-datafactory-dev'

@description('The resource id of the data factory')
param privatelinkserviceId string = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.DataFactory/factories/${datafactoryName}'

@description('Input your Subnet name at the end of the string')
param subnetId string = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${subnetName}'


// Define variables
var datafactoryName = 'df-${environmentType}-${locationabbrev}'


// Create Datafactory
module datafactory 'modules/datafactory.bicep' = {
  name: 'deploy-datafactory'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    datafactoryName: datafactoryName
    customTags: tags
    version: 'V2'
    vNetEnabled: true 
  }
}

// Create Private DNS Zone
module privatednszone 'modules/dfprivatednszone.bicep' = {
  name: 'deploy-privatednszone'
  scope: resourceGroup('rg-spoke-bicepdemo-vnet-dev-use2')
  params: {
    virtualNetworkName: vnetName
    tags: tags
    privateDnsZoneName: dnsgroupzoneName
    vnetId: vnetId
  }
}

// Create Private Endpoint
module dfprivateendpoint 'modules/pe.bicep' = {
  name: 'dfprivateendpoint'
  scope: resourceGroup(resourceGroupName)
  params: {
    tags: tags
    location: location
    privateEndpointGroupName: endpointgroupName
    pednszonegroupconfigName: dnsgroupzoneName 
    privatednszoneId: privatednszoneId
    privateEndpointName: privateendpointName
    privateLinkServiceId: privatelinkserviceId
    subnetId: subnetId
  }
  dependsOn: [
    datafactory
  ]
}

//outputs
output datafactory object = datafactory.outputs.dataFactory
output privatednszone object = privatednszone.outputs.privatednszones
output virtualnetworkLinks object = privatednszone.outputs.virtualnetworklinks
output privateendpoint object = dfprivateendpoint.outputs.privateendpoints






