# ============================================================================
#
# EPSetup - System Tasks
#
# Tarefas relacionadas ao sistema operacional
#
# ============================================================================


# Configurações originais de energia
$script:OriginalPowerSettings = @{
    MonitorTimeoutAC = $null
    MonitorTimeoutDC = $null
}


# ============================================================================
# Windows Update
# ============================================================================

function Test-WindowsUpdateService {

    $service = Get-Service `
        -Name "wuauserv" `
        -ErrorAction SilentlyContinue

    return $null -ne $service
}


# ============================================================================
# Energia
# ============================================================================

function Save-PowerSettings {

    Write-Log `
        -Message "Salvando configuracoes atuais de energia..." `
        -Level "INFO"

    try {

        $output = powercfg /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 2>&1

        if ($LASTEXITCODE -ne 0) {
            throw "Nao foi possivel consultar as configuracoes de energia."
        }

        # Procura as linhas que possuem os indices atuais.
        # Nao depende do idioma do Windows.
        $currentSettings = $output |
            Where-Object {
                $_ -match "Atuais|Current" -and
                $_ -match "0x[0-9a-fA-F]+"
            }

        if ($currentSettings.Count -lt 2) {
            throw "Nao foi possivel identificar os tempos atuais do monitor."
        }

        # Primeiro valor = AC / tomada
        # Segundo valor = DC / bateria
        $acHex = [regex]::Match(
            $currentSettings[0],
            "0x[0-9a-fA-F]+"
        ).Value

        $dcHex = [regex]::Match(
            $currentSettings[1],
            "0x[0-9a-fA-F]+"
        ).Value

        if ([string]::IsNullOrWhiteSpace($acHex)) {
            throw "Nao foi possivel identificar o valor AC."
        }

        if ([string]::IsNullOrWhiteSpace($dcHex)) {
            throw "Nao foi possivel identificar o valor DC."
        }

        $script:OriginalPowerSettings.MonitorTimeoutAC =
            [Convert]::ToInt32(
                $acHex.Substring(2),
                16
            )

        $script:OriginalPowerSettings.MonitorTimeoutDC =
            [Convert]::ToInt32(
                $dcHex.Substring(2),
                16
            )

        Write-Log `
            -Message "Configuracao AC salva: $($script:OriginalPowerSettings.MonitorTimeoutAC) segundos." `
            -Level "INFO"

        Write-Log `
            -Message "Configuracao DC salva: $($script:OriginalPowerSettings.MonitorTimeoutDC) segundos." `
            -Level "INFO"

        return $true
    }
    catch {

        Write-Log `
            -Message "Falha ao salvar configuracoes de energia: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}

function Set-TemporaryPowerSettings {

    Write-Log `
        -Message "Aplicando configuracoes temporarias de energia..." `
        -Level "INFO"

    try {

        Save-PowerSettings

        # Nunca desligar o monitor quando conectado na tomada
        powercfg /change monitor-timeout-ac 0

        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao configurar timeout do monitor na tomada."
        }

        # Nunca desligar o monitor quando estiver na bateria
        powercfg /change monitor-timeout-dc 0

        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao configurar timeout do monitor na bateria."
        }

        Write-Log `
            -Message "Configuracoes temporarias de energia aplicadas." `
            -Level "SUCCESS"

        return $true
    }
    catch {

        Write-Log `
            -Message "Falha ao aplicar configuracoes temporarias: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}


function Restore-PowerSettings {

    Write-Log `
        -Message "Restaurando configuracoes originais de energia..." `
        -Level "INFO"

    try {

        if (
            $null -eq $script:OriginalPowerSettings.MonitorTimeoutAC -or
            $null -eq $script:OriginalPowerSettings.MonitorTimeoutDC
        ) {

            Write-Log `
                -Message "Configuracoes originais de energia nao foram encontradas." `
                -Level "WARNING"

            return $false
        }

        powercfg /change monitor-timeout-ac `
            $script:OriginalPowerSettings.MonitorTimeoutAC

        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao restaurar timeout do monitor na tomada."
        }

        powercfg /change monitor-timeout-dc `
            $script:OriginalPowerSettings.MonitorTimeoutDC

        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao restaurar timeout do monitor na bateria."
        }

        Write-Log `
            -Message "Configuracoes originais de energia restauradas." `
            -Level "SUCCESS"

        return
    }
    catch {

        Write-Log `
            -Message "Falha ao restaurar configuracoes de energia: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}


# ============================================================================
# Dominio
# ============================================================================

function Add-ComputerToDomain {

    param(
        [Parameter(Mandatory = $true)]
        [string]$DomainName
    )

    Write-Log `
        -Message "Verificando se o computador ja pertence ao dominio..." `
        -Level "INFO"

    $computerSystem = Get-CimInstance Win32_ComputerSystem

    if ($computerSystem.PartOfDomain) {

        Write-Log `
            -Message "Computador ja pertence ao dominio $($computerSystem.Domain)." `
            -Level "SKIPPED"

        return $true
    }

    Write-Log `
        -Message "Computador ainda nao pertence a um dominio." `
        -Level "INFO"

    Write-Host ""
    Write-Host "Credenciais do dominio" -ForegroundColor Cyan
    Write-Host "Informe uma conta autorizada a adicionar computadores ao dominio."
    Write-Host ""

    $credential = Get-Credential

    if (-not $credential) {
        throw "Credenciais do dominio nao foram fornecidas."
    }

    Write-Log `
        -Message "Adicionando computador ao dominio $DomainName..." `
        -Level "INFO"

    try {

        Add-Computer `
            -DomainName $DomainName `
            -Credential $credential `
            -ErrorAction Stop

        Write-Log `
            -Message "Computador adicionado ao dominio $DomainName com sucesso." `
            -Level "SUCCESS"

        return $true
    }
    catch {

        Write-Log `
            -Message "Falha ao adicionar computador ao dominio: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}


# ============================================================================
# Nome do computador
# ============================================================================

function Rename-EPComputer {

    $currentName = $env:COMPUTERNAME

    Write-Log `
        -Message "Nome atual do computador: $currentName" `
        -Level "INFO"

    $answer = Read-Host "Deseja alterar o nome do computador? (S/N)"

    if ($answer -notmatch "^[Ss]$") {

        Write-Log `
            -Message "Alteracao do nome do computador ignorada." `
            -Level "SKIPPED"

        return $true
    }

    do {

        $newName = Read-Host "Digite o novo nome do computador"

        if ([string]::IsNullOrWhiteSpace($newName)) {

            Write-Host `
                "O nome nao pode estar vazio." `
                -ForegroundColor Red

            continue
        }

        if ($newName.Length -gt 15) {

            Write-Host `
                "O nome nao pode ter mais de 15 caracteres." `
                -ForegroundColor Red

            continue
        }

        if ($newName -notmatch "^[a-zA-Z0-9-]+$") {

            Write-Host `
                "Use apenas letras, numeros e hifen." `
                -ForegroundColor Red

            continue
        }

        break

    } while ($true)

    if ($newName -ieq $currentName) {

        Write-Log `
            -Message "O nome informado e igual ao nome atual." `
            -Level "SKIPPED"

        return $true
    }

    Write-Log `
        -Message "Renomeando computador para $newName..." `
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


# ============================================================================
# Delegacao de credenciais
# ============================================================================

function Set-CredentialDelegationPolicy {

    Write-Log `
        -Message "Configuracao de delegacao de credenciais..." `
        -Level "INFO"

    $answer = Read-Host "Deseja configurar a delegacao de credenciais? (S/N)"

    if ($answer -notmatch "^[Ss]$") {

        Write-Log `
            -Message "Configuracao de delegacao de credenciais ignorada." `
            -Level "SKIPPED"

        return $true
    }

    $registryPath =
        "HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation"

    $valueName = "AllowSavedCredentialsWhenNTLMOnly"
    $spn = "TERMSRV/*"

    try {

        # Cria a chave caso ela nao exista
        if (-not (Test-Path $registryPath)) {

            New-Item `
                -Path $registryPath `
                -Force `
                -ErrorAction Stop | Out-Null
        }

        # Configura TERMSRV/*
        New-ItemProperty `
            -Path $registryPath `
            -Name $valueName `
            -PropertyType MultiString `
            -Value @($spn) `
            -Force `
            -ErrorAction Stop | Out-Null

        # Habilita a concatenacao dos valores padrao
        New-ItemProperty `
            -Path $registryPath `
            -Name "ConcatenateDefaults_AllowSavedNTLMOnly" `
            -PropertyType DWord `
            -Value 1 `
            -Force `
            -ErrorAction Stop | Out-Null

        # Verifica a configuracao
        $policy = Get-ItemProperty `
            -Path $registryPath `
            -ErrorAction Stop

        $servers = $policy.$valueName
        $concatenate =
            $policy.ConcatenateDefaults_AllowSavedNTLMOnly

        if (
            ($servers -contains $spn) -and
            ($concatenate -eq 1)
        ) {

            Write-Log `
                -Message "Delegacao de credenciais configurada para $spn." `
                -Level "SUCCESS"

            return $true
        }

        throw "A verificacao da politica de delegacao falhou."
    }
    catch {

        Write-Log `
            -Message "Falha ao configurar delegacao de credenciais: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}

function Set-CurrentUserPassword {

    $username = $env:USERNAME

    $answer = Read-Host "Deseja alterar a senha do usuario $username? (S/N)"

    if ($answer -notmatch "^[Ss]$") {

        Write-Log `
            -Message "Alteracao da senha do usuario ignorada." `
            -Level "SKIPPED"

        return
    }

    Write-Log `
        -Message "Alteracao da senha do usuario $username..." `
        -Level "INFO"

    $password = Read-Host `
        "Digite a nova senha" `
        -AsSecureString

    if (-not $password) {
        throw "Nenhuma senha foi informada."
    }

    try {

        Set-LocalUser `
            -Name $username `
            -Password $password `
            -ErrorAction Stop

        Write-Log `
            -Message "Senha do usuario $username alterada com sucesso." `
            -Level "SUCCESS"
    }
    catch {

        Write-Log `
            -Message "Falha ao alterar senha do usuario $username`: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}

# ============================================================================
# Validação final do provisionamento
# ============================================================================

function Test-FinalSetup {

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " VALIDACAO FINAL" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    $successCount = 0
    $failureCount = 0
    $skippedCount = 0

    function Test-ValidationResult {

        param(
            [string]$Name,
            [bool]$Result
        )

        if ($Result) {

            Write-Host "[OK]       $Name" -ForegroundColor Green
            return "SUCCESS"
        }

        Write-Host "[FALHA]    $Name" -ForegroundColor Red
        return "FAILURE"
    }


    # =========================================================================
    # Internet
    # =========================================================================

    $result = Test-ValidationResult `
        -Name "Conexao com a Internet" `
        -Result (Test-InternetConnection)

    if ($result -eq "SUCCESS") {
        $successCount++
    }
    else {
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
    # Sophos Endpoint
    # =========================================================================

    if (Test-SophosInstalled) {

        Write-Host "[OK]       Sophos Endpoint" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[FALHA]    Sophos Endpoint" `
            -ForegroundColor Red

        $failureCount++
    }


    # =========================================================================
    # Google Chrome
    # =========================================================================

    if (Test-SoftwareInstalled -SoftwareName "Chrome") {

        Write-Host "[OK]       Google Chrome" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[FALHA]    Google Chrome" `
            -ForegroundColor Red

        $failureCount++
    }


    # =========================================================================
    # Mozilla Firefox
    # =========================================================================

    if (Test-SoftwareInstalled -SoftwareName "Mozilla Firefox") {

        Write-Host "[OK]       Mozilla Firefox" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[FALHA]    Mozilla Firefox" `
            -ForegroundColor Red

        $failureCount++
    }


    # =========================================================================
    # WinRAR
    # =========================================================================

    if (Test-SoftwareInstalled -SoftwareName "WinRAR") {

        Write-Host "[OK]       WinRAR" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[FALHA]    WinRAR" `
            -ForegroundColor Red

        $failureCount++
    }


    # =========================================================================
    # AnyDesk
    # =========================================================================

    if (Test-SoftwareInstalled -SoftwareName "AnyDesk") {

        Write-Host "[OK]       AnyDesk" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[FALHA]    AnyDesk" `
            -ForegroundColor Red

        $failureCount++
    }


    # =========================================================================
    # Microsoft Teams
    # =========================================================================

    if (Test-SoftwareInstalled -SoftwareName "Microsoft Teams") {

        Write-Host "[OK]       Microsoft Teams" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[FALHA]    Microsoft Teams" `
            -ForegroundColor Red

        $failureCount++
    }


    # =========================================================================
    # PDFCreator
    # =========================================================================

    if (Test-SoftwareInstalled -SoftwareName "PDFCreator") {

        Write-Host "[OK]       PDFCreator" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[FALHA]    PDFCreator" `
            -ForegroundColor Red

        $failureCount++
    }


    # =========================================================================
    # GLPI Agent
    # =========================================================================

    if (Test-Path "C:\Program Files\GLPI-Agent\glpi-agent.bat") {

        Write-Host "[OK]       GLPI Agent" `
            -ForegroundColor Green

        $successCount++
    }
    else {

        Write-Host "[FALHA]    GLPI Agent" `
            -ForegroundColor Red

        $failureCount++
    }


    # =========================================================================
    # Domínio
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

        Write-Log `
            -Message "Validacao final concluida sem falhas." `
            -Level "SUCCESS"

        return $true
    }

    Write-Log `
        -Message "Validacao final concluida com $failureCount falha(s)." `
        -Level "ERROR"

    return $false
}