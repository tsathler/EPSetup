$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\EPSetup\EPSetup.psd1"

Import-Module $modulePath -Force

Describe "Domain validation" {

    It "accepts a valid DNS domain name" {
        $module = Get-Module EPSetup

        $result = & $module {
            Test-EPDomainName -DomainName "example.local"
        }

        $result | Should Be $true
    }

    It "rejects an empty domain name" {
        $module = Get-Module EPSetup

        $errorMessage = & $module {
            try {
                Test-EPDomainName -DomainName ""
                $null
            }
            catch {
                $_.Exception.Message
            }
        }

        $errorMessage | Should Be "O dominio nao pode estar vazio."
    }

    It "rejects invalid domain characters" {
        $module = Get-Module EPSetup

        $errorMessage = & $module {
            try {
                Test-EPDomainName -DomainName "example\local"
                $null
            }
            catch {
                $_.Exception.Message
            }
        }

        $errorMessage | Should Be "O dominio informado possui caracteres invalidos."
    }
}
