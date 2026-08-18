# ============================================================================
#
# EPSetup - Credential Delegation
#
# Configura a delegacao de credenciais salvas para RDP via politica local
#
# ============================================================================

$script:EPCredentialDelegationPolicyPath =
    "HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation"

$script:EPCredentialDelegationListPath =
    "HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation\AllowSavedCredentialsWhenNTLMOnly"

$script:EPCredentialDelegationPolicyName =
    "AllowSavedCredentialsWhenNTLMOnly"

$script:EPCredentialDelegationConcatName =
    "ConcatenateDefaults_AllowSavedNTLMOnly"

$script:EPCredentialDelegationDefaultSpn =
    "TERMSRV/*"


function Get-EPCredentialDelegationState {

    $policyEnabled = $false
    $concatenateDefaults = $false
    $servers = @()

    if (Test-Path -LiteralPath $script:EPCredentialDelegationPolicyPath) {
        $policy = Get-ItemProperty `
            -LiteralPath $script:EPCredentialDelegationPolicyPath `
            -ErrorAction SilentlyContinue

        $policyValue =
            $policy.PSObject.Properties[$script:EPCredentialDelegationPolicyName].Value

        $concatValue =
            $policy.PSObject.Properties[$script:EPCredentialDelegationConcatName].Value

        $policyEnabled = [bool]($policyValue -eq 1)
        $concatenateDefaults = [bool]($concatValue -eq 1)
    }

    if (Test-Path -LiteralPath $script:EPCredentialDelegationListPath) {
        $listKey = Get-Item `
            -LiteralPath $script:EPCredentialDelegationListPath `
            -ErrorAction SilentlyContinue

        if ($listKey) {
            $servers = @(
                foreach ($valueName in $listKey.GetValueNames()) {
                    $listKey.GetValue($valueName)
                }
            ) |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            }
        }
    }

    return [pscustomobject]@{
        PolicyEnabled = $policyEnabled
        ConcatenateDefaults = $concatenateDefaults
        Servers = @($servers)
    }
}


function Test-EPCredentialDelegation {

    param(
        [string]$Server = $script:EPCredentialDelegationDefaultSpn
    )

    $state = Get-EPCredentialDelegationState

    return (
        $state.PolicyEnabled -and
        $state.ConcatenateDefaults -and
        ($state.Servers -contains $Server)
    )
}


function Set-EPCredentialDelegation {

    param(
        [string]$Server = $script:EPCredentialDelegationDefaultSpn,

        [switch]$Prompt
    )

    Write-EPSetupLog `
        -Message "Verificando delegacao de credenciais RDP..." `
        -Level "INFO"

    if ($Prompt) {
        $answer = Read-Host "Deseja configurar a delegacao de credenciais RDP? (S/N)"

        if ($answer -notmatch "^[Ss]$") {
            Write-EPSetupLog `
                -Message "Configuracao de delegacao de credenciais ignorada pelo usuario." `
                -Level "SKIPPED"

            return $true
        }
    }

    if (Test-EPCredentialDelegation -Server $Server) {
        Write-EPSetupLog `
            -Message "Delegacao de credenciais RDP ja configurada para $Server." `
            -Level "SKIPPED"

        return $true
    }

    try {
        if (-not (Test-Path -LiteralPath $script:EPCredentialDelegationPolicyPath)) {
            New-Item `
                -Path $script:EPCredentialDelegationPolicyPath `
                -Force `
                -ErrorAction Stop |
            Out-Null
        }

        if (-not (Test-Path -LiteralPath $script:EPCredentialDelegationListPath)) {
            New-Item `
                -Path $script:EPCredentialDelegationListPath `
                -Force `
                -ErrorAction Stop |
            Out-Null
        }

        New-ItemProperty `
            -Path $script:EPCredentialDelegationPolicyPath `
            -Name $script:EPCredentialDelegationPolicyName `
            -PropertyType DWord `
            -Value 1 `
            -Force `
            -ErrorAction Stop |
        Out-Null

        New-ItemProperty `
            -Path $script:EPCredentialDelegationPolicyPath `
            -Name $script:EPCredentialDelegationConcatName `
            -PropertyType DWord `
            -Value 1 `
            -Force `
            -ErrorAction Stop |
        Out-Null

        $state = Get-EPCredentialDelegationState

        if ($state.Servers -notcontains $Server) {
            $nextIndex = 1

            if ($state.Servers.Count -gt 0) {
                $listKey = Get-Item `
                    -LiteralPath $script:EPCredentialDelegationListPath `
                    -ErrorAction Stop

                $numericNames = @(
                    $listKey.GetValueNames() |
                    Where-Object { $_ -match "^\d+$" } |
                    ForEach-Object { [int]$_ }
                )

                if ($numericNames.Count -gt 0) {
                    $nextIndex = (($numericNames | Measure-Object -Maximum).Maximum + 1)
                }
            }

            New-ItemProperty `
                -Path $script:EPCredentialDelegationListPath `
                -Name ([string]$nextIndex) `
                -PropertyType String `
                -Value $Server `
                -Force `
                -ErrorAction Stop |
            Out-Null
        }

        if (-not (Test-EPCredentialDelegation -Server $Server)) {
            throw "A validacao da politica de delegacao falhou."
        }

        Write-EPSetupLog `
            -Message "Delegacao de credenciais RDP configurada para $Server." `
            -Level "SUCCESS"

        return $true
    }
    catch {
        Write-EPSetupLog `
            -Message "Falha ao configurar delegacao de credenciais RDP: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}
