# ============================================================================
#
# EPSetup - Configuration
#
# Carrega configuracoes Portfolio e Corporate local quando existir
#
# ============================================================================

function Merge-EPSetupConfig {

    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Base,

        [Parameter(Mandatory = $true)]
        [hashtable]$Override
    )

    foreach ($key in $Override.Keys) {
        if (
            $Base.ContainsKey($key) -and
            ($Base[$key] -is [hashtable]) -and
            ($Override[$key] -is [hashtable])
        ) {
            Merge-EPSetupConfig `
                -Base $Base[$key] `
                -Override $Override[$key]
        }
        else {
            $Base[$key] = $Override[$key]
        }
    }
}


function ConvertTo-EPHashtable {

    param(
        [Parameter(Mandatory = $true)]
        $InputObject
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        $hash = @{}

        foreach ($key in $InputObject.Keys) {
            $hash[$key] = ConvertTo-EPHashtable -InputObject $InputObject[$key]
        }

        return $hash
    }

    if ($InputObject -is [pscustomobject]) {
        $hash = @{}

        foreach ($property in $InputObject.PSObject.Properties) {
            $hash[$property.Name] = ConvertTo-EPHashtable -InputObject $property.Value
        }

        return $hash
    }

    if ($InputObject -is [array]) {
        return @(
            foreach ($item in $InputObject) {
                ConvertTo-EPHashtable -InputObject $item
            }
        )
    }

    return $InputObject
}


function Import-EPJsonConfig {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Arquivo de configuracao nao encontrado: $Path"
    }

    $content = Get-Content `
        -LiteralPath $Path `
        -Raw `
        -ErrorAction Stop

    if ([string]::IsNullOrWhiteSpace($content)) {
        return @{}
    }

    return ConvertTo-EPHashtable `
        -InputObject ($content | ConvertFrom-Json -ErrorAction Stop)
}


function Get-EPSetupConfig {

    $configRoot = Join-Path `
        -Path (Split-Path -Parent $PSScriptRoot) `
        -ChildPath "Config"

    $standardPath = Join-Path `
        -Path $configRoot `
        -ChildPath "Standard.json"

    $corporateLocalPath = Join-Path `
        -Path $configRoot `
        -ChildPath "Corporate.local.json"

    $config = Import-EPJsonConfig -Path $standardPath

    if (Test-Path -LiteralPath $corporateLocalPath) {
        $corporateConfig = Import-EPJsonConfig -Path $corporateLocalPath

        Merge-EPSetupConfig `
            -Base $config `
            -Override $corporateConfig
    }

    return $config
}
