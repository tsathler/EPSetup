$modulePath = Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath "src\WindowsProvisioningToolkit\WindowsProvisioningToolkit.psd1"

Import-Module $modulePath -Force

Describe "Get-WPTConfig" {

    It "loads the portfolio profile by default" {
        $module = Get-Module WindowsProvisioningToolkit
        $testConfigRoot = Join-Path $env:TEMP ("windows-provisioning-toolkit-config-standard-test-" + [guid]::NewGuid().ToString())

        New-Item -Path $testConfigRoot -ItemType Directory -Force | Out-Null

        try {
            @"
{
  "Application": {
    "Name": "WindowsProvisioningToolkit",
    "Version": "0.1.1"
  },
  "Profile": {
    "Name": "Portfolio",
    "Mode": "Standard"
  },
  "Paths": {
    "Data": "C:\\ProgramData\\WindowsProvisioningToolkit",
    "Logs": "C:\\ProgramData\\WindowsProvisioningToolkit\\Logs",
    "Reports": "C:\\ProgramData\\WindowsProvisioningToolkit\\Reports"
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
                $env:WPT_CONFIG_ROOT = $args[0]
                Get-WPTConfig
            } $testConfigRoot

            $config.Profile.Name | Should Be "Portfolio"
            $config.Profile.Mode | Should Be "Standard"
            $config.System.Domain.AutoJoin | Should Be $false
        }
        finally {
            & $module {
                Remove-Item Env:\WPT_CONFIG_ROOT -ErrorAction SilentlyContinue
            }

            Remove-Item -LiteralPath $testConfigRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "merges Corporate.local.json when it exists in the configured root" {
        $module = Get-Module WindowsProvisioningToolkit
        $testConfigRoot = Join-Path $env:TEMP ("windows-provisioning-toolkit-config-test-" + [guid]::NewGuid().ToString())

        New-Item -Path $testConfigRoot -ItemType Directory -Force | Out-Null

        try {
            @"
{
  "Application": {
    "Name": "WindowsProvisioningToolkit",
    "Version": "0.1.1"
  },
  "Profile": {
    "Name": "Portfolio",
    "Mode": "Standard"
  },
  "Paths": {
    "Data": "C:\\ProgramData\\WindowsProvisioningToolkit",
    "Logs": "C:\\ProgramData\\WindowsProvisioningToolkit\\Logs",
    "Reports": "C:\\ProgramData\\WindowsProvisioningToolkit\\Reports"
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
                $env:WPT_CONFIG_ROOT = $args[0]
                Get-WPTConfig
            } $testConfigRoot

            $config.Profile.Name | Should Be "Corporate"
            $config.Profile.Mode | Should Be "Local"
            $config.System.Domain.DefaultDomainName | Should Be "example.local"
            $config.System.Domain.SuggestDefaultDomain | Should Be $true
            $config.System.Domain.AutoJoin | Should Be $false
        }
        finally {
            & $module {
                Remove-Item Env:\WPT_CONFIG_ROOT -ErrorAction SilentlyContinue
            }

            Remove-Item -LiteralPath $testConfigRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
