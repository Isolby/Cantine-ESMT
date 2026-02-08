const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialiser avec les credentials par défaut (dev)
try {
  admin.initializeApp();
} catch (error) {
  console.log('ℹ️ Firebase déjà initialisé');
}

const messaging = admin.messaging();

/**
 * Test 1: Envoyer une notification à un topic
 */
async function testTopicNotification() {
  try {
    console.log('🧪 Test 1: Envoi d\'une notification au topic...\n');

    const response = await messaging.sendToTopic('nouvelles_commandes', {
      notification: {
        title: '🍽️ Nouvelle commande de test!',
        body: 'Commande #TEST-001 - 5000 FCFA',
      },
      data: {
        commandeId: 'TEST-001',
        total: '5000',
        etat: 'enAttente',
        type: 'nouvelle_commande',
        timestamp: new Date().toISOString(),
      },
      webpush: {
        fcmOptions: {
          link: 'https://example.com',
        },
      },
    });

    console.log('✅ Notification envoyée!');
    console.log('📊 Message ID:', response);
    console.log('');
  } catch (error) {
    console.error('❌ Erreur:', error);
  }
}

/**
 * Test 2: Envoyer une notification de mise à jour de statut
 */
async function testStatusNotification() {
  try {
    console.log('🧪 Test 2: Envoi d\'une notification de statut...\n');

    const response = await messaging.sendToTopic('nouvelles_commandes', {
      notification: {
        title: '📦 Mise à jour de commande',
        body: 'Commande #TEST-002: Prête à être récupérée!',
      },
      data: {
        commandeId: 'TEST-002',
        nouveauStatut: 'pret',
        type: 'mise_a_jour_statut',
        timestamp: new Date().toISOString(),
      },
    });

    console.log('✅ Notification de statut envoyée!');
    console.log('📊 Message ID:', response);
    console.log('');
  } catch (error) {
    console.error('❌ Erreur:', error);
  }
}

/**
 * Test 3: Envoyer une notification de rupture
 */
async function testRuptureNotification() {
  try {
    console.log('🧪 Test 3: Envoi d\'une notification de rupture...\n');

    const response = await messaging.sendToTopic('nouvelles_commandes', {
      notification: {
        title: '⚠️ Rupture de stock',
        body: 'Commande #TEST-003: Rupture de stock',
      },
      data: {
        commandeId: 'TEST-003',
        nouveauStatut: 'rupture',
        type: 'mise_a_jour_statut',
        timestamp: new Date().toISOString(),
      },
    });

    console.log('✅ Notification de rupture envoyée!');
    console.log('📊 Message ID:', response);
    console.log('');
  } catch (error) {
    console.error('❌ Erreur:', error);
  }
}

/**
 * Lancer tous les tests
 */
async function runAllTests() {
  console.log('\n════════════════════════════════════════');
  console.log('   🚀 TESTS DES NOTIFICATIONS FIREBASE');
  console.log('════════════════════════════════════════\n');

  await testTopicNotification();
  await new Promise(resolve => setTimeout(resolve, 2000));

  await testStatusNotification();
  await new Promise(resolve => setTimeout(resolve, 2000));

  await testRuptureNotification();

  console.log('════════════════════════════════════════');
  console.log('   ✅ TOUS LES TESTS SONT TERMINÉS');
  console.log('════════════════════════════════════════\n');

  process.exit(0);
}

// Lancer les tests
runAllTests().catch(console.error);
