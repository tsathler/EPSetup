# ============================================================================
#
# EPSetup - Elevation Module
#
# Verifica e gerencia privilégios de execução elevados (Administrador)
#
# ============================================================================


function Test-IsElevated {

<#
.SYNOPSIS
    Verifica se a sessão atual do PowerShell está rodando com privilégios de Administrador.
#>

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}



function Invoke-SelfElevation {

    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    $debugFile = "C:\ProgramData\EPSetup\elevation-debug.txt"

    try {

        "Script recebido: $ScriptPath" | Out-File $debugFile -Append

        if (-not (Test-Path $ScriptPath)) {
            "ERRO: Script não encontrado" | Out-File $debugFile -Append
            exit 1
        }

        "Abrindo processo elevado..." | Out-File $debugFile -Append

        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

        Start-Process `
            -FilePath "powershell.exe" `
            -ArgumentList $arguments `
            -Verb RunAs

        "Processo elevado iniciado" | Out-File $debugFile -Append

    }
    catch {

        "ERRO:" | Out-File $debugFile -Append
        $_.Exception.Message | Out-File $debugFile -Append
    }

    exit
}