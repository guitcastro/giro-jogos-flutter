# Configuração do Google Sign In para Web

## ❗ PASSOS OBRIGATÓRIOS PARA FUNCIONAR

### 1. Configure no Firebase Console

1. **Acesse**: https://console.firebase.google.com
2. **Selecione o projeto**: `giro-jogos`
3. **Vá para**: Authentication > Sign-in method
4. **Clique em "Google"** e habilite
5. **Adicione seu email** como email de suporte
6. **Salve as alterações**

### 2. Obtenha o Web Client ID

1. **No Firebase Console**: Project Settings (ícone de engrenagem)
2. **Aba General** > role até "Your apps"
3. **Na seção Web apps**, clique na sua app web
4. **Copie o Web Client ID** 
   - Deve ser algo como: `820256283325-abc123def456.apps.googleusercontent.com`

### 3. Configure o Client ID no código

1. **Abra o arquivo**: `/web/index.html`
2. **Encontre a linha**:
   ```html
   <meta name="google-signin-client_id" content="820256283325-SUBSTITUA_PELO_SEU_WEB_CLIENT_ID.apps.googleusercontent.com">
   ```
3. **Substitua** `SUBSTITUA_PELO_SEU_WEB_CLIENT_ID` pelo Client ID real que você copiou

### 4. Configure domínios autorizados

1. **No Firebase Console**: Authentication > Settings
2. **Na seção "Authorized domains"**
3. **Adicione**:
   - `localhost` (para desenvolvimento)
   - `127.0.0.1` (alternativa para localhost)

### 5. Teste

1. **Reinicie o app** Flutter: `flutter run -d web-server --web-port 8080`
2. **Acesse**: http://localhost:8080
3. **Clique em "Google"** no login
4. **Deve abrir o popup do Google** para autenticação

## 🔧 Resolução de Problemas

### Se ainda não funcionar:

#### Problema 1: "popup_blocked_by_browser"
- **Solução**: Permita popups para localhost no seu navegador

#### Problema 2: "invalid_client"
- **Solução**: Verifique se o Web Client ID está correto no index.html

#### Problema 3: "unauthorized_domain"
- **Solução**: Adicione localhost aos domínios autorizados no Firebase

### Como verificar se está configurado:

1. **Abra as ferramentas do desenvolvedor** (F12)
2. **Vá para Console**
3. **Clique em login com Google**
4. **Verifique se há erros** relacionados a Google Sign In

## 📱 Para Produção

Quando fizer deploy:
1. **Adicione seu domínio** aos "Authorized domains" no Firebase
2. **Configure o domínio** no Google Cloud Console se necessário

## ✅ Status Atual

- ✅ Firebase configurado
- ✅ AuthService criado
- ✅ UI implementada
- ✅ **google-services.json** adicionado em `/android/app/`
- ✅ **Web Client ID** configurado no index.html
- ⚠️  **FALTA**: Habilitar Google Sign In no Firebase Console
