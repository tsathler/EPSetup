# ============================================================================
#
# EPSetup - System Tasks
#
# Tarefas relacionadas ao sistema operacional
#
# ============================================================================


# Verifica se o serviço do Windows Update existe
function Test-WindowsUpdateService {

    $service = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue

    return $null -ne $service
}

# Configura as opcoes de energia do computador
function Configure-PowerSettings {

    powercfg /change monitor-timeout-ac 0
    powercfg /change standby-timeout-ac 0

    return $true
}

# Adiciona o computador ao dominio
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