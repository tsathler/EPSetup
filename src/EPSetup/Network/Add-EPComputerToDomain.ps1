# ============================================================================
#
# EPSetup - Add Computer To Domain
#
# Adiciona o computador ao domínio especificado
#
# ============================================================================


function Add-EPComputerToDomain {

    param(
        [Parameter(Mandatory = $true)]
        [string]$DomainName
    )


    Write-EPSetupLog `
        -Message "Verificando se o computador ja pertence ao dominio..." `
        -Level "INFO"


    $computerSystem = Get-CimInstance Win32_ComputerSystem


    if ($computerSystem.PartOfDomain) {

        Write-EPSetupLog `
            -Message "Computador ja pertence ao dominio $($computerSystem.Domain)." `
            -Level "SKIPPED"

        return $true
    }


    Write-EPSetupLog `
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


        return $true
    }
    catch {

        Write-EPSetupLog `
            -Message "Falha ao adicionar computador ao dominio: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}
