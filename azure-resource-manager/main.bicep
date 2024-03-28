@secure()
param datadogAPIKey string = ''
param datadogSite string = 'datad0g.com'

param adminUsername string = 'azureuser'

param customData string = replace(replace(loadTextContent('./customData.sh.jinja'),
    '{{ DD_API_KEY }}', datadogAPIKey),
  '{{ DD_SITE }}', datadogSite)

@description('Azure region for the deployment, resource group and resources.')
param location string = resourceGroup().location

param instanceCount int = 1
param instanceSize string = 'Standard_B2ps_v2'

param name string = 'DatatogAgentlessScanner'

@description('Tags to apply to all resources.')
param tags object = {
  Datadog: 'true'
  DatadogAgentlessScanner: 'true'
}

param sshPublicKey string

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-03-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  sku: {
    name: instanceSize
    capacity: instanceCount
  }
  properties: {
    orchestrationMode: 'Flexible'
    platformFaultDomainCount: 1
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'dd-agentless-'
        adminUsername: adminUsername
        customData: base64(customData)
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: startsWith(sshPublicKey, 'ssh-rsa ') ? sshPublicKey : startsWith(sshPublicKey, '/subscriptions/') ? reference(sshPublicKey, '2023-03-01').publicKey : reference(resourceId('Microsoft.Compute/sshPublicKeys', sshPublicKey), '2023-03-01').publicKey
              }
            ]
          }
          provisionVMAgent: true
          patchSettings: {
            patchMode: 'ImageDefault'
            assessmentMode: 'ImageDefault'
          }
          enableVMAgentPlatformUpdates: false
        }
      }
      storageProfile: {
        osDisk: {
          osType: 'Linux'
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          deleteOption: 'Delete'
          diskSizeGB: 30
        }
        imageReference: {
          publisher: 'canonical'
          offer: '0001-com-ubuntu-server-jammy'
          sku: '22_04-lts-arm64'
          version: 'latest'
        }
        diskControllerType: 'SCSI'
      }
      networkProfile: {
        networkApiVersion: '2020-11-01'
        networkInterfaceConfigurations: [ {
            name: '${name}-nic'
            properties: {
              enableAcceleratedNetworking: false
              //disableTcpStateTracking: false
              //enableIPForwarding: false
              deleteOption: 'Delete'
              ipConfigurations: [
                {
                  name: '${name}-nic-defaultIpConfiguration'
                  properties: {
                    privateIPAddressVersion: 'IPv4'
                    subnet: {
                      id: '${virtualNetwork.id}/subnets/default'
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}

// VM identity and roles
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(roleDefinition.id, managedIdentity.id, resourceGroup().id, subscription().id)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(name, resourceGroup().id, subscription().id)
  properties: {
    roleName: 'Datadog Agentless Scanner Role'
    description: 'Role used by the Datadog Agentless Scanner to manage resources in its resource group.'
    type: 'customRole'
    permissions: [
      {
        actions: [
          'Microsoft.Authorization/*/read'
          'Microsoft.Resources/subscriptions/resourceGroups/read'

          'Microsoft.Compute/availabilitySets/*'
          'Microsoft.Compute/locations/*'
          'Microsoft.Compute/virtualMachines/*'
          'Microsoft.Compute/virtualMachineScaleSets/*'

          'Microsoft.Compute/disks/read'
          'Microsoft.Compute/disks/write'
          'Microsoft.Compute/disks/delete'
          'Microsoft.Compute/disks/beginGetAccess/action'
          'Microsoft.Compute/disks/endGetAccess/action'

          'Microsoft.Compute/snapshots/read'
          'Microsoft.Compute/snapshots/write'
          'Microsoft.Compute/snapshots/delete'
          'Microsoft.Compute/snapshots/beginGetAccess/action'
          'Microsoft.Compute/snapshots/endGetAccess/action'

          'Microsoft.Storage/storageAccounts/listkeys/action'
          'Microsoft.Storage/storageAccounts/read'
          'Microsoft.Storage/storageAccounts/write'
          'Microsoft.Storage/storageAccounts/delete'
        ]
        notActions: []
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

// Network resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.0.0.0/16' ]
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefixes: [ '10.0.128.0/19' ]
          //networkSecurityGroup: { id: networkSecurityGroup.id }
          natGateway: { id: natGateway.id }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [ location ]
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: false
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
  }
}

resource natGateway 'Microsoft.Network/natGateways@2023-04-01' = {
  name: name
  location: location
  tags: tags
  sku: { name: 'Standard' }
  properties: {
    publicIpAddresses: [ { id: publicIpAddress.id } ]
  }
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}
