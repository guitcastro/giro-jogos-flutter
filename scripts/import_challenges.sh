#!/usr/bin/env fish
# Script para importar desafios do Giro Jogos 2024 para o Firestore via Firebase CLI
# Uso: fish scripts/import_challenges.sh

set json_file scripts/challenges_import.json
set project giros-jogos

# Verifica se jq está instalado
if not type -q jq
    echo "Erro: 'jq' não está instalado. Instale com 'brew install jq' ou 'sudo apt install jq'"
    exit 1
end

set total (jq '.challenges | length' $json_file)
for idx in (seq 0 (math $total - 1))
    set id (jq -r ".challenges[$idx].id" $json_file)
    set doc_file "/tmp/challenge_$id.json"
    jq ".challenges[$idx]" $json_file > $doc_file
    echo "Importando desafio $id..."
    firebase firestore:set challenges/$id $doc_file --project $project
end

echo "Importação concluída!"
