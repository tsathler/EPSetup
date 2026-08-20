# EPSetup

EPSetup is a modular PowerShell toolkit for automating Windows workstation
provisioning and corporate environment configuration.

This repository is the portfolio-safe version of the project. It demonstrates
the automation structure, menus, dry run behavior, logging, reports, and tests
without versioning internal domains, servers, users, credentials, or company
configuration.

## Status

Current version: `0.1.1`

The project is an MVP with two main areas:

- Application installation
- System configuration

## Requirements

- Windows
- PowerShell 5.1 or newer
- Administrator privileges for real provisioning flows
- Winget for most application installs
- Pester for automated tests

Run from PowerShell:

```powershell
.\Main.ps1
```

## Application Installation

The application MVP can select and install:

- Google Chrome
- Mozilla Firefox
- WinRAR
- AnyDesk
- PDFCreator
- Microsoft Teams

`Main.ps1` loads the module from `src/EPSetup` and calls `Start-EPSetup`.
The menu lets the user select applications, skips software that is already
installed, writes logs to `C:\ProgramData\EPSetup\Logs`, and displays a final
summary.

## Installation Decisions

- Chrome, Firefox, WinRAR, AnyDesk, and PDFCreator use Winget.
- PDFCreator uses the `PDFCreator-Free` package with `/COMPONENTS="none"` to
  install PDFCreator without additional components, including PDF Architect.
- Microsoft Teams uses `teamsbootstrapper.exe -p`, the current Microsoft
  method for bulk provisioning.

## System Configuration

Version `0.1.1` adds the first system configuration flows:

- RDP credential delegation for `TERMSRV/*`
- Optional domain join with user confirmation
- Current user configuration
- Complete system configuration flow

EPSetup does not restart the machine automatically. When an operation requires
a restart, the final summary reports that a restart is needed.

## Portfolio and Corporate Profiles

The repository defaults to the `Portfolio` profile and must not contain
company-specific values.

Corporate environment values should stay separate from the main project logic.

From the interface, open:

```text
[3] Perfil e Configuracao
```

Available options:

```text
[1] Ver perfil ativo
[2] Configurar Corporate local
[3] Limpar Corporate local
```

When local corporate configuration is enabled, EPSetup creates or updates:

```text
src/EPSetup/Config/Corporate.local.json
```

This file is ignored by Git. It can store local defaults, such as a suggested
domain, but EPSetup still asks whether the workstation should be added to the
domain. Domain join is never automatic.

The `Limpar Corporate local` option removes `Corporate.local.json` and returns
EPSetup to the `Portfolio` profile.

## Dry Run

The main menu includes:

```text
[4] Alternar Dry Run
```

When Dry Run is enabled, EPSetup simulates installation, RDP delegation, domain
join, user changes, password changes, and restart operations without applying
destructive system changes.

## Execution Profiles

The interface includes guided execution profiles:

- Portfolio
- Corporate basico
- Corporate completo
- Somente aplicativos
- Somente sistema

Before running a profile, EPSetup shows a pre-execution summary with the chosen
profile, active configuration profile, Dry Run state, and planned tasks. Domain
join still requires confirmation during execution.

## Tests

Automated tests use Pester:

```powershell
.\tests\Run-Tests.ps1
```

The script validates PowerShell syntax and runs the Pester suite. It fails the
process if any test fails, which makes it suitable for local checks and future
CI usage.

Current tests cover configuration loading, isolated corporate profile behavior,
domain validation, Dry Run, final reports, and task runner counters.

## Documentation

- Usage guide: `docs/USAGE.md`
- Architecture notes: `docs/ARCHITECTURE.md`
- Roadmap: `docs/ROADMAP.md`

## Reports

When a flow finishes with a summary, EPSetup exports a JSON report to:

```text
C:\ProgramData\EPSetup\Reports
```

The report includes active profile, execution context, computer, user, Dry Run
state, task summary, task details, and pending restart information.
