# WindowsProvisioningToolkit - Architecture

## Objective

WindowsProvisioningToolkit is a modular PowerShell toolkit for Windows workstation provisioning.
The project separates portfolio-safe defaults from local corporate
configuration so the public repository can demonstrate the automation flow
without exposing internal environment data.

## Entry Point

```text
Main.ps1
```

`Main.ps1` imports the local module manifest from `src/WindowsProvisioningToolkit/WindowsProvisioningToolkit.psd1`
and starts the menu-driven experience with `Start-WPT`.

## Module Layout

```text
WindowsProvisioningToolkit/
|-- Main.ps1
|-- src/
|   `-- WindowsProvisioningToolkit/
|       |-- WindowsProvisioningToolkit.psd1
|       |-- WindowsProvisioningToolkit.psm1
|       |-- Config/
|       |   |-- Standard.json
|       |   `-- Corporate.example.json
|       |-- Core/
|       |-- Network/
|       |-- Public/
|       |-- Security/
|       |-- Software/
|       |-- System/
|       `-- UI/
|-- tests/
|   |-- Core/
|   `-- Network/
|-- docs/
|   |-- ARCHITECTURE.md
|   |-- ROADMAP.md
|   `-- USAGE.md
`-- installers/
```

## Internal Areas

- `Public`: public module entry points. Currently exports `Start-WPT`.
- `Core`: configuration loading, logging, dry run state, task execution, restart state, and execution reports.
- `Software`: software catalog, installation logic, detection rules, and software task creation.
- `System`: local workstation configuration, user configuration, power settings, and system information.
- `Network`: connectivity checks and optional domain join flow.
- `Security`: elevation, credential delegation, and local password helpers.
- `UI`: console menus, banner, profile configuration, and execution profile selection.
- `Config`: portfolio defaults and a corporate example file.

## Configuration Model

The default public profile is stored in:

```text
src/WindowsProvisioningToolkit/Config/Standard.json
```

Corporate values can be generated locally in:

```text
src/WindowsProvisioningToolkit/Config/Corporate.local.json
```

`Corporate.local.json` is ignored by Git and must not contain credentials,
internal users, private servers, or production secrets. The repository includes
only `Corporate.example.json`, which uses `example.local` as a safe placeholder.

## Execution Flow

1. `Main.ps1` imports the module and calls `Start-WPT`.
2. `Start-WPT` checks elevation, initializes logging, and opens the main menu.
3. The user chooses a software, system, profile, dry run, or execution profile flow.
4. Each flow creates task objects and sends them to `Invoke-WPTTasks`.
5. The task runner records success, skipped, and failure counts.
6. Flows with summaries export a JSON report to the configured report path.

## Safety

- The project defaults to the `Portfolio` profile.
- Domain join is always optional and requires confirmation during execution.
- Dry Run simulates destructive operations before applying real changes.
- WindowsProvisioningToolkit does not restart the machine automatically after system changes.
- Local corporate configuration is kept outside version control.

## Validation

Automated validation is centralized in:

```powershell
.\tests\Run-Tests.ps1
```

The script validates PowerShell syntax and runs the Pester test suite. If any
test fails, the script exits with an error so local verification and future CI
checks can fail correctly.
