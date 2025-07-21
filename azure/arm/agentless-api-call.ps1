function Set-AzureAgentlessOptions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Guid[]]$Subscriptions,
        [Parameter(Mandatory)]
        [string]$DatadogSite,
        [Parameter(Mandatory, HelpMessage = "Datadog API Key")]
        [ValidatePattern("^[0-9a-f]{32}$")]
        [string]$APIKey,
        [Parameter(Mandatory, HelpMessage = "Datadog Application Key")]
        [ValidatePattern("^[0-9a-f]{40}$")]
        [string]$ApplicationKey
    )
    begin {
        $url = "https://api.${DatadogSite}/api/v2/agentless_scanning/accounts/azure"
        $headers = @{
            "Content-Type"       = "application/vnd.api+json"
            "DD-API-KEY"         = $APIKey
            "DD-APPLICATION-KEY" = $ApplicationKey
            "Dd-Call-Source"     = "arm-agentless"
        }
    }
    process {
        $subscription_id = $_.ToString()
        $body = @{
            "data" = @{
                "id"         = $subscription_id
                "type"       = "azure_scan_options"
                "attributes" = @{
                    "vuln_containers_os" = $true
                    "vuln_host_os"       = $true
                }
            }
        } | ConvertTo-Json

        $result = Invoke-RestMethod -Method POST -Uri $url -Headers $headers -Body $body -SkipHttpErrorCheck -StatusCodeVariable status
        if ($status -eq 409) {
            # Subscription already exists; update it instead
            $result = Invoke-RestMethod -Method PATCH -Uri "${url}/${subscription_id}" -Headers $headers -Body $body -SkipHttpErrorCheck -StatusCodeVariable status
        }
        if ($status -ge 200 -and $status -lt 300) {
            Write-Output "Successfully enabled Agentless Scanning for subscription ${subscription_id}"
        }
        else {
            Write-Error "Failed to enable Agentless Scanning for subscription ${subscription_id}: $(ConvertTo-Json -Compress $result)"
        }
    }
}

function Convert-ScopeToSubscriptionId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$Scopes
    )
    process {
        $scope = $_.Trim()
        if ($scope -match '^/subscriptions/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})(/|$)') {
            return $Matches[1]
        }
        Write-Warning "Ignoring scope: $scope"
    }
}

${env:SCAN_SCOPES} |
ConvertFrom-Json |
Convert-ScopeToSubscriptionId |
Sort-Object |
Get-Unique |
Set-AzureAgentlessOptions -APIKey ${env:DD_API_KEY} -ApplicationKey ${env:DD_APP_KEY} -DatadogSite ${env:DD_SITE}
