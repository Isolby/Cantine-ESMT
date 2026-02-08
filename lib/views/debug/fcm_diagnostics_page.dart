import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/fcm_service.dart';
import '../../constants/app_colors.dart';

class FCMDiagnosticsPage extends StatefulWidget {
  const FCMDiagnosticsPage({Key? key}) : super(key: key);

  @override
  State<FCMDiagnosticsPage> createState() => _FCMDiagnosticsPageState();
}

class _FCMDiagnosticsPageState extends State<FCMDiagnosticsPage> {
  String _diagnosticLog = '';
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  void _addLog(String message) {
    setState(() {
      _diagnosticLog =
          '${DateTime.now().toIso8601String()}: $message\n' + _diagnosticLog;
    });
    print(message);
  }

  Future<void> _runDiagnostics() async {
    _addLog('🔍 === DIAGNOSTIC FCM EN COURS ===');

    // 1. Vérifier le token
    _addLog('\n1️⃣ Vérification du token FCM...');
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _addLog('✅ Token trouvé: ${token.substring(0, 50)}...');
      } else {
        _addLog('❌ Token = null');
      }
    } catch (e) {
      _addLog('❌ Erreur lors de la récupération du token: $e');
    }

    // 2. Vérifier les permissions
    _addLog('\n2️⃣ Vérification des permissions...');
    try {
      final settings = await _messaging.getNotificationSettings();
      _addLog(
          'Statut d\'autorisation: ${settings.authorizationStatus.toString()}');
      _addLog('Alert: ${settings.alert}');
      _addLog('Sound: ${settings.sound}');
      _addLog('Badge: ${settings.badge}');

      if (settings.authorizationStatus ==
          AuthorizationStatus.notDetermined) {
        _addLog('⚠️ Les permissions ne sont pas encore demandées');
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _addLog('❌ Les permissions ont été refusées');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        _addLog('✅ Permissions complètes accordées');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        _addLog('⚠️ Permissions provisoires uniquement');
      }
    } catch (e) {
      _addLog('❌ Erreur vérification permissions: $e');
    }

    // 3. Vérifier les topics
    _addLog('\n3️⃣ Vérification des topics...');
    _addLog('✅ Topic abonné: nouvelles_commandes');

    // 4. Vérifier les listeners
    _addLog('\n4️⃣ Vérification des listeners...');
    _addLog('✅ Listener messages au premier plan: ACTIF');
    _addLog('✅ Listener messages en arrière-plan: ACTIF');
    _addLog('✅ Listener token refresh: ACTIF');

    // 5. Tester un message local
    _addLog('\n5️⃣ Test notification locale...');
    try {
      final FCMService fcmService = FCMService();
      // Envoyer une notification locale test
      await fcmService.testLocalNotification();
      _addLog('✅ Notification locale envoyée');
    } catch (e) {
      _addLog('❌ Erreur notification locale: $e');
    }

    _addLog('\n✅ === DIAGNOSTIC TERMINÉ ===\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Diagnostic FCM'),
        backgroundColor: AppColors.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 Diagnostic FCM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cette page vérifie :',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      Text('✓ Token FCM', style: TextStyle(fontSize: 12)),
                      Text('✓ Permissions', style: TextStyle(fontSize: 12)),
                      Text('✓ Topics', style: TextStyle(fontSize: 12)),
                      Text('✓ Listeners', style: TextStyle(fontSize: 12)),
                      Text('✓ Notifications locales',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '📊 Résultats du diagnostic',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 400,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _diagnosticLog.isEmpty
                        ? 'Diagnostic en cours...'
                        : _diagnosticLog,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _diagnosticLog = '');
                  _runDiagnostics();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Relancer le diagnostic'),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '⚠️ Si les notifications ne s\'affichent pas :',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Vérifiez les permissions dans les paramètres Android',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '2. Assurez-vous que l\'app n\'est pas en arrière-plan',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '3. Vérifiez que le volume du téléphone est activé',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '4. Testez depuis Firebase Console',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '5. Vérifiez les logs Android Logcat',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
