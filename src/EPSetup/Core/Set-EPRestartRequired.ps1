# ============================================================================
#
# EPSetup - Restart State
#
# Registra quando uma operacao exige reinicializacao
#
# ============================================================================

$script:EPRestartRequired = $false
$script:EPRestartReasons = @()

function Set-EPRestartRequired {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    $script:EPRestartRequired = $true

    if ($script:EPRestartReasons -notcontains $Reason) {
        $script:EPRestartReasons += $Reason
    }
}


function Get-EPRestartState {

    return [pscustomobject]@{
        Required = [bool]$script:EPRestartRequired
        Reasons = @($script:EPRestartReasons)
    }
}


function Clear-EPRestartState {

    $script:EPRestartRequired = $false
    $script:EPRestartReasons = @()
}
