# ============================================================================
#
# EPSetup - Task Runner Module
#
# Executa tarefas definidas pelo EPSetup
#
# ============================================================================

# ============================================================================
#
# EPSetup - Task Runner Module
#
# Executa tarefas definidas pelo EPSetup
#
# ============================================================================


# Verifica se o módulo de Logging está carregado
if (-not (Get-Command Write-Log -ErrorAction SilentlyContinue)) {
    throw "Módulo de Logging não carregado."
}


function Invoke-Task {

    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )


    Write-Log `
        -Message "Executando tarefa: $TaskName" `
        -Level "INFO"

}