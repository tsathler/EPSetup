# EPSetup
A modular PowerShell toolkit for automating Windows workstation provisioning and corporate environment configuration.

## MVP atual

O primeiro MVP foca na instalacao selecionavel destes aplicativos:

- Google Chrome
- Mozilla Firefox
- WinRAR
- AnyDesk
- PDFCreator
- Microsoft Teams

Execute pelo PowerShell:

```powershell
.\Main.ps1
```

O `Main.ps1` carrega o modulo em `src/EPSetup` e chama `Start-EPSetup`.
O menu permite selecionar os aplicativos desejados, evita reinstalar o que ja
estiver instalado, registra logs em `C:\ProgramData\EPSetup\Logs` e exibe um
resumo final.

## Decisoes de instalacao do MVP

- Chrome, Firefox, WinRAR, AnyDesk e PDFCreator usam Winget.
- PDFCreator usa o pacote `PDFCreator-Free` com `/COMPONENTS="none"` para
  instalar o PDFCreator sem componentes adicionais, incluindo PDF Architect.
- Microsoft Teams usa o `teamsbootstrapper.exe -p`, metodo atual de
  provisionamento em massa documentado pela Microsoft.
