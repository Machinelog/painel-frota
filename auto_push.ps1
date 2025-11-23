$folder = "$env:USERPROFILE\Documents\painel-frota\dados_para_painel"

Write-Host "Monitorando a pasta: $folder"
Write-Host "Sempre que você salvar um CSV, ele será enviado automaticamente."

while ($true) {
    $files = Get-ChildItem -Path $folder -Filter "*.csv" | Where-Object {
        (Get-Date) - $_.LastWriteTime -lt (New-TimeSpan -Seconds 3)
    }

    foreach ($file in $files) {
        Write-Host "Detectado novo CSV: $($file.Name)"
        Set-Location "$env:USERPROFILE\Documents\painel-frota"

        git add .
        git commit -m "CSV atualizado automaticamente: $($file.Name)" 2>$null
        git push

        Write-Host "Enviado com sucesso!"
    }

    Start-Sleep -Seconds 2
}
