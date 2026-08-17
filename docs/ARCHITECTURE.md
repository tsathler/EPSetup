# EPSetup - Architecture

## 1. Objetivo

Descrever a arquitetura e as convenções utilizadas pelo EPSetup.

---

## 2. Estrutura

```text

EPSetup/
│
├── Main.ps1
│
├── src/
│   └── EPSetup/
│       │
│       ├── EPSetup.psd1
│       ├── EPSetup.psm1
│       │
│       ├── Public/
│       │   └── Start-EPSetup.ps1
│       │
│       ├── Core/
│       │   ├── Get-EPSetupConfig.ps1
│       │   ├── Get-EPSetupTasks.ps1
│       │   ├── Initialize-EPSetupLogging.ps1
│       │   └── Invoke-EPSetupTask.ps1
│       │   └── Test-EPSetup.ps1
│       │   ├── Write-EPSetupLog.ps1
│       │ 
│       ├── System/
│       │   ├── Get-EPSystemInfo.ps1
│       │   ├── Get-EPSystemTasks.ps1
│       │   ├── Rename-EPComputer.ps1
│       │   ├── Get-EPSystemPower.ps1
│       │   ├── Test-EPSystemPower.ps1
│       │   └── Update-EPWindows.ps1
│       │
│       ├── Network/
│       │   └── Add-EPComputerToDomain.ps1
│       │   ├── Get.EPNetworkTasks.ps1
│       │   ├── Test-EPInternetConnection.ps1
│       │
│       ├── Software/
│       │   ├── Get-EPSoftware.ps1
│       │   ├── Get-EPSoftwareTasks.ps1
│       │   ├── Install-EPSoftware.ps1
│       │   └── software.config.json
│       │   ├── Test-EPSoftwareInstalled.ps1
│       │
│       ├── Security/
│       │   └── Invoke-EPSetupElevation.ps1
│       │   └── Set-EPCredentialDelegation.ps1
│       │   ├── Set-EPUserPassword.ps1
│       │
│       └── UI/
│           └── Show-EPSetupBanner.ps1
│
├── tests/
│   ├── Core/
│   ├── System/
│   ├── Network/
│   └── Software/
│
├── docs/
│   └── ROADMAP.md
│   └── ARCHITECTURE.md

└── installers/