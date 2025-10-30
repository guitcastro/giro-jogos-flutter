describe('Firestore Security Rules - User Duo Document', () => {
  it('Usuário pode ler e escrever seu próprio duo em /users/{userId}/duo/current', async () => {
    const userId = 'user123';
    // Cria o duo como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`users/${userId}/duo/current`).set({
        duoId: 'duo456',
        inviteCode: 'ABC123',
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
    // O próprio usuário pode ler
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertSucceeds(db.doc(`users/${userId}/duo/current`).get());
    // O próprio usuário pode escrever
    await assertSucceeds(db.doc(`users/${userId}/duo/current`).set({
      duoId: 'duo456',
      inviteCode: 'ABC123',
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  });

  it('Outro usuário NÃO pode ler ou escrever em /users/{userId}/duo/current', async () => {
    const userId = 'user123';
    // Cria o duo como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`users/${userId}/duo/current`).set({
        duoId: 'duo456',
        inviteCode: 'ABC123',
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
    // Outro usuário não pode ler
    const db = testEnv.authenticatedContext('user999').firestore();
    await assertFails(db.doc(`users/${userId}/duo/current`).get());
    // Outro usuário não pode escrever
    await assertFails(db.doc(`users/${userId}/duo/current`).set({
      duoId: 'duo456',
      inviteCode: 'ABC123',
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  });
});
// Testes de regras Firestore usando @firebase/rules-unit-testing
// Para rodar: 
// 1. Instale dependências: npm install
// 2. Rode o emulador: firebase emulators:start --only firestore
// 3. Execute: npm test

const fs = require('fs');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { setLogLevel } = require('firebase/firestore');

const rules = fs.readFileSync('../firestore.rules', 'utf8');

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "demo-firestore-rules-test",
    firestore: {
      host: "localhost",
      port: 8080,
      rules,
    },
  });
  setLogLevel('error');
});

after(async () => {
  await testEnv.cleanup();
});

describe('Firestore Security Rules - Duos', () => {
  it('Usuário só lê duo se passar inviteCode correto', async () => {
    const userId = 'user123';
    const inviteCode = 'ABC123'; // 6 caracteres
    const duoId = 'duo456';
    // Cria o duo como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duos/${duoId}/invites/${inviteCode}`).set({
        participants: [userId],
        name: 'Meu Duo',
        inviteCode,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
    // Tenta ler o documento correto
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertSucceeds(db.doc(`duos/${duoId}/invites/${inviteCode}`).get());
  });

  it('Usuário não lê duo se inviteCode incorreto', async () => {
    const userId = 'user123';
    const inviteCode = 'ABC123';
    const duoId = 'duo456';
    // Cria o duo como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duos/${duoId}/invites/${inviteCode}`).set({
        participants: [userId, 'user456'],
        name: 'Meu Duo',
        inviteCode,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
    // Tenta ler com inviteCode errado
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertFails(db.doc(`duos/${duoId}/invites/ERRADO1`).get());
  });

  it('Duo nunca pode ter mais de 2 participantes', async () => {
    const userId = 'user123';
    const inviteCode = 'ABC123';
    const duoId = 'duo456';
    // Cria o duo como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duos/${duoId}/invites/${inviteCode}`).set({
        participants: [userId, 'user456'],
        name: 'Meu Duo',
        inviteCode,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
    // Tenta atualizar para 3 participantes
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertFails(db.doc(`duos/${duoId}/invites/${inviteCode}`).update({
      participants: [userId, 'user2', 'user3'],
      updatedAt: new Date(),
    }));
  });
});
