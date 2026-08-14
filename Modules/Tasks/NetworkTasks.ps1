# ============================================================================
#
# EPSetup - Network Tasks
#
# Tarefas relacionadas à conectividade de rede
#
# ============================================================================


# Verifica se existe conexão com a internet
function Test-InternetConnection {

    return Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet
}