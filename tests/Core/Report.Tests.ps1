$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\EPSetup\EPSetup.psd1"

Import-Module $modulePath -Force

Describe "Export-EPExecutionReport" {

    It "writes a JSON execution report" {
        $module = Get-Module EPSetup
        $testConfigRoot = Join-Path $env:TEMP ("epsetup-report-config-" + [guid]::NewGuid().ToString())
        $testDataRoot = Join-Path $env:TEMP ("epsetup-report-data-" + [guid]::NewGuid().ToString())
        $testReportRoot = Join-Path $testDataRoot "Reports"

        New-Item -Path $testConfigRoot -ItemType Directory -Force | Out-Null

        try {
            $standardConfig = [ordered]@{
                Application = [ordered]@{
                    Name = "EPSetup"
                    Version = "0.1.1"
                }
                Profile = [ordered]@{
                    Name = "Portfolio"
                    Mode = "Standard"
                }
                Paths = [ordered]@{
                    Data = $testDataRoot
                    Logs = (Join-Path $testDataRoot "Logs")
                    Reports = $testReportRoot
                }
                Settings = [ordered]@{
                    RequireAdmin = $true
                }
                System = [ordered]@{
                    Domain = [ordered]@{
                        DefaultDomainName = ""
                        SuggestDefaultDomain = $false
                        AutoJoin = $false
                    }
                }
            }

            $standardConfig |
                ConvertTo-Json -Depth 10 |
                Set-Content -LiteralPath (Join-Path $testConfigRoot "Standard.json") -Encoding UTF8

            $reportPath = & $module {
                $env:EPSETUP_CONFIG_ROOT = $args[0]
                $script:LogFilePath = Join-Path $env:TEMP "epsetup-pester-report.log"

                Export-EPExecutionReport `
                    -Context "Pester" `
                    -Result @{
                        Total = 1
                        Success = 1
                        Skipped = 0
                        Failure = 0
                        Details = @(
                            [pscustomobject]@{
                                Name = "Teste"
                                Status = "SUCCESS"
                            }
                        )
                    }
            } $testConfigRoot

            Test-Path -LiteralPath $reportPath | Should Be $true

            $report = Get-Content -Raw -LiteralPath $reportPath | ConvertFrom-Json

            $report.Context | Should Be "Pester"
            $report.Summary.Success | Should Be 1
            $report.Details[0].Name | Should Be "Teste"
        }
        finally {
            & $module {
                Remove-Item Env:\EPSETUP_CONFIG_ROOT -ErrorAction SilentlyContinue
            }

            Remove-Item -LiteralPath $testConfigRoot -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $testDataRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
