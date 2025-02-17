@description('''
A Remote Configuration-enabled API key for the Datadog account
(see https://app.datadoghq.com/organization-settings/api-keys).
''')
@secure()
param datadogAPIKey string

@secure()
param datadogAppKey string = ''

@description('The Datadog site to use for the Datadog Agentless Scanner')
@allowed([
  'datadoghq.com'
  'datadoghq.eu'
  'us3.datadoghq.com'
  'us5.datadoghq.com'
  'ap1.datadoghq.com'
  'datad0g.com'
])
param datadogSite string = 'datadoghq.com'

@description('Number of Agentless Scanner instances to launch')
param instanceCount int = 1

@description('Virtual Machine instance size')
param instanceSize string = 'Standard_B2ps_v2'

@description('The name of the user-assigned managed identity to be used by the Datadog Agentless Scanner virtual machine instances.')
param identityName string = 'DatatogAgentlessScannerIdentity'

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

resource ddApiCall 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: guid(name, 'ddApiCall', resourceGroup().id, subscription().id)
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
    ]
    scriptContent: loadTextContent('./agentless-api-call.ps1')
    retentionInterval: 'P1D'
    timeout: 'PT10M'
    cleanupPreference: 'OnExpiration'
  }
}
