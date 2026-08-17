# ============================================================================
#
# EPSetup - Logging
#
# Registra eventos da execucao em arquivo e exibe na tela
#
# ============================================================================


function Write-EPSetupLog {

    param(

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet(
            "INFO",
            "WARNING",
            "ERROR",
            "SUCCESS",
            "SKIPPED"
        )]
        [string]$Level = "INFO"
    )


    # Inicializa o logging caso ainda nao tenha sido inicializado
    if ([string]::IsNullOrWhiteSpace($script:LogFilePath)) {

        Initialize-EPSetupLogging
    }


    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $logLine = "[$timestamp] [$Level] $Message"


    # Grava no arquivo
    Add-Content `
        -Path $script:LogFilePath `
        -Value $logLine `
        -Encoding UTF8 `
        -ErrorAction Stop


    # Exibe no console
    switch ($Level) {

        "INFO" {

            Write-Host `
                $logLine `
                -ForegroundColor Cyan
        }

        "WARNING" {

            Write-Host `
                $logLine `
                -ForegroundColor Yellow
        }

        "ERROR" {

            Write-Host `
                $logLine `
                -ForegroundColor Red
        }

        "SUCCESS" {

            Write-Host `
                $logLine `
                -ForegroundColor Green
        }

        "SKIPPED" {

            Write-Host `
                $logLine `
                -ForegroundColor DarkGray
        }
    }
}
