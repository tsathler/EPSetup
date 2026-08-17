# ============================================================================
#
# EPSetup
#
# Main entry point
#
# Author: Thiago Sathler
#
# ============================================================================


# Define a pasta raiz do projeto
$RootPath = Split-Path $PSCommandPath

# Interrompe a execução quando ocorrer um erro
$ErrorActionPreference = "Stop"



try {

    # =========================================================================
    # Configuração
    # =========================================================================

    . "$RootPath\Modules\Config\Config.ps1"


    # =========================================================================
    # Elevação de privilégios
    # =========================================================================

    . "$RootPath\Modules\Elevation\Elevation.ps1"

    if (-not (Test-IsElevated)) {

        Invoke-SelfElevation -ScriptPath $PSCommandPath

        exit
    }


    # =========================================================================
    # Carregamento dos módulos
    # =========================================================================

    . "$RootPath\Modules\Logging\Logging.ps1"
    . "$RootPath\Modules\UI\Banner.ps1"
    . "$RootPath\Modules\System\SystemInfo.ps1"
    . "$RootPath\Modules\System\UpdateTasks.ps1"
    . "$RootPath\Modules\Tasks\TaskRunner.ps1"
    . "$RootPath\Modules\Tasks\NetworkTasks.ps1"
    . "$RootPath\Modules\Tasks\SystemTasks.ps1"
    . "$RootPath\Modules\Tasks\TaskDefinitions.ps1"
    . "$RootPath\Modules\Software\SoftwareInstaller.ps1"

    # =========================================================================
    # Inicialização
    # =========================================================================

    Initialize-Logging

    Write-Log `
        -Message "$($EPSetupConfig.Application.Name) iniciado" `
        -Level "INFO"

    Show-Banner


    # =========================================================================
    # Coleta de informações do sistema
    # =========================================================================

    $systemInfo = Get-SystemInfo

    Write-Log -Message "Computador: $($systemInfo.ComputerName)" -Level INFO
    Write-Log -Message "Usuario: $($systemInfo.User)" -Level INFO
    Write-Log -Message "Sistema: $($systemInfo.OperatingSystem)" -Level INFO
    Write-Log -Message "Versao: $($systemInfo.OSVersion)" -Level INFO
    Write-Log -Message "Processador: $($systemInfo.Processor)" -Level INFO
    Write-Log -Message "Memoria: $($systemInfo.MemoryGB) GB" -Level INFO
    

    # =========================================================================
# Execução das tarefas
# =========================================================================

$powerSettingsApplied = $false

try {

    Write-Log `
        -Message "Aplicando configuracoes temporarias de energia..." `
        -Level "INFO"

    Set-TemporaryPowerSettings

    $powerSettingsApplied = $true

    $Tasks = Get-SetupTasks

    $result = Invoke-Tasks -Tasks $Tasks
}
finally {

    if ($powerSettingsApplied) {

        Write-Log `
            -Message "Finalizando provisionamento e restaurando energia..." `
            -Level "INFO"

        try {

            Restore-PowerSettings
        }
        catch {

            Write-Log `
                -Message "Nao foi possivel restaurar as configuracoes de energia: $($_.Exception.Message)" `
                -Level "ERROR"
        }
    }
}
    # =========================================================================
    # Validação final
    # =========================================================================

    Test-FinalSetup
    # =========================================================================
    # Resultado da execução
    # =========================================================================

    Write-Host ""
    Write-Host "Resumo:"
    Write-Host "Sucesso: $($result.Success)"
    Write-Host "Falhas: $($result.Failure)"
    Write-Host "Ignoradas: $($result.Skipped)"


}


catch {

    # =========================================================================
    # Tratamento de erros
    # =========================================================================

    Write-Host ""
    Write-Host "ERRO ENCONTRADO:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    Read-Host "Pressione ENTER para fechar"
}

Read-Host "Pressione ENTER para sair"