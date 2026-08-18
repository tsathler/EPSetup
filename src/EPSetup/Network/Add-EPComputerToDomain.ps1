# ============================================================================
#
# EPSetup - Add Computer To Domain
#
# Adiciona o computador a um dominio informado pelo usuario
#
# ============================================================================

function Get-EPComputerDomainState {

    try {
        $computerSystem = Get-CimInstance `
            -ClassName Win32_ComputerSystem `
            -ErrorAction Stop
    }
    catch {
        $computerSystem = Get-WmiObject `
            -Class Win32_ComputerSystem `
            -ErrorAction Stop
    }

    return [pscustomobject]@{
        ComputerName = $env:COMPUTERNAME
        PartOfDomain = [bool]$computerSystem.PartOfDomain
        Domain = $computerSystem.Domain
        Workgroup = $computerSystem.Workgroup
    }
}


function Test-EPDomainName {

    param(
        [Parameter(Mandatory = $true)]
        [string]$DomainName
    )

    if ([string]::IsNullOrWhiteSpace($DomainName)) {
        throw "O dominio nao pode estar vazio."
    }

    if ($DomainName -notmatch "^[a-zA-Z0-9.-]+$") {
        throw "O dominio informado possui caracteres invalidos."
    }

    if ($DomainName.StartsWith(".") -or $DomainName.EndsWith(".")) {
        throw "O dominio nao pode comecar ou terminar com ponto."
    }

    return $true
}


function Add-EPComputerToDomain {

    param(
        [string]$DomainName,

        [switch]$Prompt,

        [switch]$SuppressRestartPrompt
    )

    Write-EPSetupLog `
        -Message "Verificando associacao do computador ao dominio..." `
        -Level "INFO"

    if ($Prompt) {
        $answer = Read-Host "Deseja adicionar este computador ao dominio? (S/N)"

        if ($answer -notmatch "^[Ss]$") {
            Write-EPSetupLog `
                -Message "Entrada no dominio ignorada pelo usuario." `
                -Level "SKIPPED"

            return "SKIPPED"
        }
    }

    if ([string]::IsNullOrWhiteSpace($DomainName)) {
        $DomainName = Read-Host "Digite o dominio"
    }

    Test-EPDomainName -DomainName $DomainName | Out-Null

    $domainState = Get-EPComputerDomainState

    if ($domainState.PartOfDomain) {
        if ($domainState.Domain -ieq $DomainName) {
            Write-EPSetupLog `
                -Message "Computador ja pertence ao dominio $DomainName." `
                -Level "SKIPPED"

            return "SKIPPED"
        }

        throw "Computador ja pertence ao dominio $($domainState.Domain). Remova ou migre manualmente antes de adicionar a outro dominio."
    }

    Write-EPSetupLog `
        -Message "Computador ainda nao pertence a um dominio. Dominio atual/workgroup: $($domainState.Domain)." `
        -Level "INFO"

    Write-Host ""
    Write-Host "Credenciais administrativas do dominio" -ForegroundColor Cyan
    Write-Host "Informe uma conta autorizada a adicionar computadores ao dominio."
    Write-Host ""

    $credential = Get-Credential `
        -Message "Credenciais para adicionar o computador ao dominio $DomainName"

    if (-not $credential) {
        throw "Credenciais do dominio nao foram fornecidas."
    }

    Write-EPSetupLog `
        -Message "Adicionando computador ao dominio $DomainName..." `
        -Level "INFO"

    try {
        Add-Computer `
            -DomainName $DomainName `
            -Credential $credential `
            -ErrorAction Stop

        Write-EPSetupLog `
            -Message "Computador adicionado ao dominio $DomainName com sucesso." `
            -Level "SUCCESS"

        Write-EPSetupLog `
            -Message "Reinicializacao necessaria para concluir a entrada no dominio." `
            -Level "WARNING"

        Set-EPRestartRequired `
            -Reason "Entrada no dominio $DomainName"

        if (-not $SuppressRestartPrompt) {
            Show-EPRestartPrompt
        }

        return $true
    }
    catch {
        Write-EPSetupLog `
            -Message "Falha ao adicionar computador ao dominio: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}


function Show-EPRestartPrompt {

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "        REINICIALIZACAO NECESSARIA" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Algumas alteracoes precisam de reinicializacao."
    Write-Host ""
    Write-Host "[1] Reiniciar agora"
    Write-Host "[2] Reiniciar depois"
    Write-Host ""

    $option = Read-Host "Digite uma opcao"

    if ($option -eq "1") {
        Write-EPSetupLog `
            -Message "Reinicializacao solicitada pelo usuario." `
            -Level "WARNING"

        Restart-Computer
        return
    }

    Write-EPSetupLog `
        -Message "Reinicializacao adiada pelo usuario." `
        -Level "WARNING"
}
