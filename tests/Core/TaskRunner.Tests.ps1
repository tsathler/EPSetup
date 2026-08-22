$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\WindowsProvisioningToolkit\WindowsProvisioningToolkit.psd1"

Import-Module $modulePath -Force

Describe "Invoke-WPTTasks" {

    It "counts skipped actions returned by the action block" {
        $module = Get-Module WindowsProvisioningToolkit

        $result = & $module {
            $script:LogFilePath = Join-Path $env:TEMP "windows-provisioning-toolkit-pester-taskrunner.log"

            Invoke-WPTTasks -Tasks @(
                @{
                    Name = "Skip action"
                    Action = { "SKIPPED" }
                }
            )
        }

        $result.Success | Should Be 0
        $result.Skipped | Should Be 1
        $result.Failure | Should Be 0
    }

    It "counts skipped conditions" {
        $module = Get-Module WindowsProvisioningToolkit

        $result = & $module {
            $script:LogFilePath = Join-Path $env:TEMP "windows-provisioning-toolkit-pester-taskrunner.log"

            Invoke-WPTTasks -Tasks @(
                @{
                    Name = "Skip condition"
                    Condition = { $false }
                    Action = { $true }
                }
            )
        }

        $result.Success | Should Be 0
        $result.Skipped | Should Be 1
        $result.Failure | Should Be 0
    }

    It "counts failed actions" {
        $module = Get-Module WindowsProvisioningToolkit

        $result = & $module {
            $script:LogFilePath = Join-Path $env:TEMP "windows-provisioning-toolkit-pester-taskrunner.log"

            Invoke-WPTTasks -Tasks @(
                @{
                    Name = "Failure action"
                    Action = { throw "Expected failure" }
                }
            )
        }

        $result.Success | Should Be 0
        $result.Skipped | Should Be 0
        $result.Failure | Should Be 1
    }
}
