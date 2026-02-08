import 'package:cloud_functions/cloud_functions.dart';

class NotificationBroadcastService {
  static final _functions = FirebaseFunctions.instance;

  /// Envoyer une notification de test immédiatement
  static Future<Map<String, dynamic>> sendTestNotificationNow() async {
    try {
      final result = await _functions.httpsCallable('sendTestNotificationNow').call();
      return result.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Annoncer de nouveaux produits disponibles
  static Future<Map<String, dynamic>> notifyNewProductsAvailable({
    String productsCount = 'plusieurs',
  }) async {
    try {
      final result = await _functions
          .httpsCallable('notifyNewProductsAvailable')
          .call({'productsCount': productsCount});
      return result.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Envoyer une offre spéciale
  static Future<Map<String, dynamic>> notifySpecialOffer({
    required String offerTitle,
    required String offerDescription,
    String discount = '',
  }) async {
    try {
      final result = await _functions.httpsCallable('notifySpecialOffer').call({
        'offerTitle': offerTitle,
        'offerDescription': offerDescription,
        'discount': discount,
      });
      return result.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Envoyer une annonce générale
  static Future<Map<String, dynamic>> broadcastAnnouncement({
    required String title,
    required String message,
  }) async {
    try {
      final result = await _functions.httpsCallable('broadcastAnnouncement').call({
        'title': title,
        'message': message,
      });
      return result.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
