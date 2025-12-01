// Script para definir custom claims de admin para usuários específicos
// Execute com: node firestore-rules-test/set_admin_claims.js
// Pré-requisito: npm install firebase-admin (já instalado no projeto)

const admin = require('firebase-admin');
const fs = require('fs');

// Lista de emails dos usuários que devem ser admins
const ADMIN_EMAILS = [
  'admin@admin.com',
  // Adicione mais emails aqui conforme necessário
  // 'outro-admin@example.com',
];

const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

// Verifica se o path da service account está definido e o arquivo existe
if (!serviceAccountPath) {
  console.error('❌ Erro: variável GOOGLE_APPLICATION_CREDENTIALS não está definida');
  console.error('Execute: export GOOGLE_APPLICATION_CREDENTIALS="caminho/para/service-account.json"');
  process.exit(1);
}

if (!fs.existsSync(serviceAccountPath)) {
  console.error(`❌ Erro: arquivo de service account não encontrado: ${serviceAccountPath}`);
  process.exit(1);
}

var serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function setAdminClaims() {
  console.log('🔧 Iniciando configuração de custom claims de admin...\n');
  
  let successCount = 0;
  let errorCount = 0;
  
  for (const email of ADMIN_EMAILS) {
    try {
      // Busca o usuário pelo email
      const user = await admin.auth().getUserByEmail(email);
      
      // Define a custom claim admin=true
      await admin.auth().setCustomUserClaims(user.uid, { admin: true });
      
      console.log(`✅ Admin claim definida para: ${email} (UID: ${user.uid})`);
      successCount++;
      
    } catch (error) {
      console.error(`❌ Erro ao processar ${email}: ${error.message}`);
      errorCount++;
    }
  }
  
  console.log('\n📊 Resumo:');
  console.log(`   ✅ Sucesso: ${successCount}`);
  console.log(`   ❌ Erros: ${errorCount}`);
  console.log('\n⚠️  IMPORTANTE: Os usuários precisam fazer logout e login novamente para que as claims sejam aplicadas!\n');
}

setAdminClaims()
  .then(() => {
    console.log('✨ Processo concluído!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Erro fatal:', error);
    process.exit(1);
  });
