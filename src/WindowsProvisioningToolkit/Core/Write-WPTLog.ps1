# ============================================================================
#
# WindowsProvisioningToolkit - Logging
#
# Registra eventos da execucao em arquivo e exibe na tela
#
# ============================================================================


function Write-WPTLog {

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

        Initialize-WPTLogging
    }


    $safeMessage = [regex]::Replace($Message, '(?i)(password|senha|credential|credencial|secret|token)\s*[:=]\s*[^;\s]+', '$1=[REDACTED]')
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $logLine = "[$timestamp] [$Level] $safeMessage"


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
