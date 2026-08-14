# ============================================================================
#
# EPSetup - Task Definitions
#
# Define as tarefas que serao executadas pelo EPSetup
#
# ============================================================================


# Retorna a lista de tarefas do EPSetup
function Get-SetupTasks {

    return @(

        @{
            Name = "Verificar conexao com a Internet"

            Action = {

                if (-not (Test-InternetConnection)) {
                    throw "Conexao com a Internet indisponivel."
                }

                Write-Log `
                    -Message "Conexao com a Internet OK." `
                    -Level "SUCCESS"
            }
        }


        @{
            Name = "Configurar servico do Windows Update"

            Condition = {
                return -not (Test-WindowsUpdateSettings)
            }

            Action = {

                if (-not (Start-WindowsUpdateService)) {
                    throw "Falha ao iniciar o servico do Windows Update."
                }

                Write-Log `
                    -Message "Servico do Windows Update iniciado." `
                    -Level "SUCCESS"
            }
        }


        @{
            Name = "Instalar Google Chrome"

            Condition = {
                return -not (Test-SoftwareInstalled -SoftwareName "Chrome")
            }

            Action = {

                if (-not (Install-GoogleChrome)) {
                    throw "Falha ao instalar o Google Chrome."
                }

                Write-Log `
                    -Message "Google Chrome instalado com sucesso." `
                    -Level "SUCCESS"
            }
        }


        @{
            Name = "Configurar energia do computador"

            Condition = {
                return -not (Test-PowerSettings)
            }

            Action = {

                if (-not (Configure-PowerSettings)) {
                    throw "Falha ao configurar as opcoes de energia."
                }

                Write-Log `
                    -Message "Opcoes de energia configuradas." `
                    -Level "SUCCESS"
            }
        }

        @{
            Name = "Instalar Mozilla Firefox"

            Condition = {
                return -not (Test-SoftwareInstalled -SoftwareName "Mozilla Firefox")
            }

            Action = {

                if (-not (Install-Firefox)) {
                    throw "Falha ao instalar o Mozilla Firefox."
                }

                Write-Log `
                    -Message "Mozilla Firefox instalado com sucesso." `
                    -Level "SUCCESS"
            }
        }

        @{
            Name = "Instalar WinRAR"

            Condition = {
                return -not (Test-SoftwareInstalled -SoftwareName "WinRAR")
            }

            Action = {

                if (-not (Install-WinRAR)) {
                    throw "Falha ao instalar o WinRAR."
                }

                Write-Log `
                    -Message "WinRAR instalado com sucesso." `
                    -Level "SUCCESS"
            }
        }

        @{
            Name = "Instalar AnyDesk"

            Condition = {
                return -not (Test-SoftwareInstalled -SoftwareName "AnyDesk")
            }

            Action = {

                if (-not (Install-AnyDesk)) {
                    throw "Falha ao instalar o AnyDesk."
                }

                Write-Log `
                    -Message "AnyDesk instalado com sucesso." `
                    -Level "SUCCESS"
            }
        }

        @{
            Name = "Instalar Microsoft Teams"

            Condition = {
                return -not (Test-SoftwareInstalled -SoftwareName "Microsoft Teams")
            }

            Action = {

                if (-not (Install-MicrosoftTeams)) {
                    throw "Falha ao instalar o Microsoft Teams."
                }

                Write-Log `
                    -Message "Microsoft Teams instalado com sucesso." `
                    -Level "SUCCESS"
            }
        }

        @{
            Name = "Instalar PDFCreator"

            Condition = {
                return -not (Test-SoftwareInstalled -SoftwareName "PDFCreator")
            }

            Action = {

                if (-not (Install-PDFCreator)) {
                    throw "Falha ao instalar o PDFCreator."
                }

                Write-Log `
                    -Message "PDFCreator instalado com sucesso." `
                    -Level "SUCCESS"
            }
        }

        @{
            Name = "Instalar GLPI Agent"

            Condition = {
                return -not (Test-Path "C:\Program Files\GLPI-Agent\glpi-agent.bat")
            }

            Action = {

                if (-not (Install-GLPIAgent)) {
                    throw "Falha ao instalar o GLPI Agent."
                }

                Write-Log `
                    -Message "GLPI Agent instalado com sucesso." `
                    -Level "SUCCESS"
            }
        }

        @{
            Name = "Executar inventario do GLPI"

            Condition = {
                return Test-Path "C:\Program Files\GLPI-Agent\glpi-agent.bat"
            }

            Action = {
                Invoke-GLPIInventory
            }
        }

        @{
            Name = "Renomear computador"

            Condition = {
                return $true
            }

            Action = {
                Rename-EPComputer
            }
        }

        @{
            Name = "Adicionar computador ao dominio"

            Condition = {
                $answer = Read-Host "Deseja adicionar este computador ao dominio? (S/N)"

                return $answer -match "^[Ss]$"
            }

            Action = {
                Add-ComputerToDomain `
                    -DomainName $EPSetupConfig.Domain.Name
            }
        }
    )
}

