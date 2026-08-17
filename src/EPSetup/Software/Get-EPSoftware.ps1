# ============================================================================
#
# EPSetup - Software Configuration
#
# Carrega a configuração de softwares do EPSetup
#
# ============================================================================


function Get-EPSoftware {

    $configPath = Join-Path `
        -Path $PSScriptRoot `
        -ChildPath "software.config.json"


    if (-not (Test-Path -LiteralPath $configPath)) {

        throw "Arquivo de configuracao de softwares nao encontrado: $configPath"
    }


    try {

        $software = Get-Content `
            -Path $configPath `
            -Raw `
            -ErrorAction Stop |
        ConvertFrom-Json `
            -ErrorAction Stop

    }
    catch {

        throw "Falha ao carregar software.config.json: $($_.Exception.Message)"
    }


    return $software.Software
}
