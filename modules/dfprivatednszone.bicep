param virtualNetworkName string
param tags object
param privateDnsZoneName string
param vnetId string

@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'



resource privateDnsZoneName_resource 'Microsoft.Network/privateDnsZones@2018-09-01' = if (newOrExisting == 'new') {
  tags: tags
  name: privateDnsZoneName
  location: 'global'
  dependsOn: []
}

resource privateDnsZoneName_link_to_virtualNetworkName 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = if (newOrExisting == 'new') {
  parent: privateDnsZoneName_resource
  tags: tags
  name: 'link_to_${toLower(virtualNetworkName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

output privatednszones object = reference(privateDnsZoneName_resource.id, '2018-09-01', 'full')
output virtualnetworklinks object = reference(privateDnsZoneName_link_to_virtualNetworkName.id, '2018-09-01', 'full')
