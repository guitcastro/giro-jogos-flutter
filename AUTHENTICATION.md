# Implementação de Autenticação - Giro Jogos

## Funcionalidades Implementadas

### ✅ Autenticação com Firebase Auth
- Login/Cadastro com email e senha
- Login com Google
- Login com Apple (somente iOS)
- Gerenciamento de estado de autenticação
- Logout

### ✅ Proteção de Rotas
- Todas as telas exigem autenticação
- Redirecionamento automático para login quando não autenticado
- AuthWrapper para controle global de acesso

### ✅ Interface de Login
- Tela de login responsiva e moderna
- Alternância entre login e cadastro
- Validação de formulários
- Feedback visual de carregamento
- Tratamento de erros em português

### ✅ Perfil do Usuário
- Exibição de informações do usuário nas telas
- Avatar do usuário (foto ou iniciais)
- Menu de perfil com opção de logout

## Estrutura de Arquivos

```
lib/src/
├── services/
│   └── auth_service.dart          # Serviço de autenticação
├── screens/
│   ├── auth/
│   │   └── login_screen.dart      # Tela de login
│   ├── home/
│   │   └── home_screen.dart       # Tela inicial (protegida)
│   └── admin/
│       └── admin_screen.dart      # Tela admin (protegida)
├── auth_wrapper.dart              # Wrapper de proteção de rotas
└── app.dart                       # Configuração do app
```

## Dependências Adicionadas

```yaml
dependencies:
  # Auth
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.0
```

## Como Usar

### 1. Teste a Autenticação
1. Execute o app: `flutter run`
2. Você será redirecionado para a tela de login
3. Teste o cadastro com email/senha
4. Teste o login com Google (requer configuração)
5. Teste o login com Apple (somente iOS)

### 2. Configuração do Google Sign In

Para o Google Sign In funcionar completamente, você precisa:

#### Android
1. Adicionar o arquivo `google-services.json` em `android/app/`
2. Configurar no Firebase Console

#### iOS
1. Adicionar o arquivo `GoogleService-Info.plist` em `ios/Runner/`
2. Configurar URL schemes no iOS

### 3. Configuração do Apple Sign In

#### iOS
1. Habilitar "Sign in with Apple" no Apple Developer Console
2. Configurar no Firebase Console
3. Adicionar capability no iOS

## Funcionalidades da Tela de Login

### Campos e Validações
- **Email**: Validação de formato
- **Senha**: Mínimo 6 caracteres para cadastro
- **Mostrar/Ocultar senha**: Toggle de visibilidade

### Métodos de Autenticação
1. **Email/Senha**: Cadastro e login
2. **Google**: Login social
3. **Apple**: Login social (iOS only)

### Tratamento de Erros
- Mensagens em português
- Feedback visual para estados de carregamento
- Tratamento específico para códigos de erro do Firebase

### Estados da Interface
- **Carregamento**: Indicador visual durante autenticação
- **Erro**: SnackBar com mensagem
- **Alternância**: Botão para alternar entre login e cadastro

## Fluxo de Autenticação

1. **App inicia** → Verifica estado de autenticação
2. **Se não autenticado** → Mostra LoginScreen
3. **Se autenticado** → Mostra tela solicitada (Home/Admin)
4. **Logout** → Retorna para LoginScreen

## Gerenciamento de Estado

- **Provider**: Usado para gerenciar estado global de autenticação
- **AuthService**: ChangeNotifier que monitora mudanças de autenticação
- **Consumer**: Widgets reagem automaticamente a mudanças de estado

## Próximos Passos

1. Configurar Google Sign In no Firebase Console
2. Configurar Apple Sign In no Apple Developer Console
3. Adicionar recuperação de senha
4. Implementar verificação de email
5. Adicionar mais campos ao perfil do usuário
6. Implementar roles/permissões de usuário