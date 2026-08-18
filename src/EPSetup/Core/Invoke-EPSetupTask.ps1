# ============================================================================
#
# EPSetup - Task Runner
#
# Executa e controla as tarefas do EPSetup
#
# ============================================================================

# ============================================================================
# Executa uma unica tarefa
# ============================================================================

function Invoke-EPSetupTask {

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

    Write-EPSetupLog `
        -Message "Tarefa ignorada: $TaskName" `
        -Level "SKIPPED"

    return "SKIPPED"
}


# Verifica se existe uma condicao para a tarefa
if ($Condition) {

    try {

        $conditionResult = & $Condition
    }
    catch {

        Write-EPSetupLog `
            -Message "Falha ao verificar a condicao da tarefa '$TaskName': $($_.Exception.Message)" `
            -Level "ERROR"

        return "FAILURE"
    }


    if (-not $conditionResult) {

        Write-EPSetupLog `
            -Message "Tarefa ignorada: $TaskName" `
            -Level "SKIPPED"

        return "SKIPPED"
    }
}


# Registra o inicio da tarefa
Write-EPSetupLog `
    -Message "Iniciando tarefa: $TaskName" `
    -Level "INFO"


try {

    # Executa a acao da tarefa
    $actionResult = & $Action

    if ($actionResult -eq "SKIPPED") {
        Write-EPSetupLog `
            -Message "Tarefa ignorada: $TaskName" `
            -Level "SKIPPED"

        return "SKIPPED"
    }


    # Registra o sucesso
    Write-EPSetupLog `
        -Message "Tarefa concluida: $TaskName" `
        -Level "SUCCESS"


    return "SUCCESS"
}
catch {

    # Registra o erro ocorrido
    Write-EPSetupLog `
        -Message "Falha na tarefa '$TaskName': $($_.Exception.Message)" `
        -Level "ERROR"


    return "FAILURE"
}

}

# ============================================================================
# Executa varias tarefas em sequencia
# ============================================================================

function Invoke-EPSetupTasks {

param(
    [Parameter(Mandatory = $true)]
    [array]$Tasks
)


# Inicializa os contadores
$successCount = 0
$failureCount = 0
$skippedCount = 0
$details = @()


# Percorre todas as tarefas
foreach ($task in $Tasks) {

    # Executa a tarefa atual
    $result = Invoke-EPSetupTask `
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

    $details += [pscustomobject]@{
        Name = $task.Name
        Status = $result
    }
}


# Registra o resumo da execucao
Write-EPSetupLog `
    -Message "Tarefas concluidas: $successCount" `
    -Level "SUCCESS"


Write-EPSetupLog `
    -Message "Tarefas ignoradas: $skippedCount" `
    -Level "SKIPPED"


if ($failureCount -gt 0) {

    Write-EPSetupLog `
        -Message "Tarefas com falha: $failureCount" `
        -Level "ERROR"
}


# Retorna os resultados para o EPSetup
return @{
    Total = $Tasks.Count
    Success = $successCount
    Failure = $failureCount
    Skipped = $skippedCount
    Details = $details
}

}

