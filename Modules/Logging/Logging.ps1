# ============================================================================
# EPSetup - Logging Module
#
# Registra eventos da execução em arquivo e exibe na tela por nível de severidade
#
# ============================================================================

$script:LogFilePath = $null

function Initialize-Logging {

<#
.SYNOPSIS
Prepara o sistema de logging: cria a pasta de logs (se necessário) e define
o caminho do arquivo de log da execução atual.
#>

    $logDirectory = "C:\ProgramData\EPSetup\Logs"

    if (-not (Test-Path -Path $logDirectory)) {
        New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $fileName = "EPSetup_$timestamp.log"

    $script:LogFilePath = Join-Path -Path $logDirectory -ChildPath $fileName
}


function Write-Log {

<#
.SYNOPSIS
Grava uma mensagem no arquivo de log da execução atual e exibe na tela,
colorida conforme o nível de severidade.
#>

    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )


    if (-not $script:LogFilePath) {
        Initialize-Logging
    }


    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"


    Add-Content -Path $script:LogFilePath -Value $logLine -Encoding UTF8


    switch ($Level) {
        "INFO" {
            Write-Host $logLine -ForegroundColor Cyan
        }

        "WARNING" {
            Write-Host $logLine -ForegroundColor Yellow
        }

        "ERROR" {
            Write-Host $logLine -ForegroundColor Red
        }
    }
}