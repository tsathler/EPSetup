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
        [Parameter(Mandatory = $true)]
        [string]$SoftwareName
    )


    $software = Get-EPInstalledSoftware


    return $null -ne (
        $software |
        Where-Object {
            $_.DisplayName -like "*$SoftwareName*"
        }
    )
}
