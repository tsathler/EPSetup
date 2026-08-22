# ============================================================================
#
# WindowsProvisioningToolkit - Restart State
#
# Registra quando uma operacao exige reinicializacao
#
# ============================================================================

$script:WPTRestartRequired = $false
$script:WPTRestartReasons = @()

function Set-WPTRestartRequired {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    $script:WPTRestartRequired = $true

    if ($script:WPTRestartReasons -notcontains $Reason) {
        $script:WPTRestartReasons += $Reason
    }
}


function Get-WPTRestartState {

    return [pscustomobject]@{
        Required = [bool]$script:WPTRestartRequired
        Reasons = @($script:WPTRestartReasons)
    }
}


function Clear-WPTRestartState {

    $script:WPTRestartRequired = $false
    $script:WPTRestartReasons = @()
}
