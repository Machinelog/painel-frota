# Caminho da pasta que será monitorada
$folder = "C:\Users\machi\OneDrive\Documentos\GitHub\painel-frota\dados_para_painel"
$repo = "C:\Users\machi\OneDrive\Documentos\GitHub\painel-frota"
$historico = "$repo\historico"

Write-Host "Monitorando a pasta: $folder"
Write-Host "Sempre que você salvar ou alterar um CSV, ele será enviado automaticamente."

while ($true) {
    $files = Get-ChildItem -Path $folder -Filter "*.csv" | Where-Object {
        (Get-Date) - $_.LastWriteTime -lt (New-TimeSpan -Seconds 3)
    }

    foreach ($file in $files) {
        Write-Host "Detectado CSV novo ou alterado: $($file.Name)"
        
        # Copia para historico
        Copy-Item -Path $file.FullName -Destination $historico -Force

        # Vai para a pasta do repositório
        Set-Location $repo

        # Atualiza repositório com autostash para evitar conflito
        try {
            git pull --rebase --autostash
        } catch {
            Write-Host "Não foi possível puxar alterações remotas. Continuando..."
        }

        # Atualiza os JSONs
        python gerar_ultimo.py

        # Adiciona CSV e JSONs
        git add "dados_para_painel/$($file.Name)"
        git add "historico/ultimo.json" "historico/historico.json"

        # Comita se houver mudanças
        $hasChanges = git diff --cached --quiet
        if (-not $hasChanges) {
            git commit -m "Atualização automática: $($file.Name) + JSONs"
        }

        # Push seguro
        try {
            git push origin main
        } catch {
            Write-Host "Push ignorado devido a alterações remotas"
        }

        Write-Host "CSV e JSONs enviados com sucesso!"
    }

    Start-Sleep -Seconds 2
}
