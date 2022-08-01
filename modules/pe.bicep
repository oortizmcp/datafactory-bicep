param location string
param tags object
param subnetId string

@description('Specifies the name of the private link to the sql.')
param privateEndpointName string
param privateEndpointGroupName string
param privateLinkServiceId string
param privatednszoneId string
param pednszonegroupconfigName string



resource privateEndpointName_resource 'Microsoft.Network/privateEndpoints@2020-05-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            privateEndpointGroupName
          ]
          privateLinkServiceConnectionState: {
             status: 'Approved'
             description: 'Auto-approved'
             actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource pednszonegroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: privateEndpointName_resource
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: pednszonegroupconfigName
        properties: {
          privateDnsZoneId: privatednszoneId
        }
      }
    ]
  }
}



output privateendpoints object = reference(privateEndpointName_resource.id, '2020-05-01', 'full')
