function ConvertTo-AzureSubscriptionId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$Scopes
    )
    process {
        # try {
        #     return [Azure.Core.ResourceIdentifier]::Parse($_).SubscriptionId
        # }
        # catch {}

        $scope = $_.Trim()
        if ($scope -notmatch '^/subscriptions/([a-f0-9-]{36})(/|$)') {
            Write-Warning "Ignoring scope: $scope"
            return
        }

        $subscription_id = New-Guid -Empty
        if (-not [System.Guid]::TryParseExact($Matches[1], "D", [ref]$subscription_id)) {
            Write-Warning "Ignoring Azure subscription ID: ${Matches[1]}"
            return
        }

        return $subscription_id
    }
}

function Set-AzureAgentlessOptions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Guid[]]$Subscriptions,
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
        $headers = @{
            'DD-API-KEY'         = $DD_API_KEY
            'DD-APPLICATION-KEY' = $DD_APP_KEY
            'Dd-Call-Source'     = "arm-agentless"
        }
    }
    process {
        $subscription_id = $_.ToString("D")
        $url = "https://api.${DD_SITE}/api/v2/agentless_scanning/accounts/azure"
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

        Write-Host "POST ${url}`n$(ConvertTo-Json $headers)"

        Invoke-RestMethod -Method POST -uri $url -Headers $headers -Body $body
    }
}

${env:SCAN_SCOPES} |
ConvertFrom-Json -NoEnumerate |
ConvertTo-AzureSubscriptionId |
Sort-Object |
Get-Unique |
Set-AzureAgentlessOptions -DatadogSite ${env:DD_SITE} -APIKey ${env:DD_API_KEY} -ApplicationKey ${env:DD_APP_KEY}
