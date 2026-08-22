$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\WindowsProvisioningToolkit\WindowsProvisioningToolkit.psd1"

Import-Module $modulePath -Force

Describe "Dry Run" {

    It "is disabled by default" {
        $module = Get-Module WindowsProvisioningToolkit

        $enabled = & $module {
            Test-WPTDryRun
        }

        $enabled | Should Be $false
    }

    It "can be enabled and disabled" {
        $module = Get-Module WindowsProvisioningToolkit

        $status = & $module {
            $script:LogFilePath = Join-Path $env:TEMP "windows-provisioning-toolkit-pester-dryrun.log"

            Set-WPTDryRun -Enabled $true
            $enabled = Test-WPTDryRun

            Set-WPTDryRun -Enabled $false
            $disabled = -not (Test-WPTDryRun)

            [pscustomobject]@{
                Enabled = $enabled
                Disabled = $disabled
            }
        }

        $status.Enabled | Should Be $true
        $status.Disabled | Should Be $true
    }
}
