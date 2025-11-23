# Caminho da pasta que será monitorada
$folder = "C:\Users\machi\OneDrive\Documentos\GitHub\painel-frota\dados_para_painel"

Write-Host "Monitorando a pasta: $folder"
Write-Host "Sempre que você salvar ou alterar um CSV, ele será enviado automaticamente."

while ($true) {
    # Detecta arquivos CSV novos ou modificados nos últimos 3 segundos
    $files = Get-ChildItem -Path $folder -Filter "*.csv" | Where-Object {
        (Get-Date) - $_.LastWriteTime -lt (New-TimeSpan -Seconds 3)
    }

    foreach ($file in $files) {
        Write-Host "Detectado CSV novo ou alterado: $($file.Name)"
        
        # Vai para a pasta do repositório
        Set-Location "C:\Users\machi\OneDrive\Documentos\GitHub\painel-frota"

        # Adiciona CSV novo ou alterado
        git add "dados_para_painel/$($file.Name)"

        # Só comita se houver mudanças
        git diff --cached --quiet || git commit -m "CSV atualizado automaticamente: $($file.Name)"

        # Push seguro: ignora conflito remoto
        git push origin main || Write-Host "Push ignorado por conflito remoto"
        
        Write-Host "CSV(s) processado(s) com sucesso!"
    }

    Start-Sleep -Seconds 2
}
