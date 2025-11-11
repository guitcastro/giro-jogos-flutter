// Testes de regras Firestore usando @firebase/rules-unit-testing
// Para rodar: 
// 1. Instale dependências: npm install
// 2. Rode o emulador: firebase emulators:start --only firestore
// 3. Execute: npm test

const fs = require('fs');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');

// Silence noisy Firestore SDK logs during tests (permission_denied diagnostics)
// We filter messages that come from '@firebase/firestore' while keeping other output intact
const __origConsole = { warn: console.warn, error: console.error, info: console.info, log: console.log };
function __shouldSuppressFirestoreLog(args) {
  try {
    const text = args.map(a => (typeof a === 'string' ? a : (a && a.message ? a.message : ''))).join(' ');
    return text.includes('@firebase/firestore');
  } catch (_) {
    return false;
  }
}
console.warn = (...args) => {
  if (__shouldSuppressFirestoreLog(args)) return;
  return __origConsole.warn(...args);
};
console.error = (...args) => {
  if (__shouldSuppressFirestoreLog(args)) return;
  return __origConsole.error(...args);
};

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
});

after(async () => {
  await testEnv.cleanup();
});

describe('Firestore Security Rules - Duos', () => {
  it('Usuário pode criar, ler e escrever seu próprio duo em /users/{userId}/duo/current', async () => {
    const userId = 'user123';
    const db = testEnv.authenticatedContext(userId).firestore();
    // O próprio usuário pode criar
    await assertSucceeds(db.doc(`users/${userId}/duo/current`).set({
      duoId: 'duo456',
      inviteCode: 'ABC123',
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
    // O próprio usuário pode ler
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
  
  it('Usuário pode sair de um duo (update removendo ele da lista, restando outro participante)', async () => {
    const userId = 'user123';
    const otherId = 'user456';
    const inviteCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    const duoId = 'duo' + Math.floor(Math.random() * 1000000).toString();
    // Cria o duo com dois participantes
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duos/${duoId}/invites/${inviteCode}`).set({
        participants: [
          { id: userId, name: 'User 123' },
          { id: otherId, name: 'User 456' }
        ],
        name: 'Meu Duo',
        inviteCode,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
    // Usuário sai (update: remove userId)
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertSucceeds(db.doc(`duos/${duoId}/invites/${inviteCode}`).update({
      participants: [
        { id: otherId, name: 'User 456' }
      ],
      inviteCode,
      updatedAt: new Date(),
    }));
  });

  it('Usuário autenticado pode criar um duo válido', async () => {
    const userId = 'user123';
    const inviteCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    const duoId = 'duo' + Math.floor(Math.random() * 1000000).toString();
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertSucceeds(db.doc(`duos/${duoId}/invites/${inviteCode}`).set({
      participants: [{ id: userId, name: 'User 123' }],
      name: 'Meu Duo',
      inviteCode,
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  });
  it('Não permite criar duo com mais de um participante', async () => {
    const userId = 'user123';
    const inviteCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    const duoId = 'duo' + Math.floor(Math.random() * 1000000).toString();
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertFails(db.doc(`duos/${duoId}/invites/${inviteCode}`).set({
      participants: [
        { id: userId, name: 'User 123' },
        { id: 'user456', name: 'Outro' }
      ],
      name: 'Meu Duo',
      inviteCode,
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  });
  it('Não permite criar duo se id do participante for diferente do usuário autenticado', async () => {
    const userId = 'user123';
    const inviteCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    const duoId = 'duo' + Math.floor(Math.random() * 1000000).toString();
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertFails(db.doc(`duos/${duoId}/invites/${inviteCode}`).set({
      participants: [{ id: 'user456', name: 'Outro' }],
      name: 'Meu Duo',
      inviteCode,
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  });
  it('Participante pode deletar seu próprio duo', async () => {
    const userId = 'user123';
    const inviteCode = 'ABC123';
    const duoId = 'duo456';
    // Cria o duo como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duos/${duoId}/invites/${inviteCode}`).set({
        participants: [{ id: userId, name: 'User 123' }],
        name: 'Meu Duo',
        inviteCode,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
    // Participante pode deletar
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertSucceeds(db.doc(`duos/${duoId}/invites/${inviteCode}`).delete());
  });
  
  it('Usuário só lê duo se passar inviteCode correto', async () => {
    const userId = 'user123';
    const inviteCode = 'ABC123'; // 6 caracteres
    const duoId = 'duo456';
    // Cria o duo como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duos/${duoId}/invites/${inviteCode}`).set({
  participants: [{ id: userId, name: 'User 123' }],
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
        participants: [
          { id: userId, name: 'User 123' },
          { id: 'user456', name: 'User 456' }
        ],
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
        participants: [
          { id: userId, name: 'User 123' },
          { id: 'user456', name: 'User 456' }
        ],
        name: 'Meu Duo',
        inviteCode,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
    // Tenta atualizar para 3 participantes
    const db = testEnv.authenticatedContext(userId).firestore();
    await assertFails(db.doc(`duos/${duoId}/invites/${inviteCode}`).update({
      participants: [
        { id: userId, name: 'User 123' },
        { id: 'user2', name: 'User 2' },
        { id: 'user3', name: 'User 3' }
      ],
      updatedAt: new Date(),
    }));
  });
});

describe('Firestore Security Rules - Challenges', () => {
  it('Usuário autenticado pode ler challenge ativo individual', async () => {
    const challengeId = '1';
    // Cria challenge ativo como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`challenges/${challengeId}`).set({
        id: 1,
        title: 'Desafio 1',
        description: 'Descrição do desafio 1',
        order: 1,
        maxPoints: 200,
        isActive: true,
      });
    });
    
    // Usuário autenticado pode ler
    const db = testEnv.authenticatedContext('user123').firestore();
    await assertSucceeds(db.doc(`challenges/${challengeId}`).get());
  });

  it('Usuário autenticado NÃO pode ler challenge inativo individual', async () => {
    const challengeId = '2';
    // Cria challenge inativo como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`challenges/${challengeId}`).set({
        id: 2,
        title: 'Desafio 2',
        description: 'Descrição do desafio 2',
        order: 2,
        maxPoints: 300,
        isActive: false,
      });
    });
    
    // Usuário autenticado NÃO pode ler challenge inativo
    const db = testEnv.authenticatedContext('user123').firestore();
    await assertFails(db.doc(`challenges/${challengeId}`).get());
  });

  it('Usuário autenticado NÃO pode ler coleção challenges (comportamento com mix ativo/inativo)', async () => {
    // Limpa a coleção primeiro
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const firestore = ctx.firestore();
      const snapshot = await firestore.collection('challenges').get();
      const batch = firestore.batch();
      snapshot.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
    });

    // Cria alguns challenges (ativos e inativos) como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const firestore = ctx.firestore();
      await firestore.doc('challenges/1').set({
        id: 1,
        title: 'Desafio 1 Ativo',
        description: 'Descrição do desafio 1',
        order: 1,
        maxPoints: 200,
        isActive: true,
      });
      await firestore.doc('challenges/2').set({
        id: 2,
        title: 'Desafio 2 Inativo',
        description: 'Descrição do desafio 2',
        order: 2,
        maxPoints: 300,
        isActive: false,
      });
      await firestore.doc('challenges/3').set({
        id: 3,
        title: 'Desafio 3 Ativo',
        description: 'Descrição do desafio 3',
        order: 3,
        maxPoints: 400,
        isActive: true,
      });
    });
    
    // Teste: usuario autenticado tenta ler a coleção inteira - deve falhar
    const db = testEnv.authenticatedContext('user123').firestore();
    await assertFails(db.collection('challenges').get());
  });

  it('Usuário autenticado pode fazer query com where isActive=true', async () => {
    const db = testEnv.authenticatedContext('user123').firestore();
    await assertSucceeds(db.collection('challenges').where('isActive', '==', true).get());
  });

  // after(async () => {
  //   // Limpa dados antes do próximo teste
  //   await testEnv.clearFirestore();
  // });
});

describe('Firestore Security Rules - Challenge Submissions', () => {
  // IDs constantes para evitar recriações e conflitos de ambiente
  const CHALLENGE_ID = 'challenge_submissions_test';
  const DUO_ID = 'duo_submissions_test';
  const INVITE_CODE = 'SUB123';
  const MEMBER_USER_ID = 'user_sub_member';
  const OUTSIDER_USER_ID = 'user_sub_outsider';
  const SUBMISSION_VALID_ID = 'submission_valid';
  const SUBMISSION_OUTSIDER_ID = 'submission_outsider_attempt';

  before(async () => {
    // Limpa restos antigos (se existirem) e cria fixtures necessárias
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const f = ctx.firestore();
      // Delete antigos se existirem
      await f.doc(`challenges/${CHALLENGE_ID}`).delete().catch(()=>{});
      await f.doc(`challenges/${CHALLENGE_ID}/submissions/${SUBMISSION_VALID_ID}`).delete().catch(()=>{});
      await f.doc(`challenges/${CHALLENGE_ID}/submissions/${SUBMISSION_OUTSIDER_ID}`).delete().catch(()=>{});
      await f.doc(`duos/${DUO_ID}/invites/${INVITE_CODE}`).delete().catch(()=>{});
      await f.doc(`users/${MEMBER_USER_ID}/duo/current`).delete().catch(()=>{});
      // Cria challenge ativo
      await f.doc(`challenges/${CHALLENGE_ID}`).set({
        id: 9999,
        title: 'Desafio Submissions',
        description: 'Descrição teste submissions',
        order: 9999,
        maxPoints: 100,
        isActive: true,
      });
      // Cria duo com participante membro
      await f.doc(`duos/${DUO_ID}/invites/${INVITE_CODE}`).set({
        participants: [{ id: MEMBER_USER_ID, name: 'Member User' }],
        name: 'Duo Submissions',
        inviteCode: INVITE_CODE,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
      // Referência de duo para o membro
      await f.doc(`users/${MEMBER_USER_ID}/duo/current`).set({
        duoId: DUO_ID,
        inviteCode: INVITE_CODE,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
  });

  it('Membro da dupla pode listar submissões mesmo quando não há nenhuma', async () => {
    const db = testEnv.authenticatedContext(MEMBER_USER_ID).firestore();
    // Deve conseguir listar (get) a coleção, mesmo que esteja vazia
    await assertSucceeds(db.collection(`challenges/${CHALLENGE_ID}/submissions`).get());
  });

  it('Usuário não membro da dupla não pode criar submission', async () => {
    const db = testEnv.authenticatedContext(OUTSIDER_USER_ID).firestore();
    await assertFails(
      db.doc(`challenges/${CHALLENGE_ID}/submissions/${SUBMISSION_OUTSIDER_ID}`).set({
        duoId: DUO_ID,
        duoInviteCode: INVITE_CODE,
        mediaUrl: 'https://example.com/photo.jpg',
        mediaType: 'image',
        submissionTime: new Date(),
      })
    );
  });

  it('Membro da dupla pode criar submission válida', async () => {
    const db = testEnv.authenticatedContext(MEMBER_USER_ID).firestore();
    await assertSucceeds(
      db.doc(`challenges/${CHALLENGE_ID}/submissions/${SUBMISSION_VALID_ID}`).set({
        duoId: DUO_ID,
        duoInviteCode: INVITE_CODE,
        mediaUrl: 'https://example.com/photo.jpg',
        mediaType: 'image',
        submissionTime: new Date(),
      })
    );
  });
});

describe('Firestore Security Rules - Duo Submissions Index', () => {
  let duoId, userId1, inviteCode;

  before(async () => {
    duoId = 'duo' + Math.floor(Math.random() * 1000000).toString();
    inviteCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    userId1 = 'user123';

    // Cria duo
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duos/${duoId}/invites/${inviteCode}`).set({
        participants: [{ id: userId1, name: 'User 123' }],
        name: 'Duo Teste',
        inviteCode,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });

    // Cria referência de duo para o usuário
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`users/${userId1}/duo/current`).set({
        duoId,
        inviteCode,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    });
  });

  it('Membro da dupla pode ler índice de submissions', async () => {
    const challengeId = '1';
    
    // Cria índice como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duo_submissions_index/${duoId}/challenges/${challengeId}`).set({
        submissionCount: 1,
        lastSubmission: new Date(),
      });
    });

    const db = testEnv.authenticatedContext(userId1).firestore();
    await assertSucceeds(
      db.doc(`duo_submissions_index/${duoId}/challenges/${challengeId}`).get()
    );
  });

  it('Usuário não membro da dupla não pode ler índice', async () => {
    const challengeId = '1';
    const outsiderUserId = 'outsider999';
    
    // Cria índice como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duo_submissions_index/${duoId}/challenges/${challengeId}`).set({
        submissionCount: 1,
        lastSubmission: new Date(),
      });
    });

    const db = testEnv.authenticatedContext(outsiderUserId).firestore();
    await assertFails(
      db.doc(`duo_submissions_index/${duoId}/challenges/${challengeId}`).get()
    );
  });

  it('Membro da dupla pode ler documento principal do índice', async () => {
    // Cria índice principal como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duo_submissions_index/${duoId}`).set({
        totalSubmissions: 5,
        lastActivity: new Date(),
      });
    });

    const db = testEnv.authenticatedContext(userId1).firestore();
    await assertSucceeds(
      db.doc(`duo_submissions_index/${duoId}`).get()
    );
  });

  it('Nenhum usuário pode escrever no índice (apenas sistema)', async () => {
    const challengeId = '1';
    const db = testEnv.authenticatedContext(userId1).firestore();
    
    await assertFails(
      db.doc(`duo_submissions_index/${duoId}/challenges/${challengeId}`).set({
        submissionCount: 1,
        lastSubmission: new Date(),
      })
    );

    await assertFails(
      db.doc(`duo_submissions_index/${duoId}`).set({
        totalSubmissions: 5,
        lastActivity: new Date(),
      })
    );
  });

  it('Admin pode ler qualquer índice', async () => {
    const adminUserId = 'admin123';
    const challengeId = '1';
    
    // Cria admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`users/${adminUserId}`).set({
        email: 'admin@example.com',
        isAdmin: true,
        name: 'Admin User',
      });
    });

    // Cria índice como admin
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`duo_submissions_index/${duoId}/challenges/${challengeId}`).set({
        submissionCount: 1,
        lastSubmission: new Date(),
      });
    });

    const db = testEnv.authenticatedContext(adminUserId).firestore();
    await assertSucceeds(
      db.doc(`duo_submissions_index/${duoId}/challenges/${challengeId}`).get()
    );
  });
});
