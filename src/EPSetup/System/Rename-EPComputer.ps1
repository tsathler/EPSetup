# ============================================================================
#
# EPSetup - Computer Name
#
# Renomeia o computador atual
#
# ============================================================================


function Rename-EPComputer {

    $currentName = $env:COMPUTERNAME


    Write-EPSetupLog `
        -Message "Nome atual do computador: $currentName" `
        -Level "INFO"


    $answer = Read-Host "Deseja alterar o nome do computador? (S/N)"


    if ($answer -notmatch "^[Ss]$") {

        Write-EPSetupLog `
            -Message "Alteracao do nome do computador ignorada pelo usuario." `
            -Level "SKIPPED"

        return $true
    }


    $newName = Read-Host "Digite o novo nome do computador"


    if ([string]::IsNullOrWhiteSpace($newName)) {

        throw "O nome do computador nao pode estar vazio."
    }


    if ($newName.Length -gt 15) {

        throw "O nome do computador nao pode possuir mais de 15 caracteres."
    }


    if ($newName -notmatch "^[a-zA-Z0-9-]+$") {

        throw "O nome do computador possui caracteres invalidos."
    }


    if ($newName -ieq $currentName) {

        Write-EPSetupLog `
            -Message "O novo nome e igual ao nome atual. Alteracao ignorada." `
            -Level "SKIPPED"

        return $true
    }


    Write-EPSetupLog `
        -Message "Renomeando computador de $currentName para $newName..." `
        -Level "INFO"


    try {

        Rename-Computer `
            -NewName $newName `
            -ErrorAction Stop


        Write-EPSetupLog `
            -Message "Computador renomeado para $newName com sucesso." `
            -Level "SUCCESS"


        return $true
    }
    catch {

        Write-EPSetupLog `
            -Message "Falha ao renomear computador: $($_.Exception.Message)" `
            -Level "ERROR"

        throw
    }
}
