# ============================================================================
#
# EPSetup - Software Tasks
#
# Verifica e instala softwares
#
# ============================================================================


# Retorna os softwares instalados no computador
function Get-InstalledSoftware {

    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $paths) {

        Get-ItemProperty `
            -Path $path `
            -ErrorAction SilentlyContinue |
        Where-Object {
            $_.DisplayName
        } |
        Select-Object `
            DisplayName,
            DisplayVersion,
            Publisher
    }
}


# Verifica se um software esta instalado
function Test-SoftwareInstalled {

    param(
        [Parameter(Mandatory = $true)]
        [string]$SoftwareName
    )

    $software = Get-InstalledSoftware

    return $null -ne (
        $software |
        Where-Object {
            $_.DisplayName -like "*$SoftwareName*"
        }
    )
}

# Instala um software a partir de um instalador
# Instala um software a partir de um instalador
function Install-Software {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$DownloadUrl,

        [Parameter(Mandatory = $true)]
        [string[]]$InstallerArguments
    )

    $installerPath = "$env:TEMP\$Name-Setup.exe"

    Write-Log `
        -Message "Baixando $Name..." `
        -Level "INFO"

    # Baixa o instalador
    Invoke-WebRequest `
        -Uri $DownloadUrl `
        -OutFile $installerPath `
        -UseBasicParsing `
        -ErrorAction Stop

    # Verifica se o instalador foi baixado
    if (-not (Test-Path $installerPath)) {
        throw "Instalador de $Name nao foi baixado."
    }

    Write-Log `
        -Message "Download de $Name concluido." `
        -Level "SUCCESS"

    Write-Log `
        -Message "Instalando $Name..." `
        -Level "INFO"

    # Executa o instalador
    $process = Start-Process `
    -FilePath $installerPath `
    -ArgumentList $InstallerArguments `
    -Wait `
    -NoNewWindow `
    -PassThru `
    -ErrorAction Stop

if ($process.ExitCode -ne 0) {
    throw "Instalacao de $Name falhou. Codigo de saida: $($process.ExitCode)"
}

    Write-Log `
        -Message "Instalacao de $Name concluida." `
        -Level "SUCCESS"

    # Remove o instalador temporario
    Remove-Item `
        -Path $installerPath `
        -Force `
        -ErrorAction SilentlyContinue

    return $true
}

# Instala o Google Chrome
function Install-GoogleChrome {

    $downloadUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"

    Install-Software `
        -Name "Chrome" `
        -DownloadUrl $downloadUrl `
        -InstallerArguments "/silent", "/install"

    # Verifica se o Chrome foi instalado
    if (-not (Test-SoftwareInstalled -SoftwareName "Chrome")) {
        throw "Google Chrome nao foi instalado corretamente."
    }

    return $true
}

# Instala o Mozilla Firefox
function Install-Firefox {

    $downloadUrl = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=pt-BR"

    Install-Software `
        -Name "Firefox" `
        -DownloadUrl $downloadUrl `
        -InstallerArguments "/S"

    # Verifica se o Firefox foi instalado
    if (-not (Test-SoftwareInstalled -SoftwareName "Mozilla Firefox")) {
        throw "Mozilla Firefox nao foi instalado corretamente."
    }

    return $true
}

# Instala o WinRAR
function Install-WinRAR {

    $downloadUrl = "https://www.rarlab.com/rar/winrar-x64-723.exe"

    Install-Software `
        -Name "WinRAR" `
        -DownloadUrl $downloadUrl `
        -InstallerArguments "/s"

    # Verifica se o WinRAR foi instalado
    if (-not (Test-SoftwareInstalled -SoftwareName "WinRAR")) {
        throw "WinRAR nao foi instalado corretamente."
    }

    return $true
}

# Instala o AnyDesk
function Install-AnyDesk {

    $downloadUrl = "https://download.anydesk.com/AnyDesk.exe"

    Install-Software `
        -Name "AnyDesk" `
        -DownloadUrl $downloadUrl `
        -InstallerArguments "--install", "C:\Program Files (x86)\AnyDesk", "--start-with-win"

    if (-not (Test-SoftwareInstalled -SoftwareName "AnyDesk")) {
        throw "AnyDesk nao foi instalado corretamente."
    }

    return $true
}

# Instala o Microsoft Teams
function Install-MicrosoftTeams {

    $downloadUrl = "https://statics.teams.cdn.office.net/production-windows-x64/latest/Teams_windows_x64.exe"

    Install-Software `
        -Name "MicrosoftTeams" `
        -DownloadUrl $downloadUrl `
        -InstallerArguments "-s"

    if (-not (Test-SoftwareInstalled -SoftwareName "Microsoft Teams")) {
        throw "Microsoft Teams nao foi instalado corretamente."
    }

    return $true
}

# Instala o PDFCreator
function Install-PDFCreator {

    $downloadUrl = "https://download.pdfforge.org/download/pdfcreator/PDFCreator-stable"

    Install-Software `
        -Name "PDFCreator" `
        -DownloadUrl $downloadUrl `
        -InstallerArguments "/VERYSILENT", "/NORESTART"

    if (-not (Test-SoftwareInstalled -SoftwareName "PDFCreator")) {
        throw "PDFCreator nao foi instalado corretamente."
    }

    return $true
}