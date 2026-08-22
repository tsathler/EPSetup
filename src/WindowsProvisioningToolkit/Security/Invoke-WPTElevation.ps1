# ============================================================================
#
# WindowsProvisioningToolkit - Elevation
#
# Verifica e gerencia privilegios de Administrador
#
# ============================================================================

function Test-WPTElevated {

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

    $principal = New-Object `
        Security.Principal.WindowsPrincipal($currentUser)

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}


function Invoke-WPTElevation {

    param(
        [string]$ScriptPath
    )

    try {

        # Caminho do manifesto do m�dulo
        $moduleManifest = Join-Path `
            -Path $PSScriptRoot `
            -ChildPath "..\WindowsProvisioningToolkit.psd1"

        $moduleManifest = (Resolve-Path $moduleManifest).Path


        # Comandos que ser�o executados no PowerShell elevado
        $command = @"
Import-Module '$moduleManifest' -Force
Start-WPT

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " WindowsProvisioningToolkit finalizado." -ForegroundColor Green
Write-Host " Pressione ENTER para fechar." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Read-Host
"@


        # Abre um novo PowerShell como Administrador
        Start-Process `
            -FilePath "powershell.exe" `
            -ArgumentList @(
                "-NoProfile"
                "-ExecutionPolicy"
                "Bypass"
                "-Command"
                $command
            ) `
            -Verb RunAs `
            -ErrorAction Stop

        return $true
    }
    catch {

        throw "Nao foi possivel iniciar o WindowsProvisioningToolkit como Administrador: $($_.Exception.Message)"
    }
}
