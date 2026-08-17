# ============================================================================
#
# EPSetup - Start
#
# Ponto de entrada principal da aplicação
#
# ============================================================================

function Start-EPSetup {

<#
.SYNOPSIS
Inicia o processo de configuração do EPSetup.

.DESCRIPTION
Coordena a execução dos principais componentes do EPSetup.

.OUTPUTS
Boolean
#>

# =========================================================================
# Eleva��o
# =========================================================================

if (-not (Test-EPSetupElevated)) {

        Invoke-EPSetupElevation `
            -ScriptPath $PSCommandPath

        return
    }

# =========================================================================
# Inicializa��o
# =========================================================================

Write-EPSetupLog `
    -Message "EPSetup iniciado." `
    -Level "INFO"


try {

    # =====================================================================
    # Obtém as tarefas disponíveis
    # =====================================================================

    $tasks = Get-EPSetupTasks


    # =====================================================================
    # Executa as tarefas
    # =====================================================================

    $result = Invoke-EPSetupTasks `
        -Tasks $tasks


    # =====================================================================
    # Finalização
    # =====================================================================

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

