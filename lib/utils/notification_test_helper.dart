import 'package:cloud_functions/cloud_functions.dart';

class NotificationTestHelper {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Envoyer une notification de test pour une nouvelle commande
  static Future<void> testNotificationNouvelleCommande() async {
    try {
      print('🧪 Test: Envoi d\'une notification de nouvelle commande...');

      final result = await _functions
          .httpsCallable('envoyerNotificationCommande')
          .call({
        'commandeId': 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        'total': 5000.0,
        'etat': 'enAttente',
      });

      print('✅ Notification envoyée avec succès!');
      print('📊 Réponse: ${result.data}');
    } catch (e) {
      print('❌ Erreur test notification: $e');
      rethrow;
    }
  }

  /// Envoyer une notification de test pour une mise à jour de statut
  static Future<void> testNotificationStatut(String newStatus) async {
    try {
      print('🧪 Test: Envoi d\'une notification de statut ($newStatus)...');

      final result = await _functions
          .httpsCallable('envoyerNotificationStatut')
          .call({
        'commandeId': 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        'nouveauStatut': newStatus,
      });

      print('✅ Notification de statut envoyée!');
      print('📊 Réponse: ${result.data}');
    } catch (e) {
      print('❌ Erreur test notification: $e');
      rethrow;
    }
  }

  /// Envoyer une notification à un utilisateur spécifique
  static Future<void> testNotificationUtilisateur(String token) async {
    try {
      print('🧪 Test: Envoi d\'une notification utilisateur...');

      final result = await _functions
          .httpsCallable('envoyerNotificationUtilisateur')
          .call({
        'token': token,
        'titre': '🧪 Test Notification',
        'message': 'Ceci est une notification de test',
        'type': 'test',
      });

      print('✅ Notification utilisateur envoyée!');
      print('📊 Réponse: ${result.data}');
    } catch (e) {
      print('❌ Erreur test notification: $e');
      rethrow;
    }
  }

  /// Tester tous les types de notifications
  static Future<void> runAllTests() async {
    print('\n🚀 === LANCEMENT DE TOUS LES TESTS ===\n');

    // Test 1: Nouvelle commande
    await testNotificationNouvelleCommande();
    await Future.delayed(Duration(seconds: 2));

    // Test 2: Mise à jour statut - Prête
    await testNotificationStatut('pret');
    await Future.delayed(Duration(seconds: 2));

    // Test 3: Mise à jour statut - Rupture
    await testNotificationStatut('rupture');

    print('\n✅ === TOUS LES TESTS SONT TERMINÉS ===\n');
  }
}
