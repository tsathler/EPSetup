if ($PSScriptRoot) {
    $RootPath = $PSScriptRoot
}
else {
    $RootPath = [System.AppDomain]::CurrentDomain.BaseDirectory
}

$MainScript = Join-Path $RootPath "Main.ps1"

if (-not (Test-Path -LiteralPath $MainScript)) {
    Write-Host "Main.ps1 nao foi encontrado em:" -ForegroundColor Red
    Write-Host $MainScript -ForegroundColor Yellow
    Read-Host "Pressione ENTER para sair"
    exit 1
}

powershell.exe -ExecutionPolicy Bypass -File $MainScript