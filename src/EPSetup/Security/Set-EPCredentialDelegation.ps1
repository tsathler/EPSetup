# ============================================================================
#
# EPSetup - Credential Delegation
#
# Configura a delegacao de credenciais do Windows
#
# ============================================================================


function Set-EPCredentialDelegation {

    Write-EPSetupLog `
        -Message "Configuracao de delegacao de credenciais..." `
        -Level "INFO"

    $answer = Read-Host `
        "Deseja configurar a delegacao de credenciais? (S/N)"

    if ($answer -notmatch "^[Ss]$") {

        Write-EPSetupLog `
            -Message "Configuracao de delegacao de credenciais ignorada." `
            -Level "SKIPPED"

        return $true
    }

    $registryPath =
        "HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation"

    $valueName = "AllowSavedCredentialsWhenNTLMOnly"
    $spn = "TERMSRV/*"

    try {

        if (-not (Test-Path $registryPath)) {

            New-Item `
                -Path $registryPath `
                -Force `
                -ErrorAction Stop | Out-Null
        }

        New-ItemProperty `
            -Path $registryPath `
            -Name $valueName `
            -PropertyType MultiString `
            -Value @($spn) `
            -Force `
            -ErrorAction Stop | Out-Null

        New-ItemProperty `
            -Path $registryPath `
            -Name "ConcatenateDefaults_AllowSavedNTLMOnly" `
            -PropertyType DWord `
            -Value 1 `
            -Force `
            -ErrorAction Stop | Out-Null

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

            Write-EPSetupLog `
                -Message "Delegacao de credenciais configurada para $spn." `
                -Level "SUCCESS"

            return $true
        }

        throw "A verificacao da politica de delegacao falhou."
    }
    catch {

        Write-EPSetupLog `
            -Message "Falha ao configurar delegacao de credenciais: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}
