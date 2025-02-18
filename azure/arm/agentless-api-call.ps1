function ConvertTo-AzureSubscriptionId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$Scopes
    )
    process {
        $scope = $_.Trim()
        Write-Debug "Scope: ${scope}"

        try {
            Write-Debug [Azure.Core.ResourceIdentifier]::Parse($_).SubscriptionId
        }
        catch {}

        if ($scope -notmatch '^/subscriptions/([a-f0-9-]{36})(/|$)') {
            Write-Warning "Ignoring scope: $scope"
            return
        }

        $subscription_id = New-Guid -Empty
        if (-not [System.Guid]::TryParseExact($Matches[1], "D", [ref]$subscription_id)) {
            Write-Warning "Ignoring Azure subscription ID: ${Matches[1]}"
            return
        }

        return $subscription_id.ToString("D")
    }
}

function Set-AzureAgentlessOptions {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$Subscriptions,
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
            'DD-API-KEY'         = $APIKey
            'DD-APPLICATION-KEY' = $ApplicationKey
            'Dd-Call-Source'     = "arm-agentless"
        }
    }
    process {
        $subscription_id = $_
        $url = "https://api.${DatadogSite}/api/v2/agentless_scanning/accounts/azure"
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

        Write-Debug "POST ${url}`n${body}"

        $result = Invoke-RestMethod -Method POST -Uri $url -Headers $headers -Body $body -SkipHttpErrorCheck -StatusCodeVariable status
        if ($status -eq 409) {
            $result = Invoke-RestMethod -Method PATCH -Uri "${url}/${subscription_id}" -Headers $headers -Body $body -SkipHttpErrorCheck -StatusCodeVariable status
        }
        if ($status -ge 200 -and $status -lt 300) {
            Write-Information "Successfully enabled Agentless Scanning for subscription ${subscription_id}"
        }
        else {
            Write-Error "Failed to enable Agentless Scanning for subscription ${subscription_id}: $(ConvertTo-Json -Compress $result)"
        }
    }
}

$InformationPreference = 'Continue'
$DebugPreference = 'Continue'

${env:SCAN_SCOPES} |
ConvertFrom-Json |
ConvertTo-AzureSubscriptionId |
Sort-Object |
Get-Unique |
Set-AzureAgentlessOptions -DatadogSite ${env:DD_SITE} -APIKey ${env:DD_API_KEY} -ApplicationKey ${env:DD_APP_KEY}
