# ============================================================================
#
# WindowsProvisioningToolkit - Setup Validation
#
# Valida o resultado final do provisionamento
#
# ============================================================================


function Test-WPT {

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " VALIDACAO FINAL" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    $successCount = 0
    $failureCount = 0
    $skippedCount = 0


    # =========================================================================
    # Internet
    # =========================================================================

    if (Test-WPTInternetConnection) {

        Write-Host "[OK]       Conexao com a Internet" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[FALHA]    Conexao com a Internet" `
            -ForegroundColor Red

        $failureCount++
    }


    # =========================================================================
    # Nome do computador
    # =========================================================================

    $computerName = $env:COMPUTERNAME

    Write-Host "[OK]       Nome do computador: $computerName" `
        -ForegroundColor Green

    $successCount++


    # =========================================================================
    # Software
    # =========================================================================

    $softwareList = @(
        "Chrome"
        "Mozilla Firefox"
        "WinRAR"
        "AnyDesk"
        "Microsoft Teams"
        "PDFCreator"
    )


    foreach ($software in $softwareList) {

        if (Test-WPTSoftwareInstalled -SoftwareName $software) {

            Write-Host "[OK]       $software" `
                -ForegroundColor Green

            $successCount++
        }
        else {

            Write-Host "[FALHA]    $software" `
                -ForegroundColor Red

            $failureCount++
        }
    }


    # =========================================================================
    # Domí­nio
    # =========================================================================

    $computerSystem = Get-CimInstance Win32_ComputerSystem

    if ($computerSystem.PartOfDomain) {

        Write-Host "[OK]       Dominio: $($computerSystem.Domain)" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[SKIPPED]  Computador nao pertence a um dominio" `
            -ForegroundColor Yellow

        $skippedCount++
    }


    # =========================================================================
    # Resumo
    # =========================================================================

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " RESULTADO DA VALIDACAO" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "OK:        $successCount" -ForegroundColor Green
    Write-Host "Falhas:    $failureCount" -ForegroundColor Red
    Write-Host "Ignoradas: $skippedCount" -ForegroundColor Yellow
    Write-Host ""


    if ($failureCount -eq 0) {

        Write-WPTLog `
            -Message "Validacao final concluida sem falhas." `
            -Level "SUCCESS"

        return $true
    }


    Write-WPTLog `
        -Message "Validacao final concluida com $failureCount falha(s)." `
        -Level "ERROR"

    return $false
}
