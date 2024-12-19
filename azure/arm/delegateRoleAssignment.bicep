targetScope = 'subscription'

param name string
param roleDefinitionId string
param principalId string

resource delegateRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: name
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
