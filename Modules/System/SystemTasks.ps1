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
            Write-Host "O nome nao pode estar vazio." -ForegroundColor Red
            continue
        }

        if ($newName.Length -gt 15) {
            Write-Host "O nome nao pode ter mais de 15 caracteres." -ForegroundColor Red
            continue
        }

        if ($newName -notmatch "^[a-zA-Z0-9-]+$") {
            Write-Host "Use apenas letras, numeros e hifen." -ForegroundColor Red
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

function Set-CredentialDelegationPolicy {

    $registryPath = "HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation"

    Write-Log `
        -Message "Configurando delegacao de credenciais..." `
        -Level "INFO"

    try {

        if (-not (Test-Path $registryPath)) {
            New-Item `
                -Path $registryPath `
                -Force | Out-Null
        }

        New-ItemProperty `
            -Path $registryPath `
            -Name "AllowSavedCredentialsWhenNTLMOnly" `
            -PropertyType DWord `
            -Value 1 `
            -Force | Out-Null

        Write-Log `
            -Message "Politica de delegacao de credenciais habilitada." `
            -Level "SUCCESS"

        return $true
    }
    catch {

        Write-Log `
            -Message "Falha ao configurar delegacao de credenciais: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}

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

    $registryPath = "HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation"
    $valueName = "AllowSavedCredentialsWhenNTLMOnly"
    $spn = "TERMSRV/*"

    try {

        # Cria a chave caso nao exista
        if (-not (Test-Path $registryPath)) {

            New-Item `
                -Path $registryPath `
                -Force `
                -ErrorAction Stop | Out-Null
        }

        # Configura a politica como REG_MULTI_SZ
        New-ItemProperty `
            -Path $registryPath `
            -Name $valueName `
            -PropertyType MultiString `
            -Value @($spn) `
            -Force `
            -ErrorAction Stop | Out-Null

        # Verifica a configuracao
        $policy = Get-ItemProperty `
            -Path $registryPath `
            -Name $valueName `
            -ErrorAction Stop

        if ($policy.$valueName -contains $spn) {

            Write-Log `
                -Message "Delegacao de credenciais configurada para $spn." `
                -Level "SUCCESS"

            return $true
        }

        throw "A politica foi configurada, mas a verificacao falhou."
    }
    catch {

        Write-Log `
            -Message "Falha ao configurar delegacao de credenciais: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}