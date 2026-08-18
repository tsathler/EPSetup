# ============================================================================
#
# EPSetup - Software Detection
#
# Verifica se um software esta instalado
#
# ============================================================================


function Get-EPInstalledSoftware {

    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )


    foreach ($path in $paths) {

        Get-ItemProperty `
            -Path $path `
            -ErrorAction SilentlyContinue |
        Where-Object {
            $_.DisplayName
        } |
        Select-Object `
            DisplayName,
            DisplayVersion,
            Publisher
    }
}


function Test-EPSoftwareInstalled {

    param(
        [string]$SoftwareName,

        [pscustomobject]$Software
    )


    $detectionNames = @()
    $appxNames = @()

    if ($Software) {
        $detectionNames = @($Software.DetectionNames)

        if ($Software.AppxNames) {
            $appxNames = @($Software.AppxNames)
        }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($SoftwareName)) {
        $detectionNames = @($SoftwareName)
    }
    else {
        throw "Informe SoftwareName ou Software para verificar a instalacao."
    }


    $software = Get-EPInstalledSoftware


    foreach ($detectionName in $detectionNames) {
        if ([string]::IsNullOrWhiteSpace($detectionName)) {
            continue
        }

        $found = $software |
            Where-Object {
                $_.DisplayName -like "*$detectionName*"
            }

        if ($found) {
            return $true
        }
    }


    foreach ($appxName in $appxNames) {
        if ([string]::IsNullOrWhiteSpace($appxName)) {
            continue
        }

        $package = Get-AppxPackage `
            -Name $appxName `
            -AllUsers `
            -ErrorAction SilentlyContinue

        if ($package) {
            return $true
        }
    }


    return $false
}
