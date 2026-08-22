# ============================================================================
#
# WindowsProvisioningToolkit - User Password
#
# Gerencia a senha do usuario local atual
#
# ============================================================================


function Set-WPTUserPassword {

    $username = $env:USERNAME

    $answer = Read-Host `
        "Deseja alterar a senha do usuario $username? (S/N)"

    if ($answer -notmatch "^[Ss]$") {

        Write-WPTLog `
            -Message "Alteracao da senha do usuario ignorada." `
            -Level "SKIPPED"

        return $true
    }

    Write-WPTLog `
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

        Write-WPTLog `
            -Message "Senha do usuario $username alterada com sucesso." `
            -Level "SUCCESS"

        return $true
    }
    catch {

        Write-WPTLog `
            -Message "Falha ao alterar senha do usuario $username`: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}
