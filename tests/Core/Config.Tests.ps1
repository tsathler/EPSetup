$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\EPSetup\EPSetup.psd1"

Import-Module $modulePath -Force

Describe "Get-EPSetupConfig" {

    It "loads the portfolio profile by default" {
        $module = Get-Module EPSetup

        $config = & $module {
            Get-EPSetupConfig
        }

        $config.Profile.Name | Should Be "Portfolio"
        $config.Profile.Mode | Should Be "Standard"
        $config.System.Domain.AutoJoin | Should Be $false
    }

    It "keeps Corporate.local.json out of the default test state" {
        $module = Get-Module EPSetup

        $exists = & $module {
            Test-EPCorporateLocalConfig
        }

        $exists | Should Be $false
    }
}
