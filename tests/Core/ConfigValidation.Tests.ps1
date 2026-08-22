$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\WindowsProvisioningToolkit\WindowsProvisioningToolkit.psd1"

Describe "Validacao de configuracao" {
    It "aceita a configuracao padrao" {
        $module = Get-Module WindowsProvisioningToolkit
        $config = & $module { Get-WPTConfig }
        ($null -ne $config) | Should Be $true
    }

    It "rejeita secoes obrigatorias ausentes" {
        $module = Get-Module WindowsProvisioningToolkit
        $threw = $false
        try {
            & $module { Test-WPTConfig -Config @{ Paths = @{ Data = 'x'; Logs = 'x'; Reports = 'x' } } }
        }
        catch {
            $threw = $true
        }
        $threw | Should Be $true
    }
}
