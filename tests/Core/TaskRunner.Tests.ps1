$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\EPSetup\EPSetup.psd1"

Import-Module $modulePath -Force

Describe "Invoke-EPSetupTasks" {

    It "counts skipped actions returned by the action block" {
        $module = Get-Module EPSetup

        $result = & $module {
            $script:LogFilePath = Join-Path $env:TEMP "epsetup-pester-taskrunner.log"

            Invoke-EPSetupTasks -Tasks @(
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
        $module = Get-Module EPSetup

        $result = & $module {
            $script:LogFilePath = Join-Path $env:TEMP "epsetup-pester-taskrunner.log"

            Invoke-EPSetupTasks -Tasks @(
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
        $module = Get-Module EPSetup

        $result = & $module {
            $script:LogFilePath = Join-Path $env:TEMP "epsetup-pester-taskrunner.log"

            Invoke-EPSetupTasks -Tasks @(
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
