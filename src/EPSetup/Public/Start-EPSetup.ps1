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

    while ($true) {
        $mainOption = Show-EPMainMenu

        switch ($mainOption) {
            "1" {
                Invoke-EPSoftwareInstallationFlow
            }

            "2" {
                Invoke-EPSystemConfigurationFlow
            }

            "0" {
                Write-EPSetupLog `
                    -Message "EPSetup finalizado pelo usuario." `
                    -Level "INFO"

                return $true
            }
        }
    }
}
catch {

    Write-EPSetupLog `
        -Message "Falha na execução do EPSetup: $($_.Exception.Message)" `
        -Level "ERROR"


    return $false
}

}

function Invoke-EPSoftwareInstallationFlow {

    $softwareList = @(Get-EPSoftware)
    $selectedSoftware = @(Show-EPSoftwareSelectionMenu -SoftwareList $softwareList)

    if ($selectedSoftware.Count -eq 0) {
        Write-EPSetupLog `
            -Message "Nenhum software selecionado. Instalacao de aplicativos cancelada." `
            -Level "WARNING"

        return
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

    Read-Host "Pressione ENTER para voltar"
}

function Invoke-EPSystemConfigurationFlow {

    while ($true) {
        $systemOption = Show-EPSystemConfigurationMenu

        switch ($systemOption) {
            "1" {
                Invoke-EPCredentialDelegationTestFlow
            }

            "2" {
                Invoke-EPDomainJoinFlow
            }

            "3" {
                Invoke-EPUserConfigurationFlow
            }

            "4" {
                Invoke-EPFullSystemConfigurationFlow
            }

            "0" {
                return
            }
        }
    }
}

function Invoke-EPCredentialDelegationTestFlow {

    Write-EPSetupLog `
        -Message "Iniciando teste de delegacao de credenciais RDP." `
        -Level "INFO"

    $tasks = @(
        @{
            Name = "Delegacao de credenciais RDP"
            Condition = {
                -not (Test-EPCredentialDelegation)
            }
            Action = {
                Set-EPCredentialDelegation
            }
        }
    )

    $result = Invoke-EPSetupTasks `
        -Tasks $tasks

    Show-EPSetupSummary -Result $result

    Read-Host "Pressione ENTER para voltar"
}

function Invoke-EPDomainJoinFlow {

    Write-EPSetupLog `
        -Message "Iniciando fluxo de entrada no dominio." `
        -Level "INFO"

    Clear-EPRestartState

    $tasks = @(
        @{
            Name = "Adicionar ao dominio"
            Action = {
                Add-EPComputerToDomain -Prompt
            }
        }
    )

    $result = Invoke-EPSetupTasks `
        -Tasks $tasks

    Show-EPSetupSummary -Result $result

    Show-EPRestartSummary

    Read-Host "Pressione ENTER para voltar"
}

function Invoke-EPFullSystemConfigurationFlow {

    Write-EPSetupLog `
        -Message "Iniciando configuracao completa do sistema." `
        -Level "INFO"

    Clear-EPRestartState

    $tasks = @(
        @{
            Name = "Delegacao de credenciais RDP"
            Condition = {
                -not (Test-EPCredentialDelegation)
            }
            Action = {
                Set-EPCredentialDelegation
            }
        }

        @{
            Name = "Adicionar ao dominio"
            Action = {
                Add-EPComputerToDomain `
                    -Prompt `
                    -SuppressRestartPrompt
            }
        }

        @{
            Name = "Configuracao do usuario"
            Action = {
                Invoke-EPUserConfiguration
            }
        }
    )

    $result = Invoke-EPSetupTasks `
        -Tasks $tasks

    Show-EPSetupSummary -Result $result

    Show-EPRestartSummary

    Read-Host "Pressione ENTER para voltar"
}

function Invoke-EPUserConfigurationFlow {

    Write-EPSetupLog `
        -Message "Iniciando fluxo de configuracao do usuario." `
        -Level "INFO"

    $tasks = @(
        @{
            Name = "Configuracao do usuario"
            Action = {
                Invoke-EPUserConfiguration
            }
        }
    )

    $result = Invoke-EPSetupTasks `
        -Tasks $tasks

    Show-EPSetupSummary -Result $result

    Read-Host "Pressione ENTER para voltar"
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

function Show-EPRestartSummary {

    $restartState = Get-EPRestartState

    if (-not $restartState.Required) {
        return
    }

    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "        REINICIALIZACAO NECESSARIA" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""

    foreach ($reason in $restartState.Reasons) {
        Write-Host ("[WARNING] {0}" -f $reason) -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Reinicie o computador depois de concluir as configuracoes." -ForegroundColor Yellow
    Write-Host ""
}

