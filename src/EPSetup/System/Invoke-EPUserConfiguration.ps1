# ============================================================================
#
# EPSetup - User Configuration
#
# Detecta e configura a conta de usuario atual quando a operacao e suportada
#
# ============================================================================

function Get-EPCurrentUser {

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $identityName = $identity.Name
    $accountParts = $identityName -split "\\", 2

    $accountDomain = if ($accountParts.Count -eq 2) { $accountParts[0] } else { $env:USERDOMAIN }
    $accountName = if ($accountParts.Count -eq 2) { $accountParts[1] } else { $env:USERNAME }
    $profilePath = $env:USERPROFILE

    $accountType = "Desconhecida"
    $displayName = ""
    $localUser = $null

    try {
        $localUser = Get-LocalUser `
            -Name $accountName `
            -ErrorAction SilentlyContinue
    }
    catch {
        $localUser = $null
    }

    if ($localUser -and ($accountDomain -ieq $env:COMPUTERNAME)) {
        $accountType = "Local"
        $displayName = $localUser.FullName
    }
    elseif ($accountDomain -ieq "MicrosoftAccount") {
        $accountType = "Conta Microsoft"
    }
    elseif (-not [string]::IsNullOrWhiteSpace($accountDomain)) {
        $accountType = "Dominio"
    }

    return [pscustomobject]@{
        Identity = $identityName
        Domain = $accountDomain
        Name = $accountName
        DisplayName = $displayName
        AccountType = $accountType
        ProfilePath = $profilePath
        IsLocal = ($accountType -eq "Local")
    }
}


function Show-EPCurrentUserInfo {

    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$User
    )

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "              USUARIO" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usuario atual: $($User.Name)"
    Write-Host "Tipo da conta: $($User.AccountType)"
    Write-Host "Dominio/origem: $($User.Domain)"

    if (-not [string]::IsNullOrWhiteSpace($User.DisplayName)) {
        Write-Host "Nome de exibicao: $($User.DisplayName)"
    }

    Write-Host "Perfil: $($User.ProfilePath)"
    Write-Host ""
}


function Test-EPLocalUserName {

    param(
        [Parameter(Mandatory = $true)]
        [string]$UserName
    )

    if ([string]::IsNullOrWhiteSpace($UserName)) {
        throw "O nome do usuario nao pode estar vazio."
    }

    if ($UserName.Length -gt 20) {
        throw "O nome do usuario nao pode possuir mais de 20 caracteres."
    }

    if ($UserName -match '[\\/:*?"<>|@]') {
        throw "O nome do usuario possui caracteres invalidos."
    }

    return $true
}


function Rename-EPCurrentLocalUser {

    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$User
    )

    if (-not $User.IsLocal) {
        Write-EPSetupLog `
            -Message "Alteracao de nome ignorada: a conta atual nao e local." `
            -Level "SKIPPED"

        return "SKIPPED"
    }

    $answer = Read-Host "Deseja alterar o nome do usuario? (S/N)"

    if ($answer -notmatch "^[Ss]$") {
        Write-EPSetupLog `
            -Message "Alteracao do nome do usuario ignorada." `
            -Level "SKIPPED"

        return "SKIPPED"
    }

    $newName = Read-Host "Novo nome"
    Test-EPLocalUserName -UserName $newName | Out-Null

    if ($newName -ieq $User.Name) {
        Write-EPSetupLog `
            -Message "Novo nome igual ao usuario atual. Alteracao ignorada." `
            -Level "SKIPPED"

        return "SKIPPED"
    }

    $existingUser = Get-LocalUser `
        -Name $newName `
        -ErrorAction SilentlyContinue

    if ($existingUser) {
        throw "Ja existe um usuario local chamado $newName."
    }

    Write-Host ""
    Write-Host "Usuario atual: $($User.Name)"
    Write-Host "Novo usuario: $newName"
    Write-Host ""

    $confirmation = Read-Host "Confirmar alteracao? (S/N)"

    if ($confirmation -notmatch "^[Ss]$") {
        Write-EPSetupLog `
            -Message "Alteracao do nome do usuario cancelada na confirmacao." `
            -Level "SKIPPED"

        return "SKIPPED"
    }

    Rename-LocalUser `
        -Name $User.Name `
        -NewName $newName `
        -ErrorAction Stop

    Write-EPSetupLog `
        -Message "Nome do usuario local alterado de $($User.Name) para $newName." `
        -Level "SUCCESS"

    return $true
}


function Test-EPSecureStringEqual {

    param(
        [Parameter(Mandatory = $true)]
        [securestring]$First,

        [Parameter(Mandatory = $true)]
        [securestring]$Second
    )

    $firstPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($First)
    $secondPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Second)

    try {
        $firstText = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($firstPointer)
        $secondText = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($secondPointer)

        return ($firstText -ceq $secondText)
    }
    finally {
        if ($firstPointer -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($firstPointer)
        }

        if ($secondPointer -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($secondPointer)
        }
    }
}


function Set-EPCurrentLocalUserPassword {

    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$User
    )

    if (-not $User.IsLocal) {
        Write-EPSetupLog `
            -Message "Alteracao de senha ignorada: a conta atual nao e local." `
            -Level "SKIPPED"

        return "SKIPPED"
    }

    $answer = Read-Host "Deseja alterar a senha do usuario atual? (S/N)"

    if ($answer -notmatch "^[Ss]$") {
        Write-EPSetupLog `
            -Message "Alteracao de senha do usuario ignorada." `
            -Level "SKIPPED"

        return "SKIPPED"
    }

    $password = Read-Host "Nova senha" -AsSecureString
    $confirmation = Read-Host "Confirmar nova senha" -AsSecureString

    if (-not $password -or $password.Length -eq 0) {
        throw "Nenhuma senha foi informada."
    }

    if (-not (Test-EPSecureStringEqual -First $password -Second $confirmation)) {
        throw "A confirmacao da senha nao confere."
    }

    Set-LocalUser `
        -Name $User.Name `
        -Password $password `
        -ErrorAction Stop

    Write-EPSetupLog `
        -Message "Senha do usuario local $($User.Name) alterada com sucesso." `
        -Level "SUCCESS"

    return $true
}


function Invoke-EPUserConfiguration {

    Write-EPSetupLog `
        -Message "Iniciando configuracao do usuario atual." `
        -Level "INFO"

    $user = Get-EPCurrentUser

    Show-EPCurrentUserInfo -User $user

    Write-EPSetupLog `
        -Message "Usuario atual identificado: $($user.Name) ($($user.AccountType))." `
        -Level "INFO"

    $renameResult = Rename-EPCurrentLocalUser -User $user

    $updatedUser = Get-EPCurrentUser

    $passwordResult = Set-EPCurrentLocalUserPassword -User $updatedUser

    if (($renameResult -eq "SKIPPED") -and ($passwordResult -eq "SKIPPED")) {
        Write-EPSetupLog `
            -Message "Configuracao do usuario ignorada: nenhuma alteracao aplicavel ou solicitada." `
            -Level "SKIPPED"

        return "SKIPPED"
    }

    Write-EPSetupLog `
        -Message "Configuracao do usuario finalizada." `
        -Level "SUCCESS"

    return $true
}
