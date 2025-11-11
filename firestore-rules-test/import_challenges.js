// Script para importar desafios do Giro Jogos 2024 para o Firestore usando Firebase Admin SDK
// Execute com: node firestore-rules-test/import_challenges.js
// Pré-requisito: npm install firebase-admin

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const jsonPath = path.resolve(__dirname, '../scripts/challenges_import.json');
const challengesData = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

// Verifica se o path da service account está definido e o arquivo existe
if (!serviceAccountPath) {
  console.error('Erro: variável GOOGLE_APPLICATION_CREDENTIALS não está definida');
  console.error('Execute: export GOOGLE_APPLICATION_CREDENTIALS="caminho/para/service-account.json"');
  process.exit(1);
}

if (!fs.existsSync(serviceAccountPath)) {
  console.error(`Erro: arquivo de service account não encontrado: ${serviceAccountPath}`);
  process.exit(1);
}

var serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function importChallenges() {
  try {
    const batch = db.batch();
    
    for (const challenge of challengesData.challenges) {      
      const docRef = db.collection('challenges').doc(String(challenge.id));
      batch.set(docRef, {
        id: challenge.id,
        title: challenge.title,
        description: challenge.description,
        order: challenge.order,
        maxPoints: challenge.maxPoints,
        isActive: challenge.id % 2 === 0 
      });
      console.log(`Preparando desafio ${challenge.id}...`);
    }
    
    await batch.commit();
    console.log('Todos os desafios foram importados com sucesso!');
    
  } catch (error) {
    console.error('Erro ao importar desafios:', error);
  } finally {
    admin.app().delete();
  }
}

importChallenges();
