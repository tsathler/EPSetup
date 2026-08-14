# Verifica se as configuracoes de energia ja estao corretas
function Test-PowerSettings {

    # Consulta o tempo do monitor
    $monitorTimeout = powercfg /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE

    # Consulta o tempo de suspensao
    $standbyTimeout = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE

    # Verifica se o monitor esta configurado para nunca desligar
    $monitorCorrect = $monitorTimeout -match "0x00000000"

    # Verifica se o computador esta configurado para nunca suspender
    $standbyCorrect = $standbyTimeout -match "0x00000000"

    # Retorna verdadeiro somente se ambas estiverem corretas
    return ($monitorCorrect -and $standbyCorrect)
}