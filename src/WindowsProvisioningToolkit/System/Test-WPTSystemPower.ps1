# ============================================================================
#
# WindowsProvisioningToolkit - System Power
#
# Verifica as configuracoes de energia do sistema
#
# ============================================================================


function Test-WPTSystemPowerConfiguration {

    $monitorTimeout =
        powercfg /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE

    $standbyTimeout =
        powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE

    $monitorCorrect =
        $monitorTimeout -match "0x00000000"

    $standbyCorrect =
        $standbyTimeout -match "0x00000000"

    return (
        $monitorCorrect -and
        $standbyCorrect
    )
}
