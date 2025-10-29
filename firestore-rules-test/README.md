# Firestore Rules Test

Este projeto executa testes automatizados das regras de segurança do Firestore do projeto giro-jogos-flutter usando o Firebase Emulator Suite.

## Como rodar localmente

1. Instale as dependências:

```sh
cd firestore-rules-test
npm install
```

2. Inicie o emulador do Firestore (na raiz do projeto):

```sh
firebase emulators:start --only firestore
```

3. Em outro terminal, execute os testes:

```sh
npm test
```

## Estrutura
- `firestore.rules.test.js`: testes automatizados das regras
- `../firestore.rules`: arquivo de regras do Firestore (referenciado nos testes)

## CI
Para rodar no CI, adicione os passos:
- Instalar Node.js
- Instalar dependências (npm install)
- Iniciar o emulador do Firestore
- Executar `npm test`

Exemplo para GitHub Actions:
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
- run: npm install -g firebase-tools
- run: npm install
  working-directory: firestore-rules-test
- run: firebase emulators:start --only firestore &
  working-directory: .
- run: npm test
  working-directory: firestore-rules-test
```
