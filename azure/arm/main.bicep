@description('''
A Remote Configuration-enabled API key for the Datadog account
(see https://app.datadoghq.com/organization-settings/api-keys).
''')
@secure()
param datadogAPIKey string

@secure()
@description('''
[Optional] A Datadog application key. If provided, it will be used to
automatically enable Agentless Scanning on the selected subscriptions.
''')
param datadogAppKey string = ''

@description('The Datadog site to use for the Datadog Agentless Scanner')
@allowed([
  'datadoghq.com'
  'datadoghq.eu'
  'us3.datadoghq.com'
  'us5.datadoghq.com'
  'ap1.datadoghq.com'
  'ap2.datadoghq.com'
  'datad0g.com'
])
param datadogSite string = 'datadoghq.com'

@description('Number of Agentless Scanner instances to launch')
param instanceCount int = 1

@description('Virtual Machine instance size')
param instanceSize string = 'Standard_B2ps_v2'

@description('The name of the user-assigned managed identity to be used by the Datadog Agentless Scanner virtual machine instances.')
param identityName string = 'DatatogAgentlessScannerIdentity'

@description('Prefix to use for custom role names. Used to create role definitions.')
param roleNamePrefix string = 'Datadog Agentless Scanner'

@description('The set of scopes that the Datadog Agentless Scanner is allowed to scan')
param scanScopes string[] = [subscription().id]

@description('Specifies the version of the scanner to install')
param scannerVersion string = '0.11'

@description('Specifies the channel to use for installing the scanner')
@allowed([
  'stable'
  'beta'
  'nightly'
])
param scannerChannel string = 'stable'

@description('Repository URL to install the scanner from.')
param scannerRepository string = 'https://apt.datadoghq.com/'

@description('The administrator username for the VM')
param adminUsername string = 'azureuser'

@description('SSH public key of the administrator user')
param sshPublicKey string?
// HACK
// Azure requires a password or a valid SSH public key to be provided, and it is not possible to
// create an SSH public key using Azure Resource Manager alone.
// We don't want to ask for a public key because there is rarely any reason to connect to the VMs.
// As a workaround, we supply a valid key by default but remove it on first boot.
// Thanks, Microsoft.
var sshMockPublicKey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJWFDAB+VRKsHvHjIyiEN9izvhaosXAUMG1jPMo9hcnE'
var sshAuthorizedKeysFile = '/home/${adminUsername}/.ssh/authorized_keys'

@description('Tags to apply to all resources.')
param resourceTags object = {}

var tags = union(resourceTags, {
  Datadog: 'true'
  DatadogAgentlessScanner: 'true'
})
var name = 'DatatogAgentlessScanner'

// Virtual machine scale set
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: name
  location: resourceGroup().location
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
    orchestrationMode: 'Uniform'
    upgradePolicy: { mode: 'Automatic' }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'agentless-scanning-'
        adminUsername: adminUsername
        customData: base64(customData)
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: sshAuthorizedKeysFile
                keyData: sshPublicKey ?? sshMockPublicKey
              }
            ]
          }
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
          diskSizeGB: 30
        }
        imageReference: {
          publisher: 'canonical'
          offer: 'ubuntu-24_04-lts'
          sku: 'minimal-arm64'
          version: 'latest'
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic'
            properties: {
              primary: true
              enableAcceleratedNetworking: false
              //disableTcpStateTracking: false
              //enableIPForwarding: false
              ipConfigurations: [
                {
                  name: 'ipconfig'
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
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
      extensionProfile: {
        extensions: [
          {
            name: 'HealthExtension'
            properties: {
              publisher: 'Microsoft.ManagedServices'
              type: 'ApplicationHealthLinux'
              typeHandlerVersion: '2.0'
              settings: {
                protocol: 'http'
                port: 6253
                requestPath: '/health'
                intervalInSeconds: 10
                numberOfProbes: 3
                gracePeriod: 1200
              }
            }
          }
        ]
      }
    }
    automaticRepairsPolicy: {
      enabled: true
      gracePeriod: 'PT10M'
    }
  }
}

// Generate a random number from a GUID by removing the letters/hyphens and taking the first 9 digits (to avoid overflow)
var restartMinute = int(substring(join(split(guid(vmss.id), ['a', 'b', 'c', 'd', 'e', 'f', '-']), ''), 0, 9)) % (24 * 60)
resource autoscaleSetting 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: '${vmss.name}-Autoscale'
  location: resourceGroup().location
  tags: tags
  properties: {
    name: '${vmss.name}-Autoscale'
    enabled: true
    targetResourceUri: vmss.id
    targetResourceLocation: vmss.location
    profiles: [
      {
        name: 'Terminate all instances'
        capacity: {
          default: '0'
          maximum: '0'
          minimum: '0'
        }
        rules: []
        recurrence: {
          frequency: 'Week'
          schedule: {
            days: [
              'Monday'
              'Tuesday'
              'Wednesday'
              'Thursday'
              'Friday'
              'Saturday'
              'Sunday'
            ]
            hours: [restartMinute / 60]
            minutes: [restartMinute % 60]
            timeZone: 'UTC'
          }
        }
      }
      {
        name: '{"name":"Auto created default scale condition","for":"Terminate all instances"}'
        capacity: {
          default: '${instanceCount}'
          maximum: '${instanceCount}'
          minimum: '${instanceCount}'
        }
        rules: []
        recurrence: {
          frequency: 'Week'
          schedule: {
            days: [
              'Monday'
              'Tuesday'
              'Wednesday'
              'Thursday'
              'Friday'
              'Saturday'
              'Sunday'
            ]
            hours: [(restartMinute + 1) / 60 % 24]
            minutes: [(restartMinute + 1) % 60]
            timeZone: 'UTC'
          }
        }
      }
    ]
  }
}

// VM identity and roles
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: resourceGroup().location
  tags: tags
}

resource scannerRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(name, 'scannerRole', resourceGroup().id, subscription().id)
  properties: {
    roleName: '${roleNamePrefix} Orchestrator Role'
    description: 'Role used by the Datadog Agentless Scanner to manage resources in its own resource group.'
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
    assignableScopes: [resourceGroup().id]
  }
}

resource delegateRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(name, 'delegateRole', resourceGroup().id, subscription().id)
  properties: {
    roleName: '${roleNamePrefix} Worker Role'
    description: 'Role used by the Datadog Agentless Scanner to scan resources.'
    type: 'customRole'
    permissions: [
      {
        actions: [
          'Microsoft.Compute/virtualMachines/read'
          'Microsoft.Compute/virtualMachines/instanceView/read'
          'Microsoft.Compute/virtualMachineScaleSets/read'
          'Microsoft.Compute/virtualMachineScaleSets/instanceView/read'
          'Microsoft.Compute/virtualMachineScaleSets/virtualMachines/read'
          'Microsoft.Compute/virtualMachineScaleSets/virtualMachines/instanceView/read'

          'Microsoft.Compute/disks/read'
          'Microsoft.Compute/disks/beginGetAccess/action'
          'Microsoft.Compute/disks/endGetAccess/action'

          'Microsoft.ContainerRegistry/registries/pull/read'
        ]
        notActions: []
      }
    ]
    assignableScopes: union([resourceGroup().id], scanScopes)
  }
}

resource scannerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(scannerRole.id, managedIdentity.id)
  properties: {
    roleDefinitionId: scannerRole.id
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

module delegateRoleAssignments './delegateRoleAssignment.bicep' = [
  for subscriptionId in map(
    filter(scanScopes, s => startsWith(s, '/subscriptions/')),
    s => skip(s, length('/subscriptions/'))
  ): {
    name: 'delegateRoleAssignment-${guid(delegateRole.id, managedIdentity.id, subscriptionId)}'
    scope: subscription(subscriptionId)
    params: {
      name: guid(delegateRole.id, managedIdentity.id, subscriptionId)
      roleDefinitionId: delegateRole.id
      principalId: managedIdentity.properties.principalId
    }
  }
]

// Network resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: 'vnet'
  location: resourceGroup().location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefixes: ['10.0.128.0/19']
          //networkSecurityGroup: { id: networkSecurityGroup.id }
          natGateway: { id: natGateway.id }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [resourceGroup().location]
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

resource natGateway 'Microsoft.Network/natGateways@2024-03-01' = {
  name: 'natgw'
  location: resourceGroup().location
  tags: tags
  sku: { name: 'Standard' }
  properties: {
    publicIpAddresses: [{ id: publicIpAddress.id }]
  }
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2024-03-01' = {
  name: 'natgw-ip'
  location: resourceGroup().location
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

// Call the Datadog API to enable Agentless Scanning on the selected subscription
@description('[Internal: do not change] Tag to force an update to the Datadog Agentless Scanning options.')
param _forceUpdateTag string = utcNow()
resource ddApiCall 'Microsoft.Resources/deploymentScripts@2023-08-01' = if (datadogAppKey != '') {
  name: '${name}-ApiCall'
  location: resourceGroup().location
  tags: tags
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '12.3'
    environmentVariables: [
      { name: 'DD_API_KEY', secureValue: datadogAPIKey }
      { name: 'DD_APP_KEY', secureValue: datadogAppKey }
      { name: 'DD_SITE', value: datadogSite }
      { name: 'SCAN_SCOPES', value: string(scanScopes) }
      { name: 'NO_COLOR', value: 'true' }
    ]
    forceUpdateTag: _forceUpdateTag
    scriptContent: loadTextContent('./agentless-api-call.ps1')
    retentionInterval: 'P1D'
    timeout: 'PT10M'
    cleanupPreference: 'OnExpiration'
  }
}

var customData = replaceMultiple(loadTextContent('./install.sh'), {
  '\${api_key}': datadogAPIKey
  '\${site}': datadogSite
  '\${scanner_version}': scannerVersion
  '\${scanner_channel}': scannerChannel
  '\${scanner_repository}': scannerRepository
  '\${azure_client_id}': managedIdentity.properties.clientId
  // HACK
  '\${ssh_mock_public_key}': sshMockPublicKey
  '\${ssh_authorized_keys_file}': sshAuthorizedKeysFile
})

func replaceMultiple(input string, replacements { *: string }) string =>
  reduce(items(replacements), input, (cur, next) => replace(string(cur), next.key, next.value))
