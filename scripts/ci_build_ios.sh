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

echo "✅ Variáveis de ambiente configuradas"

# Verifica se é um build incremental
echo "🔍 Verificando cache de pods..."
if [ -f "ios/Podfile.lock" ] && [ -d "ios/Pods" ]; then
    echo "📦 Usando cache de pods existente..."
    cd ios 
    echo "⚡ Executando pod install --deployment..."
    pod install --deployment --verbose
else
    echo "📦 Instalação completa de pods (primeira vez)..."
    cd ios
    echo "⚡ Executando pod install --repo-update..."
    pod install --repo-update --verbose
fi

echo "✅ Pods instalados com sucesso"
cd ..

# Build otimizado para CI
echo "🔨 Executando build iOS otimizado..."
echo "🎯 Target: iOS Release (no codesign)"

flutter build ios \
    --release \
    --no-codesign \
    --no-tree-shake-icons \
    --dart-define=CI=true \
    --dart-define=FLUTTER_WEB_USE_SKIA=false \
    --verbose

echo "✅ Build iOS otimizado concluído!"
echo "📱 Artifact localizado em: build/ios/iphoneos/Runner.app"
echo "🕐 Finalizado em: $(date)"