# Pausa de console desabilitavel para execucoes automatizadas.
function Read-WPTPause {
    param([string]$Prompt = "Pressione ENTER para continuar")

    if ([string]$env:WPT_NO_PAUSE -eq "1") {
        return
    }

    Read-Host $Prompt | Out-Null
}
