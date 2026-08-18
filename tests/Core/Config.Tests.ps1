$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\EPSetup\EPSetup.psd1"

Import-Module $modulePath -Force

Describe "Get-EPSetupConfig" {

    It "loads the portfolio profile by default" {
        $module = Get-Module EPSetup
        $testConfigRoot = Join-Path $env:TEMP ("epsetup-config-standard-test-" + [guid]::NewGuid().ToString())

        New-Item -Path $testConfigRoot -ItemType Directory -Force | Out-Null

        try {
            @"
{
  "Application": {
    "Name": "EPSetup",
    "Version": "0.1.1"
  },
  "Profile": {
    "Name": "Portfolio",
    "Mode": "Standard"
  },
  "Paths": {
    "Data": "C:\\ProgramData\\EPSetup",
    "Logs": "C:\\ProgramData\\EPSetup\\Logs",
    "Reports": "C:\\ProgramData\\EPSetup\\Reports"
  },
  "Settings": {
    "RequireAdmin": true
  },
  "System": {
    "Domain": {
      "DefaultDomainName": "",
      "SuggestDefaultDomain": false,
      "AutoJoin": false
    }
  }
}
"@ | Set-Content -LiteralPath (Join-Path $testConfigRoot "Standard.json") -Encoding UTF8

            $config = & $module {
                $env:EPSETUP_CONFIG_ROOT = $args[0]
                Get-EPSetupConfig
            } $testConfigRoot

            $config.Profile.Name | Should Be "Portfolio"
            $config.Profile.Mode | Should Be "Standard"
            $config.System.Domain.AutoJoin | Should Be $false
        }
        finally {
            & $module {
                Remove-Item Env:\EPSETUP_CONFIG_ROOT -ErrorAction SilentlyContinue
            }

            Remove-Item -LiteralPath $testConfigRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "merges Corporate.local.json when it exists in the configured root" {
        $module = Get-Module EPSetup
        $testConfigRoot = Join-Path $env:TEMP ("epsetup-config-test-" + [guid]::NewGuid().ToString())

        New-Item -Path $testConfigRoot -ItemType Directory -Force | Out-Null

        try {
            @"
{
  "Application": {
    "Name": "EPSetup",
    "Version": "0.1.1"
  },
  "Profile": {
    "Name": "Portfolio",
    "Mode": "Standard"
  },
  "Paths": {
    "Data": "C:\\ProgramData\\EPSetup",
    "Logs": "C:\\ProgramData\\EPSetup\\Logs",
    "Reports": "C:\\ProgramData\\EPSetup\\Reports"
  },
  "Settings": {
    "RequireAdmin": true
  },
  "System": {
    "Domain": {
      "DefaultDomainName": "",
      "SuggestDefaultDomain": false,
      "AutoJoin": false
    }
  }
}
"@ | Set-Content -LiteralPath (Join-Path $testConfigRoot "Standard.json") -Encoding UTF8

            @"
{
  "Profile": {
    "Name": "Corporate",
    "Mode": "Local"
  },
  "System": {
    "Domain": {
      "DefaultDomainName": "example.local",
      "SuggestDefaultDomain": true,
      "AutoJoin": false
    }
  }
}
"@ | Set-Content -LiteralPath (Join-Path $testConfigRoot "Corporate.local.json") -Encoding UTF8

            $config = & $module {
                $env:EPSETUP_CONFIG_ROOT = $args[0]
                Get-EPSetupConfig
            } $testConfigRoot

            $config.Profile.Name | Should Be "Corporate"
            $config.Profile.Mode | Should Be "Local"
            $config.System.Domain.DefaultDomainName | Should Be "example.local"
            $config.System.Domain.SuggestDefaultDomain | Should Be $true
            $config.System.Domain.AutoJoin | Should Be $false
        }
        finally {
            & $module {
                Remove-Item Env:\EPSETUP_CONFIG_ROOT -ErrorAction SilentlyContinue
            }

            Remove-Item -LiteralPath $testConfigRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
