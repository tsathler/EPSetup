# ============================================================================
#
# WindowsProvisioningToolkit - Credential Delegation
#
# Configura a delegacao de credenciais salvas para RDP via politica local
#
# ============================================================================

$script:WPTCredentialDelegationPolicyPath =
    "HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation"

$script:WPTCredentialDelegationListPath =
    "HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation\AllowSavedCredentialsWhenNTLMOnly"

$script:WPTCredentialDelegationPolicyName =
    "AllowSavedCredentialsWhenNTLMOnly"

$script:WPTCredentialDelegationConcatName =
    "ConcatenateDefaults_AllowSavedNTLMOnly"

$script:WPTCredentialDelegationDefaultSpn =
    "TERMSRV/*"


function Get-WPTCredentialDelegationState {

    $policyEnabled = $false
    $concatenateDefaults = $false
    $servers = @()

    if (Test-Path -LiteralPath $script:WPTCredentialDelegationPolicyPath) {
        $policy = Get-ItemProperty `
            -LiteralPath $script:WPTCredentialDelegationPolicyPath `
            -ErrorAction SilentlyContinue

        $policyValue =
            $policy.PSObject.Properties[$script:WPTCredentialDelegationPolicyName].Value

        $concatValue =
            $policy.PSObject.Properties[$script:WPTCredentialDelegationConcatName].Value

        $policyEnabled = [bool]($policyValue -eq 1)
        $concatenateDefaults = [bool]($concatValue -eq 1)
    }

    if (Test-Path -LiteralPath $script:WPTCredentialDelegationListPath) {
        $listKey = Get-Item `
            -LiteralPath $script:WPTCredentialDelegationListPath `
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


function Test-WPTCredentialDelegation {

    param(
        [string]$Server = $script:WPTCredentialDelegationDefaultSpn
    )

    $state = Get-WPTCredentialDelegationState

    return (
        $state.PolicyEnabled -and
        $state.ConcatenateDefaults -and
        ($state.Servers -contains $Server)
    )
}


function Set-WPTCredentialDelegation {

    param(
        [string]$Server = $script:WPTCredentialDelegationDefaultSpn,

        [switch]$Prompt
    )

    Write-WPTLog `
        -Message "Verificando delegacao de credenciais RDP..." `
        -Level "INFO"

    if ($Prompt) {
        $answer = Read-Host "Deseja configurar a delegacao de credenciais RDP? (S/N)"

        if ($answer -notmatch "^[Ss]$") {
            Write-WPTLog `
                -Message "Configuracao de delegacao de credenciais ignorada pelo usuario." `
                -Level "SKIPPED"

            return $true
        }
    }

    if (Test-WPTCredentialDelegation -Server $Server) {
        Write-WPTLog `
            -Message "Delegacao de credenciais RDP ja configurada para $Server." `
            -Level "SKIPPED"

        return $true
    }

    if (Test-WPTDryRun) {
        Write-WPTLog `
            -Message "[DRY RUN] Delegacao de credenciais RDP seria configurada para $Server. Nenhuma alteracao foi feita." `
            -Level "WARNING"

        return $true
    }

    try {
        if (-not (Test-Path -LiteralPath $script:WPTCredentialDelegationPolicyPath)) {
            New-Item `
                -Path $script:WPTCredentialDelegationPolicyPath `
                -Force `
                -ErrorAction Stop |
            Out-Null
        }

        if (-not (Test-Path -LiteralPath $script:WPTCredentialDelegationListPath)) {
            New-Item `
                -Path $script:WPTCredentialDelegationListPath `
                -Force `
                -ErrorAction Stop |
            Out-Null
        }

        New-ItemProperty `
            -Path $script:WPTCredentialDelegationPolicyPath `
            -Name $script:WPTCredentialDelegationPolicyName `
            -PropertyType DWord `
            -Value 1 `
            -Force `
            -ErrorAction Stop |
        Out-Null

        New-ItemProperty `
            -Path $script:WPTCredentialDelegationPolicyPath `
            -Name $script:WPTCredentialDelegationConcatName `
            -PropertyType DWord `
            -Value 1 `
            -Force `
            -ErrorAction Stop |
        Out-Null

        $state = Get-WPTCredentialDelegationState

        if ($state.Servers -notcontains $Server) {
            $nextIndex = 1

            if ($state.Servers.Count -gt 0) {
                $listKey = Get-Item `
                    -LiteralPath $script:WPTCredentialDelegationListPath `
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
                -Path $script:WPTCredentialDelegationListPath `
                -Name ([string]$nextIndex) `
                -PropertyType String `
                -Value $Server `
                -Force `
                -ErrorAction Stop |
            Out-Null
        }

        if (-not (Test-WPTCredentialDelegation -Server $Server)) {
            throw "A validacao da politica de delegacao falhou."
        }

        Write-WPTLog `
            -Message "Delegacao de credenciais RDP configurada para $Server." `
            -Level "SUCCESS"

        return $true
    }
    catch {
        Write-WPTLog `
            -Message "Falha ao configurar delegacao de credenciais RDP: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}
