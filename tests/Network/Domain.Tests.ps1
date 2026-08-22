$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\WindowsProvisioningToolkit\WindowsProvisioningToolkit.psd1"

Import-Module $modulePath -Force

Describe "Domain validation" {

    It "accepts a valid DNS domain name" {
        $module = Get-Module WindowsProvisioningToolkit

        $result = & $module {
            Test-WPTDomainName -DomainName "example.local"
        }

        $result | Should Be $true
    }

    It "rejects an empty domain name" {
        $module = Get-Module WindowsProvisioningToolkit

        $errorMessage = & $module {
            try {
                Test-WPTDomainName -DomainName ""
                $null
            }
            catch {
                $_.Exception.Message
            }
        }

        $errorMessage | Should Be "O dominio nao pode estar vazio."
    }

    It "rejects invalid domain characters" {
        $module = Get-Module WindowsProvisioningToolkit

        $errorMessage = & $module {
            try {
                Test-WPTDomainName -DomainName "example\local"
                $null
            }
            catch {
                $_.Exception.Message
            }
        }

        $errorMessage | Should Be "O dominio informado possui caracteres invalidos."
    }
}
