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
function Install-Software {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$DownloadUrl,

        [Parameter(Mandatory = $true)]
        [string[]]$InstallerArguments,

        [ValidateSet("EXE", "MSI")]
        [string]$InstallerType = "EXE"
    )

    $extension = if ($InstallerType -eq "MSI") {
        ".msi"
    }
    else {
        ".exe"
    }

    $installerPath = "$env:TEMP\$Name-Setup$extension"

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

    # Define o executavel e os argumentos
    if ($InstallerType -eq "MSI") {

        $filePath = "msiexec.exe"

        $arguments = @(
            "/i"
            "`"$installerPath`""
        ) + $InstallerArguments
    }
    else {

        $filePath = $installerPath

        $arguments = $InstallerArguments
    }

    # Executa o instalador
    $process = Start-Process `
        -FilePath $filePath `
        -ArgumentList $arguments `
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
        -InstallerArguments "/VERYSILENT", "/NORESTART", "/COMPONENTS=none"

    if (-not (Test-SoftwareInstalled -SoftwareName "PDFCreator")) {
        throw "PDFCreator nao foi instalado corretamente."
    }

    return $true
}

# Instala o GLPI Agent
function Install-GLPIAgent {

    $downloadUrl = "https://github.com/glpi-project/glpi-agent/releases/download/1.15/GLPI-Agent-1.15-x64.msi"

    $serverUrl = "http://conecta.cieemg.org.br/marketplace/glpiinventory/"

    Install-Software `
        -Name "GLPI Agent" `
        -DownloadUrl $downloadUrl `
        -InstallerArguments "/quiet", "SERVER=$serverUrl", "RUNNOW=1" `
        -InstallerType "MSI"

    if (-not (Test-Path "C:\Program Files\GLPI-Agent\glpi-agent.bat")) {
        throw "GLPI Agent nao foi instalado corretamente."
    }

    return $true
}

# Solicita o inventario do GLPI Agent
function Invoke-GLPIInventory {

    $agentPath = "C:\Program Files\GLPI-Agent\glpi-agent.bat"
    $localUrl = "http://localhost:62354/now?task=inventory"

    if (-not (Test-Path $agentPath)) {
        throw "GLPI Agent nao encontrado."
    }

    Write-Log `
        -Message "Solicitando inventario do GLPI Agent..." `
        -Level "INFO"

    $response = Invoke-WebRequest `
        -Uri $localUrl `
        -UseBasicParsing `
        -ErrorAction Stop

    if ($response.StatusCode -ne 200) {
        throw "Nao foi possivel solicitar o inventario do GLPI."
    }

    Write-Log `
        -Message "Inventario do GLPI solicitado com sucesso." `
        -Level "SUCCESS"

    return $true
}

function Rename-EPComputer {

    $currentName = $env:COMPUTERNAME

    Write-Log `
        -Message "Nome atual do computador: $currentName" `
        -Level "INFO"

    $answer = Read-Host "Deseja alterar o nome do computador? (S/N)"

    if ($answer -notmatch "^[Ss]$") {

        Write-Log `
            -Message "Alteracao do nome do computador ignorada pelo usuario." `
            -Level "SKIPPED"

        return $true
    }

    $newName = Read-Host "Digite o novo nome do computador"

    if ([string]::IsNullOrWhiteSpace($newName)) {
        throw "O nome do computador nao pode estar vazio."
    }

    if ($newName.Length -gt 15) {
        throw "O nome do computador nao pode possuir mais de 15 caracteres."
    }

    if ($newName -notmatch "^[a-zA-Z0-9-]+$") {
        throw "O nome do computador possui caracteres invalidos."
    }

    if ($newName -ieq $currentName) {

        Write-Log `
            -Message "O novo nome e igual ao nome atual. Alteracao ignorada." `
            -Level "SKIPPED"

        return $true
    }

    Write-Log `
        -Message "Renomeando computador de $currentName para $newName..." `
        -Level "INFO"

    try {

        Rename-Computer `
            -NewName $newName `
            -ErrorAction Stop

        Write-Log `
            -Message "Computador renomeado para $newName com sucesso." `
            -Level "SUCCESS"

        return $true
    }
    catch {

        Write-Log `
            -Message "Falha ao renomear computador: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}

function Test-SophosInstalled {

    $serviceNames = @(
        "Sophos Endpoint Defense Service",
        "Sophos File Scanner Service",
        "Sophos MCS Agent"
    )

    foreach ($serviceName in $serviceNames) {

        $service = Get-Service `
            -Name $serviceName `
            -ErrorAction SilentlyContinue

        if ($service) {
            return $true
        }
    }

    return $false
}

function Install-SophosEndpoint {

    $installerPath = "C:\EPSetup\Installers\SophosSetup.exe"

    Write-Log `
        -Message "Iniciando instalacao do Sophos Endpoint..." `
        -Level "INFO"

    if (-not (Test-Path $installerPath)) {

        Write-Log `
            -Message "Instalador do Sophos nao encontrado em $installerPath." `
            -Level "ERROR"

        throw "Instalador do Sophos nao encontrado."
    }

    try {

        $process = Start-Process `
            -FilePath $installerPath `
            -ArgumentList "--products=endpoint --quiet" `
            -Wait `
            -PassThru `
            -ErrorAction Stop

        if ($process.ExitCode -ne 0) {

            throw "Instalador do Sophos retornou o codigo $($process.ExitCode)."
        }

        Write-Log `
            -Message "Sophos Endpoint instalado com sucesso." `
            -Level "SUCCESS"

        return $true
    }
    catch {

        Write-Log `
            -Message "Falha ao instalar o Sophos Endpoint: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}