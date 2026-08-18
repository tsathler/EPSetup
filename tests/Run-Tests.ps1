# ============================================================================
#
# EPSetup - Test Runner
#
# Valida sintaxe PowerShell e executa testes Pester
#
# ============================================================================

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "Validando sintaxe dos scripts..." -ForegroundColor Cyan

$syntaxErrors = @()

Get-ChildItem `
    -LiteralPath $projectRoot `
    -Filter "*.ps1" `
    -Recurse |
ForEach-Object {
    $tokens = $null
    $parseErrors = $null

    [System.Management.Automation.Language.Parser]::ParseFile(
        $_.FullName,
        [ref]$tokens,
        [ref]$parseErrors
    ) | Out-Null

    if ($parseErrors) {
        $syntaxErrors += $parseErrors |
            ForEach-Object {
                "{0}: {1}" -f $_.Extent.File, $_.Message
            }
    }
}

if ($syntaxErrors.Count -gt 0) {
    $syntaxErrors | ForEach-Object {
        Write-Host $_ -ForegroundColor Red
    }

    throw "Falha na validacao de sintaxe."
}

Write-Host "Sintaxe OK." -ForegroundColor Green
Write-Host "Executando testes Pester..." -ForegroundColor Cyan

Invoke-Pester `
    -Script $PSScriptRoot
