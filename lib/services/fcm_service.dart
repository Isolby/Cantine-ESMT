import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:io';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _currentToken;

  factory FCMService() {
    return _instance;
  }

  FCMService._internal();

  // Getter pour le token
  String? get currentToken => _currentToken;

  Future<void> initialize() async {
    print('🔄 Initialisation FCM...');
    
    try {
      // Demander les permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permissions FCM accordées');
      } else {
        print('⚠️ Permissions FCM limitées');
      }

      // Initialiser les notifications locales
      await _initLocalNotifications();

      // S'abonner aux topics
      await _firebaseMessaging.subscribeToTopic('nouvelles_commandes');
      print('✅ Abonné au topic: nouvelles_commandes');

      // Gérer les messages au premier plan
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Gérer les messages en arrière-plan (app ouverte via notification)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Obtenir et stocker le token FCM
      _currentToken = await _firebaseMessaging.getToken();
      print('🔑 Token FCM: $_currentToken');

      // Écouter les changements de token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        print('🔄 Token FCM mis à jour: $newToken');
      });
    } catch (e) {
      print('❌ Erreur initialisation FCM: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('📲 Notification cliquée: ${response.payload}');
        },
      );

      // Créer un canal de notification Android
      if (Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel',
          'Notifications importantes',
          description: 'Notifications FCM haute priorité',
          importance: Importance.max,
          playSound: true,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }

      print('✅ Notifications locales initialisées');
    } catch (e) {
      print('❌ Erreur init notifications locales: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Message au premier plan: ${message.notification?.title}');
    _showLocalNotification(message);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('📨 Message reçu (app en arrière-plan): ${message.notification?.title}');
    // Naviguer vers la page appropriée si nécessaire
    if (message.data.containsKey('commandeId')) {
      print('🎯 Commande: ${message.data['commandeId']}');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) return;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'high_importance_channel',
        'Notifications importantes',
        channelDescription: 'Notifications FCM',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Cantine App',
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: message.data.toString(),
      );

      print('✅ Notification locale affichée');
    } catch (e) {
      print('❌ Erreur affichage notification: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Abonné au topic: $topic');
    } catch (e) {
      print('❌ Erreur abonnement topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Désabonné du topic: $topic');
    } catch (e) {
      print('❌ Erreur désabonnement topic: $e');
    }
  }

  Future<void> testLocalNotification() async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'high_importance_channel',
        'Notifications importantes',
        channelDescription: 'Test notification',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Test',
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        9999,
        '🧪 Test Notification',
        'Ceci est une notification de test locale',
        notificationDetails,
      );

      print('✅ Notification de test envoyée');
    } catch (e) {
      print('❌ Erreur notification test: $e');
    }
  }
}
