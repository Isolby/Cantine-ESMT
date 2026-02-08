const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// ⚙️ VARIABLE DE CONTRÔLE - Changer à false pour désactiver les notifications de test
const ENABLE_TEST_NOTIFICATIONS = true;

// Fonction déclenchée à chaque nouvelle commande
exports.sendNewCommandeNotification = functions.firestore
  .document('commandes/{commandeId}')
  .onCreate(async (snap, context) => {
    try {
      const commande = snap.data();
      const commandeId = context.params.commandeId;

      console.log('🔔 Nouvelle commande créée:', commandeId);

      // ✅ OPTIMISATION: Envoyer DIRECTEMENT au TOPIC (pas de recherche DB = temps réel)
      // Formater le message de façon professionnelle
      const nomEtudiant = commande.etudiant || 'Client'; // Note: le champ s'appelle 'etudiant' et non 'nomEtudiant'
      const montant = commande.total ? commande.total.toFixed(0) : '0';
      const plats = commande.plats || []; // Note: le champ s'appelle 'plats' et non 'articles'
      const nombreArticles = Array.isArray(plats) ? plats.length : 0;

      const message = {
        notification: {
          title: `📋 Commande de ${nomEtudiant}`,
          body: `Montant: ${montant} FCFA • ${nombreArticles > 0 ? nombreArticles + ' article(s)' : 'En attente de traitement'}`,
        },
        data: {
          commandeId: commandeId,
          etudiant: nomEtudiant,
          total: montant,
          statut: commande.etat || 'enAttente',
          type: 'nouvelle_commande',
          timestamp: new Date().toISOString(),
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
          nombreArticles: nombreArticles.toString(),
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'high_importance_channel',
            sound: 'default',
            priority: 'high',
            defaultVibrateTimings: true,
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
          },
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              'mutable-content': 1,
            },
          },
        },
        topic: 'nouvelles_commandes', // ✅ ENVOI DIRECT AU TOPIC = TEMPS RÉEL
      };

      // Envoyer immédiatement sans recherche de tokens
      const response = await admin.messaging().send(message);

      console.log(`✅ Notification envoyée au topic en temps réel. Message ID: ${response}`);
      return { success: true, messageId: response };

    } catch (error) {
      console.error('❌ Erreur lors de l\'envoi de la notification:', error);
      return { success: false, error: error.message };
    }
  });

// ✅ NOUVEAU: Notification de test chaque minute (pour les tests)
exports.sendTestNotificationEveryMinute = functions.pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    if (!ENABLE_TEST_NOTIFICATIONS) {
      console.log('⏸️ Notifications de test désactivées');
      return null;
    }

    try {
      const now = new Date();
      const time = now.toLocaleTimeString('fr-FR');
      
      console.log(`🧪 Envoi notification de test à ${time}`);

      const message = {
        notification: {
          title: '🆕 Nouvelle commande reçue !',
          body: `Test notification envoyée à ${time}`,
        },
        data: {
          type: 'test_notification',
          timestamp: new Date().toISOString(),
          testMode: 'true',
          testTime: time,
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'high_importance_channel',
            sound: 'default',
            priority: 'high',
            color: '#4CAF50', // Vert pour les tests
            defaultVibrateTimings: true,
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
          },
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              'mutable-content': 1,
            },
          },
        },
        topic: 'nouvelles_commandes', // Envoyer à tous les abonnés
      };

      const response = await admin.messaging().send(message);
      console.log(`✅ Notification de test envoyée. Message ID: ${response}`);

      return { success: true, messageId: response, time: time };

    } catch (error) {
      console.error('❌ Erreur notification de test:', error);
      return { success: false, error: error.message };
    }
  });

// ✅ NOUVEAU: Notification de test immédiate (callable)
exports.sendTestNotificationNow = functions.https.onCall(async (data, context) => {
  if (!ENABLE_TEST_NOTIFICATIONS) {
    throw new functions.https.HttpsError('failed-precondition', 'Notifications de test désactivées');
  }

  try {
    console.log('🚀 Notification de test immédiate demandée');

    const message = {
      notification: {
        title: '🚀 Test immédiat !',
        body: 'Ceci est une notification de test envoyée maintenant',
      },
      data: {
        type: 'test_notification_now',
        timestamp: new Date().toISOString(),
        immediateTest: 'true',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          sound: 'default',
          priority: 'high',
          color: '#FF9800', // Orange pour les tests immédiats
          defaultVibrateTimings: true,
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      topic: 'nouvelles_commandes',
    };

    const response = await admin.messaging().send(message);
    console.log(`✅ Notification de test immédiate envoyée. Message ID: ${response}`);

    return {
      success: true,
      messageId: response,
      message: 'Notification de test envoyée immédiatement',
    };

  } catch (error) {
    console.error('❌ Erreur notification de test immédiate:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Fonction pour envoyer une notification au changement de statut
exports.sendCommandeStatusUpdate = functions.firestore
  .document('commandes/{commandeId}')
  .onUpdate(async (change, context) => {
    try {
      const oldData = change.before.data();
      const newData = change.after.data();
      const commandeId = context.params.commandeId;

      // Vérifier si le statut a changé
      if (oldData.statut === newData.statut) {
        return null;
      }

      console.log(`📦 Statut changé pour ${commandeId}: ${oldData.statut} -> ${newData.statut}`);

      // ✅ OPTIMISATION: Messages selon le statut avec emojis
      const statusMessages = {
        'preparee': {
          title: '👨‍🍳 Commande en préparation',
          body: 'Votre commande est en cours de préparation !',
        },
        'pret': {
          title: '✅ Commande prête',
          body: 'Votre commande est prête à être récupérée !',
        },
        'livree': {
          title: '✅ Commande livrée',
          body: 'Votre commande est prête !',
        },
        'annulee': {
          title: '❌ Commande annulée',
          body: 'Votre commande a été annulée',
        },
        'rupture': {
          title: '⚠️ Rupture de stock',
          body: 'Désolé, ce plat n\'est plus disponible',
        },
      };

      const statusInfo = statusMessages[newData.statut];
      if (!statusInfo) {
        console.log('⚠️ Statut inconnu:', newData.statut);
        return null;
      }

      // ✅ ENVOI DIRECT AU TOPIC (pas besoin de chercher les tokens de l'étudiant)
      const message = {
        notification: {
          title: statusInfo.title,
          body: statusInfo.body,
        },
        data: {
          commandeId: commandeId,
          ancienStatut: oldData.statut,
          nouveauStatut: newData.statut,
          type: 'mise_a_jour_statut',
          timestamp: new Date().toISOString(),
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'high_importance_channel',
            sound: 'default',
            priority: 'high',
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
          },
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
        topic: 'nouvelles_commandes', // ✅ ENVOI DIRECT AU TOPIC = TEMPS RÉEL
      };

      const response = await admin.messaging().send(message);
      console.log(`✅ Notification de statut envoyée en temps réel. Message ID: ${response}`);

      return { success: true, messageId: response };

    } catch (error) {
      console.error('❌ Erreur lors de l\'envoi de la notification de statut:', error);
      return { success: false, error: error.message };
    }
  });

// Fonction pour nettoyer les anciens tokens (à exécuter régulièrement)
exports.cleanupInvalidTokens = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    try {
      console.log('🧹 Nettoyage des tokens invalides...');

      // ✅ Vérifier les tokens des gérants
      const gerantsSnapshot = await admin.firestore()
        .collection('gerants')
        .where('fcmToken', '!=', null)
        .get();

      let gerantsRemoved = 0;

      for (const doc of gerantsSnapshot.docs) {
        const token = doc.data().fcmToken;
        
        // Tester le token avec dryRun
        try {
          await admin.messaging().send({
            token: token,
            data: { test: 'true' },
          }, true);
        } catch (error) {
          // Token invalide, le supprimer
          await doc.ref.update({
            fcmToken: admin.firestore.FieldValue.delete(),
          });
          gerantsRemoved++;
          console.log(`❌ Token gérant supprimé: ${token.substring(0, 20)}...`);
        }
      }

      // ✅ Vérifier les tokens des étudiants
      const etudiantsSnapshot = await admin.firestore()
        .collection('etudiants')
        .where('fcmToken', '!=', null)
        .get();

      let etudiantsRemoved = 0;

      for (const doc of etudiantsSnapshot.docs) {
        const token = doc.data().fcmToken;
        
        // Tester le token avec dryRun
        try {
          await admin.messaging().send({
            token: token,
            data: { test: 'true' },
          }, true);
        } catch (error) {
          // Token invalide, le supprimer
          await doc.ref.update({
            fcmToken: admin.firestore.FieldValue.delete(),
          });
          etudiantsRemoved++;
          console.log(`❌ Token étudiant supprimé: ${token.substring(0, 20)}...`);
        }
      }

      console.log(`✅ ${gerantsRemoved} token(s) gérant et ${etudiantsRemoved} token(s) étudiant supprimé(s)`);
      return null;
    } catch (error) {
      console.error('❌ Erreur lors du nettoyage des tokens:', error);
      return null;
    }
  });

// ✅ NOUVEAU: Notification de nouveaux produits disponibles
exports.notifyNewProductsAvailable = functions.https.onCall(async (data, context) => {
  try {
    console.log('📢 Notification nouveaux produits demandée');

    // Récupérer les produits du jour (optionnel)
    const productsCount = data.productsCount || 'plusieurs';
    
    const message = {
      notification: {
        title: '🍽️ Nouveaux plats du jour !',
        body: `Découvrez ${productsCount} nouveau(x) délicieux plat(s) fraîchement préparé(s) pour vous`,
      },
      data: {
        type: 'nouveaux_produits',
        productsCount: productsCount.toString(),
        timestamp: new Date().toISOString(),
        action: 'open_menu',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          sound: 'default',
          priority: 'high',
          color: '#FF6B35', // Couleur orange pour les promos
          lightColor: '#FF6B35',
          defaultVibrateTimings: true,
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            'mutable-content': 1,
            category: 'NEW_PRODUCTS',
          },
        },
      },
      topic: 'nouvelles_commandes', // ✅ Envoyer à tous les abonnés
    };

    const response = await admin.messaging().send(message);
    console.log(`✅ Notification nouveaux produits envoyée. Message ID: ${response}`);

    return {
      success: true,
      messageId: response,
      message: 'Notification de nouveaux produits envoyée à tous les utilisateurs',
    };

  } catch (error) {
    console.error('❌ Erreur notification nouveaux produits:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// ✅ NOUVEAU: Notification promotion/offre spéciale
exports.notifySpecialOffer = functions.https.onCall(async (data, context) => {
  try {
    console.log('🎁 Notification offre spéciale demandée');

    const offerTitle = data.offerTitle || '🎁 Offre spéciale du jour';
    const offerDescription = data.offerDescription || 'Une belle surprise vous attend !';
    const discount = data.discount || '';

    const discountText = discount ? ` - ${discount}% de réduction` : '';

    const message = {
      notification: {
        title: offerTitle,
        body: `${offerDescription}${discountText}`,
      },
      data: {
        type: 'offre_speciale',
        offerTitle: offerTitle,
        discount: discount,
        timestamp: new Date().toISOString(),
        action: 'open_offers',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          sound: 'default',
          priority: 'high',
          color: '#FF1744', // Couleur rouge pour les offres
          lightColor: '#FF1744',
          defaultVibrateTimings: true,
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
            badge: 2,
            'mutable-content': 1,
            category: 'SPECIAL_OFFER',
          },
        },
      },
      topic: 'nouvelles_commandes',
    };

    const response = await admin.messaging().send(message);
    console.log(`✅ Notification offre spéciale envoyée. Message ID: ${response}`);

    return {
      success: true,
      messageId: response,
      message: 'Notification offre spéciale envoyée à tous les utilisateurs',
    };

  } catch (error) {
    console.error('❌ Erreur notification offre spéciale:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// ✅ NOUVEAU: Notification générale/annonce
exports.broadcastAnnouncement = functions.https.onCall(async (data, context) => {
  try {
    console.log('📣 Annonce générale demandée');

    const title = data.title || '📢 Annonce importante';
    const message_text = data.message || 'Consultez l\'annonce pour plus de détails';

    const message = {
      notification: {
        title: title,
        body: message_text,
      },
      data: {
        type: 'annonce',
        title: title,
        timestamp: new Date().toISOString(),
        action: 'open_announcements',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          sound: 'default',
          priority: 'high',
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      topic: 'nouvelles_commandes',
    };

    const response = await admin.messaging().send(message);
    console.log(`✅ Annonce générale envoyée. Message ID: ${response}`);

    return {
      success: true,
      messageId: response,
      message: 'Annonce envoyée à tous les utilisateurs',
    };

  } catch (error) {
    console.error('❌ Erreur annonce générale:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});