# ============================================================================
#
# EPSetup - Task Runner Module
#
# Executa e controla as tarefas do EPSetup
#
# ============================================================================


# Verifica se o Logging esta carregado
if (-not (Get-Command Write-Log -ErrorAction SilentlyContinue)) {
    throw "Modulo de Logging nao carregado."
}


# Executa uma unica tarefa
function Invoke-Task {

    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskName,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Action,

        [scriptblock]$Condition,

        [switch]$Skip
    )


    # Verifica se a tarefa deve ser ignorada manualmente
    if ($Skip) {

        Write-Log `
            -Message "Tarefa ignorada: $TaskName" `
            -Level "SKIPPED"

        return "SKIPPED"
    }


    # Verifica se existe uma condicao para a tarefa
    if ($Condition) {

        if (-not (& $Condition)) {

            Write-Log `
                -Message "Tarefa ignorada: $TaskName" `
                -Level "SKIPPED"

            return "SKIPPED"
        }
    }


    # Registra o inicio da tarefa
    Write-Log `
        -Message "Iniciando tarefa: $TaskName" `
        -Level "INFO"


    try {

        # Executa a acao da tarefa
        & $Action


        # Registra o sucesso
        Write-Log `
            -Message "Tarefa concluida: $TaskName" `
            -Level "SUCCESS"


        return "SUCCESS"

    }
    catch {

        # Registra o erro ocorrido
        Write-Log `
            -Message "Falha na tarefa '$TaskName': $($_.Exception.Message)" `
            -Level "ERROR"


        return "FAILURE"
    }
}


# Executa varias tarefas em sequencia
function Invoke-Tasks {

    param(
        [Parameter(Mandatory = $true)]
        [array]$Tasks
    )


    # Inicializa os contadores
    $successCount = 0
    $failureCount = 0
    $skippedCount = 0


    # Percorre todas as tarefas
    foreach ($task in $Tasks) {

        # Executa a tarefa atual
        $result = Invoke-Task `
            -TaskName $task.Name `
            -Action $task.Action `
            -Condition $task.Condition `
            -Skip:$task.Skip


        # Conta o resultado da tarefa
        switch ($result) {

            "SUCCESS" {
                $successCount++
            }

            "FAILURE" {
                $failureCount++
            }

            "SKIPPED" {
                $skippedCount++
            }
        }
    }


    # Registra o resumo da execucao
    Write-Log `
        -Message "Tarefas concluidas: $successCount" `
        -Level "SUCCESS"


    Write-Log `
        -Message "Tarefas ignoradas: $skippedCount" `
        -Level "SKIPPED"


    if ($failureCount -gt 0) {

        Write-Log `
            -Message "Tarefas com falha: $failureCount" `
            -Level "ERROR"
    }


    # Retorna os resultados para o Main
    return @{
        Success = $successCount
        Failure = $failureCount
        Skipped = $skippedCount
    }
}