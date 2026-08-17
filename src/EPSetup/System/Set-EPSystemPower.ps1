# ============================================================================
#
# EPSetup - System Power
#
# Gerencia configuracoes temporarias de energia durante o provisionamento
#
# ============================================================================


$script:OriginalPowerSettings = @{
    MonitorTimeoutAC = $null
    MonitorTimeoutDC = $null
}


function Save-EPSystemPower {

    Write-EPSetupLog `
        -Message "Salvando configuracoes atuais de energia..." `
        -Level "INFO"

    $output = powercfg /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 2>&1

    if ($LASTEXITCODE -ne 0) {
        throw "Nao foi possivel consultar as configuracoes de energia."
    }

    $currentSettings = $output |
        Where-Object {
            $_ -match "Atuais|Current" -and
            $_ -match "0x[0-9a-fA-F]+"
        }

    if ($currentSettings.Count -lt 2) {
        throw "Nao foi possivel identificar os tempos atuais do monitor."
    }

    $acHex = [regex]::Match(
        $currentSettings[0],
        "0x[0-9a-fA-F]+"
    ).Value

    $dcHex = [regex]::Match(
        $currentSettings[1],
        "0x[0-9a-fA-F]+"
    ).Value

    $script:OriginalPowerSettings.MonitorTimeoutAC =
        [Convert]::ToInt32($acHex.Substring(2), 16)

    $script:OriginalPowerSettings.MonitorTimeoutDC =
        [Convert]::ToInt32($dcHex.Substring(2), 16)

    return $true
}


function Set-EPSystemPowerTemporary {

    Save-EPSystemPower

    powercfg /change monitor-timeout-ac 0

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao configurar timeout do monitor na tomada."
    }

    powercfg /change monitor-timeout-dc 0

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao configurar timeout do monitor na bateria."
    }

    Write-EPSetupLog `
        -Message "Configuracoes temporarias de energia aplicadas." `
        -Level "SUCCESS"

    return $true
}


function Restore-EPSystemPower {

    if (
        $null -eq $script:OriginalPowerSettings.MonitorTimeoutAC -or
        $null -eq $script:OriginalPowerSettings.MonitorTimeoutDC
    ) {

        Write-EPSetupLog `
            -Message "Configuracoes originais de energia nao encontradas." `
            -Level "WARNING"

        return $false
    }

    powercfg /change monitor-timeout-ac `
        $script:OriginalPowerSettings.MonitorTimeoutAC

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao restaurar timeout do monitor na tomada."
    }

    powercfg /change monitor-timeout-dc `
        $script:OriginalPowerSettings.MonitorTimeoutDC

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao restaurar timeout do monitor na bateria."
    }

    Write-EPSetupLog `
        -Message "Configuracoes originais de energia restauradas." `
        -Level "SUCCESS"

    return $true
}
