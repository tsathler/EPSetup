# ============================================================================
#
# EPSetup - Execution Report
#
# Exporta resumo da execucao para consulta posterior
#
# ============================================================================

function Export-EPExecutionReport {

    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Result,

        [string]$Context = "EPSetup"
    )

    $config = Get-EPSetupConfig
    $reportDirectory = $config.Paths.Reports

    if ([string]::IsNullOrWhiteSpace($reportDirectory)) {
        $reportDirectory = Join-Path `
            -Path $config.Paths.Data `
            -ChildPath "Reports"
    }

    if (-not (Test-Path -LiteralPath $reportDirectory)) {
        New-Item `
            -Path $reportDirectory `
            -ItemType Directory `
            -Force `
            -ErrorAction Stop |
        Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $safeContext = $Context -replace "[^a-zA-Z0-9_-]", "_"
    $reportPath = Join-Path `
        -Path $reportDirectory `
        -ChildPath "EPSetup_${safeContext}_$timestamp.json"

    $restartState = Get-EPRestartState

    $report = [pscustomobject]@{
        Application = $config.Application.Name
        Version = $config.Application.Version
        Profile = $config.Profile.Name
        Context = $Context
        ComputerName = $env:COMPUTERNAME
        UserName = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        DryRun = Test-EPDryRun
        Timestamp = (Get-Date).ToString("s")
        RestartRequired = $restartState.Required
        RestartReasons = @($restartState.Reasons)
        Summary = [pscustomobject]@{
            Total = $Result.Total
            Success = $Result.Success
            Skipped = $Result.Skipped
            Failure = $Result.Failure
        }
        Details = @($Result.Details)
    }

    $report |
        ConvertTo-Json -Depth 8 |
        Set-Content `
            -LiteralPath $reportPath `
            -Encoding UTF8 `
            -ErrorAction Stop

    Write-EPSetupLog `
        -Message "Relatorio de execucao exportado: $reportPath" `
        -Level "SUCCESS"

    return $reportPath
}
