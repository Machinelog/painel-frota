import os
import json

# Caminho da pasta historico
pasta = "./historico"

# Lista todos os arquivos CSV
csvs = [f for f in os.listdir(pasta) if f.endswith(".csv")]

# Ordena por nome (YYYY-MM-DD_HH-MM garante ordem cronológica)
csvs.sort()

# Pega o último CSV
ultimo = csvs[-1] if csvs else None

# Atualiza historico.json
historico_json_path = os.path.join(pasta, "historico.json")
with open(historico_json_path, "w") as f:
    json.dump({"arquivos": csvs}, f, indent=2)

# Atualiza ultimo.json
ultimo_json_path = os.path.join(pasta, "ultimo.json")
with open(ultimo_json_path, "w") as f:
    json.dump({"ultimo": ultimo}, f, indent=2)

print("Arquivos CSV encontrados:", csvs)
print("Último CSV registrado:", ultimo)
