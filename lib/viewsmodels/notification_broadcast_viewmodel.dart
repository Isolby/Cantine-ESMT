import 'package:flutter/material.dart';
import '../services/notification_broadcast_service.dart';

class NotificationBroadcastViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _lastMessage = '';

  bool get isLoading => _isLoading;
  String get lastMessage => _lastMessage;

  /// Envoyer une notification de test
  Future<bool> sendTestNotification() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await NotificationBroadcastService.sendTestNotificationNow();
      _lastMessage = result['message'] ?? 'Test envoyé';
      notifyListeners();
      return true;
    } catch (e) {
      _lastMessage = 'Erreur: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Annoncer de nouveaux produits
  Future<bool> announceNewProducts(String count) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await NotificationBroadcastService.notifyNewProductsAvailable(
        productsCount: count,
      );
      _lastMessage = result['message'] ?? 'Nouveaux produits annoncés';
      notifyListeners();
      return true;
    } catch (e) {
      _lastMessage = 'Erreur: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envoyer une offre spéciale
  Future<bool> sendSpecialOffer({
    required String title,
    required String description,
    required String discount,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await NotificationBroadcastService.notifySpecialOffer(
        offerTitle: title,
        offerDescription: description,
        discount: discount,
      );
      _lastMessage = result['message'] ?? 'Offre envoyée';
      notifyListeners();
      return true;
    } catch (e) {
      _lastMessage = 'Erreur: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envoyer une annonce générale
  Future<bool> broadcastAnnouncement({
    required String title,
    required String message,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await NotificationBroadcastService.broadcastAnnouncement(
        title: title,
        message: message,
      );
      _lastMessage = result['message'] ?? 'Annonce envoyée';
      notifyListeners();
      return true;
    } catch (e) {
      _lastMessage = 'Erreur: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
