# EPSetup
A modular PowerShell toolkit for automating Windows workstation provisioning and corporate environment configuration.

## Versao atual

A versao atual possui duas areas principais:

- Instalacao de Aplicativos
- Configuracao do Sistema

Execute pelo PowerShell:

```powershell
.\Main.ps1
```

## Instalacao de Aplicativos

O MVP de aplicativos permite selecionar e instalar:

- Google Chrome
- Mozilla Firefox
- WinRAR
- AnyDesk
- PDFCreator
- Microsoft Teams

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

## Configuracao do Sistema

A versao 0.1.1 adiciona as primeiras configuracoes de sistema:

- Delegacao de credenciais RDP para `TERMSRV/*`
- Entrada opcional no dominio informado pelo usuario
- Configuracao do usuario atual
- Execucao completa das configuracoes de sistema

O EPSetup nao reinicia a maquina automaticamente. Quando uma operacao exigir
reinicializacao, o resumo final informa que ela e necessaria.

## Portfolio e Corporate

Este repositorio representa a versao Portfolio do EPSetup. Ela nao deve conter
dominios, servidores, usuarios, credenciais ou configuracoes internas de uma
empresa.

Configuracoes especificas de ambiente corporativo devem permanecer separadas da
logica principal do projeto.

Pela interface, acesse:

```text
[3] Perfil e Configuracao
```

Opcoes disponiveis:

```text
[1] Ver perfil ativo
[2] Configurar Corporate local
[3] Limpar Corporate local
```

Ao configurar o Corporate local, o EPSetup cria ou atualiza:

```text
src/EPSetup/Config/Corporate.local.json
```

Esse arquivo e ignorado pelo Git. Ele pode conter valores padrao do ambiente,
como um dominio sugerido, mas o EPSetup ainda pergunta se a maquina deve ou nao
ser adicionada ao dominio. Nada e associado ao dominio automaticamente.

A opcao `Limpar Corporate local` remove o `Corporate.local.json` e faz o EPSetup
voltar ao perfil Portfolio.
