#!/bin/bash

# Script de otimização específico para CI/CD iOS
# Este script é executado automaticamente no ambiente CI

set -e

echo "🚀 Iniciando build iOS otimizado para CI..."
echo "📍 Working directory: $(pwd)"
echo "📅 Timestamp: $(date)"

# Configurações de ambiente para acelerar builds
export CI=true
export COCOAPODS_DISABLE_STATS=true
export COCOAPODS_DISABLE_DETERMINISTIC_UUIDS=true
export CP_DISABLE_ON_DOWNLOAD_HOOKS=true

# Configurações do Flutter para CI
export PUB_CACHE="$HOME/.pub-cache"
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn


cd ios 
echo "⚡ Executando pod install --deployment..."
pod install --deployment 

echo "✅ Pods instalados com sucesso"

# Verificar se os arquivos xcfilelist foram criados
echo "🔍 Verificando arquivos de integração..."
if [ ! -f "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist" ]; then
    echo "⚠️  Arquivo xcfilelist não encontrado, tentando reinstalar pods..."
    rm -rf Pods
    pod install --verbose
fi

cd ..

# Build otimizado para CI
echo "🔨 Executando build iOS otimizado..."
echo "🎯 Target: iOS Release (no codesign)"

# Configurar Xcode para reduzir warnings desnecessários no CI
export XCODE_WARN_SCRIPT_PHASE_OUTPUTS=NO

flutter build ios \
    --release \
    --no-codesign \
    --no-tree-shake-icons \
    --dart-define=CI=true 

echo "✅ Build iOS otimizado concluído!"
echo "📱 Artifact localizado em: build/ios/iphoneos/Runner.app"
echo "🕐 Finalizado em: $(date)"