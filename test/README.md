# Testes de Autenticação - Giro Jogos

Este diretório contém todos os testes para a feature de autenticação da aplicação Giro Jogos.

## Estrutura dos Testes

### 📁 services/
Testes unitários para os serviços de autenticação:
- `auth_service_test.dart` - Testa o AuthService com diferentes cenários de login/logout

### 📁 screens/auth/
Testes de widget para as telas de autenticação:
- `login_screen_test.dart` - Testa a LoginScreen com validações, interações e estados

### 📁 widgets/
Testes de widget para componentes específicos:
- `auth_wrapper_test.dart` - Testa o AuthWrapper que protege as rotas

### 📁 integration/
Testes de integração para fluxos completos:
- `auth_integration_test.dart` - Testa fluxos completos de autenticação

## Executando os Testes

### Todos os testes
```bash
flutter test
```

### Testes específicos
```bash
# Testes do AuthService
flutter test test/services/auth_service_test.dart

# Testes da LoginScreen
flutter test test/screens/auth/login_screen_test.dart

# Testes do AuthWrapper
flutter test test/widgets/auth_wrapper_test.dart

# Testes de integração
flutter test test/integration/auth_integration_test.dart
```

### Com coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Cenários Testados

### 🔐 AuthService
- [x] Estado inicial (não autenticado)
- [x] Login com email/senha (credenciais inválidas)
- [x] Cadastro com senha fraca
- [x] Email com formato inválido
- [x] Google Sign In (estrutura)
- [x] Apple Sign In (estrutura)
- [x] Logout

### 🎨 LoginScreen
- [x] Elementos da UI presentes
- [x] Alternância entre modo login/cadastro
- [x] Mostrar/ocultar senha
- [x] Validação de email
- [x] Validação de campos obrigatórios
- [x] Validação de comprimento da senha (cadastro)
- [x] Chamada do AuthService com dados corretos
- [x] Tratamento de erros

### 🛡️ AuthWrapper
- [x] Mostra tela de login quando não autenticado
- [x] Mostra conteúdo protegido quando autenticado
- [x] Reage a mudanças no estado de autenticação

### 🔄 Integração
- [x] Fluxo completo: login → home screen
- [x] Navegação entre modos login/cadastro
- [x] Fluxo de logout: home screen → login
- [x] Validação de formulário
- [x] Tratamento de credenciais inválidas

## Mocks Utilizados

### MockAuthService
Mock customizado que implementa `AuthService` para testar:
- Estados de autenticação
- Simulação de erros
- Captura de parâmetros de entrada
- Notificação de mudanças de estado

## Estrutura dos Testes

### Padrão AAA (Arrange, Act, Assert)
```dart
test('should do something', () async {
  // Arrange - configurar o teste
  mockAuthService.setShouldThrowError(true);
  
  // Act - executar a ação
  await authService.signIn('email', 'password');
  
  // Assert - verificar o resultado
  expect(authService.isAuthenticated, isFalse);
});
```

### Widget Tests
```dart
testWidgets('should show login form', (WidgetTester tester) async {
  await tester.pumpWidget(createTestWidget());
  
  expect(find.text('Email'), findsOneWidget);
  expect(find.text('Senha'), findsOneWidget);
});
```

## Limitações Atuais

### 🚧 Áreas para Melhoria

1. **Mocks mais sofisticados**: Usar bibliotecas como `mockito` para mocks mais robustos
2. **Testes com Firebase real**: Usar Firebase Emulator Suite para testes mais realistas
3. **Testes de Golden**: Adicionar testes de screenshots para UI
4. **Testes de performance**: Verificar tempo de resposta das operações
5. **Testes de acessibilidade**: Garantir que a UI seja acessível

### 📝 Próximos Passos

- [ ] Adicionar testes com Firebase Auth Emulator
- [ ] Implementar mocks mais robustos com Mockito
- [ ] Adicionar testes de Golden para componentes visuais
- [ ] Criar testes E2E com integration_test
- [ ] Adicionar testes de acessibilidade
- [ ] Implementar testes de performance

## Executando em CI/CD

### GitHub Actions
```yaml
- name: Run tests
  run: flutter test --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    file: coverage/lcov.info
```

## Debugging de Testes

### Prints úteis
```dart
test('debug test', () async {
  await tester.pumpWidget(widget);
  
  // Debug widgets presentes
  print(tester.allWidgets.map((w) => w.runtimeType).toList());
  
  // Debug texto visível
  print(find.text('texto').evaluate());
});
```

### Pump vs PumpAndSettle
```dart
// Para animações simples
await tester.pump();

// Para animações complexas ou navegação
await tester.pumpAndSettle();
```