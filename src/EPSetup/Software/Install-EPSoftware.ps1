# ============================================================================
#
# EPSetup - Software Installation
#
# Instala softwares definidos na configuracao
#
# ============================================================================


function Install-EPSoftware {

    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Software
    )


    $name = $Software.Name
    $installerType = $Software.InstallerType
    $arguments = $Software.Arguments


    Write-EPSetupLog `
        -Message "Iniciando instalacao de $name..." `
        -Level "INFO"

    if (Test-EPDryRun) {
        Write-EPSetupLog `
            -Message "[DRY RUN] Instalacao de $name seria executada. Nenhuma alteracao foi feita." `
            -Level "WARNING"

        return $true
    }


    # =========================================================================
    # Define o instalador
    # =========================================================================

    if ($Software.Source.Type -eq "Winget") {

        $wingetCommand = Get-Command "winget.exe" -ErrorAction SilentlyContinue

        if (-not $wingetCommand) {
            throw "Winget nao foi encontrado neste computador. Instale o App Installer ou use um instalador local para $name."
        }

        if ([string]::IsNullOrWhiteSpace($Software.Source.PackageId)) {
            throw "PackageId do Winget nao informado para $name."
        }

        $filePath = $wingetCommand.Source
        $processArguments = @(
            "install"
            "--id"
            $Software.Source.PackageId
            "--exact"
            "--silent"
            "--accept-package-agreements"
            "--accept-source-agreements"
        )

        if ($Software.Source.Custom) {
            $processArguments += @(
                "--custom"
                $Software.Source.Custom
            )
        }

        Write-EPSetupLog `
            -Message "Instalando $name via Winget..." `
            -Level "INFO"
    }

    elseif ($Software.Source.Type -eq "Download") {

        if ([string]::IsNullOrWhiteSpace($Software.Source.Url)) {

            throw "URL de download nao informada para $name."
        }


        $extension = if ($installerType -eq "MSI") {
            ".msi"
        }
        else {
            ".exe"
        }


        $installerPath = Join-Path `
            -Path $env:TEMP `
            -ChildPath "$name-Setup$extension"


        Write-EPSetupLog `
            -Message "Baixando $name..." `
            -Level "INFO"


        Invoke-WebRequest `
            -Uri $Software.Source.Url `
            -OutFile $installerPath `
            -UseBasicParsing `
            -ErrorAction Stop


        if (-not (Test-Path -LiteralPath $installerPath)) {

            throw "Instalador de $name nao foi encontrado apos o download."
        }


        Write-EPSetupLog `
            -Message "Download de $name concluido." `
            -Level "SUCCESS"
    }


    elseif ($Software.Source.Type -eq "Local") {

        $installerPath = $Software.Source.Path


        if ([string]::IsNullOrWhiteSpace($installerPath)) {

            throw "Caminho do instalador nao informado para $name."
        }


        if (-not (Test-Path -LiteralPath $installerPath)) {

            throw "Instalador de $name nao encontrado: $installerPath"
        }


        Write-EPSetupLog `
            -Message "Usando instalador local de $name..." `
            -Level "INFO"
    }


    else {

        throw "Tipo de origem invalido para ${name}: $($Software.Source.Type)"
    }


    if ($Software.Source.Type -ne "Winget") {

        if ($installerType -eq "MSI") {

            $filePath = "msiexec.exe"

            $processArguments = @(
                "/i"
                "`"$installerPath`""
            ) + $arguments
        }


        elseif ($installerType -eq "EXE") {

            $filePath = $installerPath

            $processArguments = $arguments
        }


        else {

            throw "Tipo de instalador invalido para $name`: $installerType"
        }
    }


    # =========================================================================
    # Instalacao
    # =========================================================================

    Write-EPSetupLog `
        -Message "Instalando $name..." `
        -Level "INFO"


    Write-EPSetupLog `
    -Message "Executando instalador com argumentos: $processArguments" `
    -Level "INFO"
    
    $process = Start-Process `
        -FilePath $filePath `
        -ArgumentList $processArguments `
        -Wait `
        -NoNewWindow `
        -PassThru `
        -ErrorAction Stop


    if ($process.ExitCode -ne 0) {

        throw "Instalacao de $name falhou. Codigo de saida: $($process.ExitCode)"
    }


    Write-EPSetupLog `
        -Message "Instalacao de $name concluida com sucesso." `
        -Level "SUCCESS"


    # =========================================================================
    # Limpeza
    # =========================================================================

    if ($Software.Source.Type -eq "Download") {

        Remove-Item `
            -LiteralPath $installerPath `
            -Force `
            -ErrorAction SilentlyContinue
    }


    return $true
}
