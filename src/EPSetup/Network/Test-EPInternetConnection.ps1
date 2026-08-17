# ============================================================================
#
# EPSetup - Internet Connectivity
#
# Verifica a conectividade com a Internet
#
# ============================================================================


function Test-EPInternetConnection {

    try {
        $result = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction Stop

        return $result
    }
    catch {
        return $false
    }
}
