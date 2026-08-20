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

            "3" {
                Invoke-EPProfileConfigurationFlow
            }

            "4" {
                Set-EPDryRun -Enabled (-not (Test-EPDryRun))
                Read-Host "Pressione ENTER para continuar"
            }

            "5" {
                Invoke-EPExecutionProfileFlow
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
    Export-EPExecutionReport -Result $result -Context "Software" | Out-Null

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

function Invoke-EPProfileConfigurationFlow {

    while ($true) {
        $profileOption = Show-EPProfileConfigurationMenu

        switch ($profileOption) {
            "1" {
                Show-EPActiveProfile
                Read-Host "Pressione ENTER para voltar"
            }

            "2" {
                Set-EPCorporateLocalConfig
                Read-Host "Pressione ENTER para voltar"
            }

            "3" {
                Clear-EPCorporateLocalConfig | Out-Null
                Read-Host "Pressione ENTER para voltar"
            }

            "0" {
                return
            }
        }
    }
}

function Invoke-EPExecutionProfileFlow {

    while ($true) {
        $profileOption = Show-EPExecutionProfileMenu

        switch ($profileOption) {
            "1" {
                Invoke-EPPortfolioExecutionProfile
            }

            "2" {
                Invoke-EPCorporateBasicExecutionProfile
            }

            "3" {
                Invoke-EPCorporateFullExecutionProfile
            }

            "4" {
                Invoke-EPSoftwareOnlyExecutionProfile
            }

            "5" {
                Invoke-EPSystemOnlyExecutionProfile
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
    Export-EPExecutionReport -Result $result -Context "CredentialDelegation" | Out-Null

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
    Export-EPExecutionReport -Result $result -Context "DomainJoin" | Out-Null

    Read-Host "Pressione ENTER para voltar"
}

function Invoke-EPFullSystemConfigurationFlow {

    Write-EPSetupLog `
        -Message "Iniciando configuracao completa do sistema." `
        -Level "INFO"

    $steps = @(
        "Delegacao de credenciais RDP"
        "Adicionar ao dominio: perguntar antes"
        "Configuracao do usuario atual"
    )

    if (-not (Confirm-EPExecutionPlan -Title "Configuracao completa do sistema" -Steps $steps)) {
        Write-EPSetupLog `
            -Message "Configuracao completa do sistema cancelada pelo usuario." `
            -Level "SKIPPED"

        return
    }

    Clear-EPRestartState

    $tasks = @(New-EPSystemConfigurationTasks -IncludeDomain -IncludeUser)

    $result = Invoke-EPSetupTasks `
        -Tasks $tasks

    Show-EPSetupSummary -Result $result

    Show-EPRestartSummary
    Export-EPExecutionReport -Result $result -Context "FullSystemConfiguration" | Out-Null

    Read-Host "Pressione ENTER para voltar"
}

function Invoke-EPPortfolioExecutionProfile {

    $steps = @(
        "Delegacao de credenciais RDP"
        "Configuracao do usuario atual"
    )

    Invoke-EPSystemTaskProfile `
        -Title "Portfolio" `
        -Context "ExecutionProfile-Portfolio" `
        -Steps $steps `
        -Tasks @(New-EPSystemConfigurationTasks -IncludeUser)
}

function Invoke-EPCorporateBasicExecutionProfile {

    $steps = @(
        "Delegacao de credenciais RDP"
        "Adicionar ao dominio: perguntar antes"
    )

    Invoke-EPSystemTaskProfile `
        -Title "Corporate basico" `
        -Context "ExecutionProfile-CorporateBasic" `
        -Steps $steps `
        -Tasks @(New-EPSystemConfigurationTasks -IncludeDomain)
}

function Invoke-EPCorporateFullExecutionProfile {

    $steps = @(
        "Delegacao de credenciais RDP"
        "Adicionar ao dominio: perguntar antes"
        "Configuracao do usuario atual"
    )

    Invoke-EPSystemTaskProfile `
        -Title "Corporate completo" `
        -Context "ExecutionProfile-CorporateFull" `
        -Steps $steps `
        -Tasks @(New-EPSystemConfigurationTasks -IncludeDomain -IncludeUser)
}

function Invoke-EPSoftwareOnlyExecutionProfile {

    $steps = @(
        "Selecao manual de aplicativos"
        "Instalacao somente dos aplicativos selecionados"
    )

    if (-not (Confirm-EPExecutionPlan -Title "Somente aplicativos" -Steps $steps)) {
        Write-EPSetupLog `
            -Message "Perfil Somente aplicativos cancelado pelo usuario." `
            -Level "SKIPPED"

        return
    }

    Invoke-EPSoftwareInstallationFlow
}

function Invoke-EPSystemOnlyExecutionProfile {

    $steps = @(
        "Selecionar uma configuracao de sistema"
        "Executar somente tarefas de sistema"
    )

    if (-not (Confirm-EPExecutionPlan -Title "Somente sistema" -Steps $steps)) {
        Write-EPSetupLog `
            -Message "Perfil Somente sistema cancelado pelo usuario." `
            -Level "SKIPPED"

        return
    }

    Invoke-EPSystemConfigurationFlow
}

function Invoke-EPSystemTaskProfile {

param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string]$Context,

    [Parameter(Mandatory = $true)]
    [string[]]$Steps,

    [Parameter(Mandatory = $true)]
    [array]$Tasks
)

    Write-EPSetupLog `
        -Message "Iniciando perfil de execucao: $Title." `
        -Level "INFO"

    if (-not (Confirm-EPExecutionPlan -Title $Title -Steps $Steps)) {
        Write-EPSetupLog `
            -Message "Perfil de execucao cancelado pelo usuario: $Title." `
            -Level "SKIPPED"

        return
    }

    Clear-EPRestartState

    $result = Invoke-EPSetupTasks `
        -Tasks $Tasks

    Show-EPSetupSummary -Result $result

    Show-EPRestartSummary
    Export-EPExecutionReport -Result $result -Context $Context | Out-Null

    Read-Host "Pressione ENTER para voltar"
}

function New-EPSystemConfigurationTasks {

param(
    [switch]$IncludeDomain,
    [switch]$IncludeUser
)

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

    if ($IncludeDomain) {
        $tasks += @{
            Name = "Adicionar ao dominio"
            Action = {
                Add-EPComputerToDomain `
                    -Prompt `
                    -SuppressRestartPrompt
            }
        }
    }

    if ($IncludeUser) {
        $tasks += @{
            Name = "Configuracao do usuario"
            Action = {
                Invoke-EPUserConfiguration
            }
        }
    }

    return $tasks
}

function Confirm-EPExecutionPlan {

param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [string[]]$Steps
)

    $config = Get-EPSetupConfig
    $dryRunStatus = Get-EPDryRunStatus

    Clear-Host
    Show-EPSetupBanner

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "        RESUMO PRE-EXECUCAO" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ("Perfil escolhido: {0}" -f $Title)
    Write-Host ("Perfil ativo:     {0}" -f $config.Profile.Name)
    Write-Host ("Dry Run:          {0}" -f $dryRunStatus)
    Write-Host ""
    Write-Host "Sera executado:"

    foreach ($step in $Steps) {
        Write-Host ("- {0}" -f $step)
    }

    Write-Host ""

    if ($Steps -match "dominio") {
        Write-Host "Entrada no dominio depende de confirmacao durante a execucao." -ForegroundColor Yellow
        Write-Host ""
    }

    $confirmation = Read-Host "Deseja continuar? (S/N)"

    return ($confirmation -match "^[sS]$")
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
    Export-EPExecutionReport -Result $result -Context "UserConfiguration" | Out-Null

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

    if (Test-EPDryRun) {
        Write-Host "[DRY RUN] Simulacao ativa. Nenhuma alteracao destrutiva foi aplicada." -ForegroundColor Yellow
        Write-Host ""
    }

    foreach ($detail in $Result.Details) {
        switch ($detail.Status) {
            "SUCCESS" {
                Write-Host ("[SUCCESS] {0}" -f $detail.Name) -ForegroundColor Green
            }
            "SKIPPED" {
                Write-Host ("[SKIP]    {0}" -f $detail.Name) -ForegroundColor DarkGray
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

