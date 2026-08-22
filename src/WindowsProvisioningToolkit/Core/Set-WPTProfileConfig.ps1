# ============================================================================
#
# WindowsProvisioningToolkit - Profile Configuration
#
# Gerencia configuracao local Portfolio/Corporate
#
# ============================================================================

function Get-WPTCorporateLocalConfigPath {

    return Join-Path `
        -Path (Get-WPTConfigRoot) `
        -ChildPath "Corporate.local.json"
}


function Get-WPTCorporateExampleConfigPath {

    return Join-Path `
        -Path (Get-WPTConfigRoot) `
        -ChildPath "Corporate.example.json"
}


function Test-WPTCorporateLocalConfig {

    return (Test-Path -LiteralPath (Get-WPTCorporateLocalConfigPath))
}


function Show-WPTActiveProfile {

    $config = Get-WPTConfig
    $corporateLocalExists = Test-WPTCorporateLocalConfig

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "          PERFIL ATIVO" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Perfil: $($config.Profile.Name)"
    Write-Host "Modo: $($config.Profile.Mode)"
    Write-Host "Corporate local: $(if ($corporateLocalExists) { 'Configurado' } else { 'Nao configurado' })"
    Write-Host "Dominio sugerido: $($config.System.Domain.DefaultDomainName)"
    Write-Host "Sugerir dominio: $($config.System.Domain.SuggestDefaultDomain)"
    Write-Host "Entrada automatica no dominio: $($config.System.Domain.AutoJoin)"
    Write-Host ""

    Write-WPTLog `
        -Message "Perfil ativo exibido: $($config.Profile.Name)." `
        -Level "INFO"
}


function Set-WPTCorporateLocalConfig {

    $corporateLocalPath = Get-WPTCorporateLocalConfigPath
    $corporateExamplePath = Get-WPTCorporateExampleConfigPath

    if (-not (Test-Path -LiteralPath $corporateLocalPath)) {
        if (-not (Test-Path -LiteralPath $corporateExamplePath)) {
            throw "Arquivo modelo Corporate.example.json nao encontrado."
        }

        Copy-Item `
            -LiteralPath $corporateExamplePath `
            -Destination $corporateLocalPath `
            -Force `
            -ErrorAction Stop

        Write-WPTLog `
            -Message "Arquivo Corporate.local.json criado a partir do modelo." `
            -Level "INFO"
    }

    $domainName = Read-Host "Dominio padrao sugerido"

    if (-not [string]::IsNullOrWhiteSpace($domainName)) {
        Test-WPTDomainName -DomainName $domainName | Out-Null
    }

    $suggestDomain = $false

    if (-not [string]::IsNullOrWhiteSpace($domainName)) {
        $suggestAnswer = Read-Host "Sugerir esse dominio nos fluxos? (S/N)"
        $suggestDomain = ($suggestAnswer -match "^[Ss]$")
    }

    $corporateConfig = [ordered]@{
        Profile = [ordered]@{
            Name = "Corporate"
            Mode = "Local"
        }
        System = [ordered]@{
            Domain = [ordered]@{
                DefaultDomainName = $domainName
                SuggestDefaultDomain = $suggestDomain
                AutoJoin = $false
            }
        }
    }

    $corporateConfig |
        ConvertTo-Json -Depth 10 |
        Set-Content `
            -LiteralPath $corporateLocalPath `
            -Encoding UTF8 `
            -ErrorAction Stop

    Write-WPTLog `
        -Message "Perfil Corporate local configurado. AutoJoin permanece desabilitado." `
        -Level "SUCCESS"

    Write-Host ""
    Write-Host "Perfil Corporate local configurado." -ForegroundColor Green
    Write-Host "O dominio sera apenas sugerido. Nenhuma maquina sera adicionada automaticamente." -ForegroundColor Yellow
    Write-Host ""
}


function Clear-WPTCorporateLocalConfig {

    $corporateLocalPath = Get-WPTCorporateLocalConfigPath

    if (-not (Test-Path -LiteralPath $corporateLocalPath)) {
        Write-WPTLog `
            -Message "Nenhuma configuracao Corporate local encontrada para limpar." `
            -Level "SKIPPED"

        Write-Host ""
        Write-Host "Nenhuma configuracao Corporate local encontrada." -ForegroundColor Yellow
        Write-Host ""

        return "SKIPPED"
    }

    $answer = Read-Host "Remover Corporate.local.json e voltar ao perfil Portfolio? (S/N)"

    if ($answer -notmatch "^[Ss]$") {
        Write-WPTLog `
            -Message "Limpeza da configuracao Corporate local cancelada." `
            -Level "SKIPPED"

        return "SKIPPED"
    }

    Remove-Item `
        -LiteralPath $corporateLocalPath `
        -Force `
        -ErrorAction Stop

    Write-WPTLog `
        -Message "Configuracao Corporate local removida. Perfil Portfolio sera usado." `
        -Level "SUCCESS"

    Write-Host ""
    Write-Host "Configuracao Corporate local removida." -ForegroundColor Green
    Write-Host "O WindowsProvisioningToolkit voltara a usar o perfil Portfolio." -ForegroundColor Green
    Write-Host ""

    return $true
}
