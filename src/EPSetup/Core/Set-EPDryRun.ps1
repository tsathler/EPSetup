# ============================================================================
#
# EPSetup - Dry Run
#
# Controla o modo de simulacao da execucao
#
# ============================================================================

$script:EPDryRun = $false

function Set-EPDryRun {

    param(
        [Parameter(Mandatory = $true)]
        [bool]$Enabled
    )

    $script:EPDryRun = $Enabled

    $state = if ($Enabled) { "ativado" } else { "desativado" }

    Write-EPSetupLog `
        -Message "Modo Dry Run $state." `
        -Level "WARNING"
}


function Test-EPDryRun {

    return [bool]$script:EPDryRun
}


function Get-EPDryRunStatus {

    if (Test-EPDryRun) {
        return "Ativado"
    }

    return "Desativado"
}
