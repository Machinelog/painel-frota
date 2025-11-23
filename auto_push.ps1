# Caminho da pasta que será monitorada
$folder = "C:\Users\machi\OneDrive\Documentos\GitHub\painel-frota\dados_para_painel"

Write-Host "Monitorando a pasta: $folder"
Write-Host "Sempre que você salvar ou alterar um CSV, ele será enviado automaticamente."

while ($true) {

    # Pega CSVs novos ou modificados nos últimos 3 segundos
    $files = Get-ChildItem -Path $folder -Filter "*.csv" | Where-Object {
        (Get-Date) - $_.LastWriteTime -lt (New-TimeSpan -Seconds 3)
    }

    foreach ($file in $files) {
        Write-Host "Detectado CSV novo ou alterado: $($file.Name)"

        # Vai para a pasta do repositório
        Set-Location "C:\Users\machi\OneDrive\Documentos\GitHub\painel-frota"

        # Atualiza repositório local e tenta evitar conflitos
        try {
            git pull --rebase --autostash
        } catch {
            Write-Host "Aviso: erro ao puxar alterações remotas. Continuando..."
        }

        # Adiciona arquivo alterado
        git add "dados_para_painel/$($file.Name)"

        # Comita se houver mudanças
        $diff = git diff --cached
        if ($diff) {
            git commit -m "CSV atualizado automaticamente: $($file.Name)"
        } else {
            Write-Host "Nenhuma mudança para commitar."
        }

        # Push para o GitHub (não trava se houver conflito remoto)
        try {
            git push origin main
            Write-Host "CSV enviado com sucesso!"
        } catch {
            Write-Host "Aviso: push não foi realizado devido a conflito remoto."
        }
    }

    # Espera 2 segundos antes de checar novamente
    Start-Sleep -Seconds 2
}
