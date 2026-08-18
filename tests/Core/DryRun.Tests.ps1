$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\EPSetup\EPSetup.psd1"

Import-Module $modulePath -Force

Describe "Dry Run" {

    It "is disabled by default" {
        $module = Get-Module EPSetup

        $enabled = & $module {
            Test-EPDryRun
        }

        $enabled | Should Be $false
    }

    It "can be enabled and disabled" {
        $module = Get-Module EPSetup

        $status = & $module {
            $script:LogFilePath = Join-Path $env:TEMP "epsetup-pester-dryrun.log"

            Set-EPDryRun -Enabled $true
            $enabled = Test-EPDryRun

            Set-EPDryRun -Enabled $false
            $disabled = -not (Test-EPDryRun)

            [pscustomobject]@{
                Enabled = $enabled
                Disabled = $disabled
            }
        }

        $status.Enabled | Should Be $true
        $status.Disabled | Should Be $true
    }
}
