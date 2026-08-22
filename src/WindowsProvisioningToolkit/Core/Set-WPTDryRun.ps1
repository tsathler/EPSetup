# ============================================================================
#
# WindowsProvisioningToolkit - Dry Run
#
# Controla o modo de simulacao da execucao
#
# ============================================================================

$script:WPTDryRun = $false

function Set-WPTDryRun {

    param(
        [Parameter(Mandatory = $true)]
        [bool]$Enabled
    )

    $script:WPTDryRun = $Enabled

    $state = if ($Enabled) { "ativado" } else { "desativado" }

    Write-WPTLog `
        -Message "Modo Dry Run $state." `
        -Level "WARNING"
}


function Test-WPTDryRun {

    return [bool]$script:WPTDryRun
}


function Get-WPTDryRunStatus {

    if (Test-WPTDryRun) {
        return "Ativado"
    }

    return "Desativado"
}
