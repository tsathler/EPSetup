# ============================================================================
#
# EPSetup - Start
#
# Ponto de entrada principal da aplicação
#
# ============================================================================

function Start-EPSetup {

param(
    [string]$ScriptPath = $PSCommandPath
)

<#
.SYNOPSIS
Inicia o processo de configuração do EPSetup.

.DESCRIPTION
Coordena a execução dos principais componentes do EPSetup.

.OUTPUTS
Boolean
#>

# =========================================================================
# Elevacao
# =========================================================================

if (-not (Test-EPSetupElevated)) {

        Invoke-EPSetupElevation `
            -ScriptPath $ScriptPath

        return
    }

# =========================================================================
# Inicializacao
# =========================================================================

Initialize-EPSetupLogging | Out-Null

Show-EPSetupBanner

Write-EPSetupLog `
    -Message "EPSetup iniciado." `
    -Level "INFO"


try {

    $softwareList = @(Get-EPSoftware)
    $selectedSoftware = @(Show-EPSoftwareSelectionMenu -SoftwareList $softwareList)

    if ($selectedSoftware.Count -eq 0) {
        Write-EPSetupLog `
            -Message "Nenhum software selecionado. Execucao cancelada pelo usuario." `
            -Level "WARNING"

        return $false
    }

    foreach ($software in $selectedSoftware) {
        Write-EPSetupLog `
            -Message "Usuario selecionou: $($software.Name)" `
            -Level "INFO"
    }

    $tasks = @(Get-EPSoftwareTasks -SoftwareList $selectedSoftware)

    $result = Invoke-EPSetupTasks `
        -Tasks $tasks

    Show-EPSetupSummary -Result $result

    if ($result.Failure -gt 0) {

        Write-EPSetupLog `
            -Message "EPSetup finalizado com falhas." `
            -Level "ERROR"

        return $false
    }


    Write-EPSetupLog `
        -Message "EPSetup finalizado com sucesso." `
        -Level "SUCCESS"


    return $true
}
catch {

    Write-EPSetupLog `
        -Message "Falha na execução do EPSetup: $($_.Exception.Message)" `
        -Level "ERROR"


    return $false
}

}

function Show-EPSetupSummary {

param(
    [Parameter(Mandatory = $true)]
    [hashtable]$Result
)

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "         EXECUCAO FINALIZADA" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    foreach ($detail in $Result.Details) {
        switch ($detail.Status) {
            "SUCCESS" {
                Write-Host ("[SUCCESS] {0}" -f $detail.Name) -ForegroundColor Green
            }
            "SKIPPED" {
                Write-Host ("[SKIP]    {0} - ja instalado" -f $detail.Name) -ForegroundColor DarkGray
            }
            "FAILURE" {
                Write-Host ("[ERROR]   {0}" -f $detail.Name) -ForegroundColor Red
            }
        }
    }

    Write-Host ""
    Write-Host "----------------------------------------"
    Write-Host ("Total:      {0}" -f $Result.Total)
    Write-Host ("Sucesso:    {0}" -f $Result.Success)
    Write-Host ("Ignorados:  {0}" -f $Result.Skipped)
    Write-Host ("Erros:      {0}" -f $Result.Failure)
    Write-Host ""
}

