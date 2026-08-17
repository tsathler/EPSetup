# ============================================================================
#
# EPSetup - Software Tasks
#
# Gera tarefas de instalação de softwares a partir do software.json
#
# ============================================================================

function Get-EPSoftwareTasks {

    $softwareList = @(Get-EPSoftware)

    $testSoftwareInstalled = ${function:Test-EPSoftwareInstalled}
    $installSoftware = ${function:Install-EPSoftware}

    foreach ($software in $softwareList) {

        $softwareName = $software.Name
        $softwareData = $software

        @{
            Name = "Instalar $softwareName"

            Condition = {
                -not (& $testSoftwareInstalled -SoftwareName $softwareName)
            }.GetNewClosure()

            Action = {
                & $installSoftware -Software $softwareData
            }.GetNewClosure()
        }
    }
}
