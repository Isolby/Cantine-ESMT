import 'package:flutter/material.dart';
import '../../utils/notification_test_helper.dart';
import '../../services/fcm_service.dart';
import '../../constants/app_colors.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({Key? key}) : super(key: key);

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  bool _isLoading = false;
  String _testLog = '';

  void _addLog(String message) {
    setState(() {
      _testLog = '${DateTime.now().toIso8601String()}: $message\n' + _testLog;
    });
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Test Notifications'),
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Infos FCM
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📱 Infos FCM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Token: ${FCMService().currentToken?.substring(0, 50) ?? "Chargement..."}...',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          final token = FCMService().currentToken;
                          if (token != null) {
                            _addLog('✅ Token: $token');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Token affiché dans les logs!'),
                              ),
                            );
                          }
                        },
                        child: const Text('Afficher le token complet'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Boutons de test
              const Text(
                '🧪 Tests de notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTestButton(
                'Test: Nouvelle commande',
                '🍽️',
                () async {
                  _addLog('Envoi notification: Nouvelle commande...');
                  try {
                    await NotificationTestHelper
                        .testNotificationNouvelleCommande();
                    _addLog('✅ Notification nouvelle commande envoyée!');
                  } catch (e) {
                    _addLog('❌ Erreur: $e');
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildTestButton(
                'Test: Statut Prête',
                '✅',
                () async {
                  _addLog('Envoi notification: Statut Prête...');
                  try {
                    await NotificationTestHelper.testNotificationStatut('pret');
                    _addLog('✅ Notification statut prête envoyée!');
                  } catch (e) {
                    _addLog('❌ Erreur: $e');
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildTestButton(
                'Test: Statut Rupture',
                '❌',
                () async {
                  _addLog('Envoi notification: Statut Rupture...');
                  try {
                    await NotificationTestHelper
                        .testNotificationStatut('rupture');
                    _addLog('✅ Notification statut rupture envoyée!');
                  } catch (e) {
                    _addLog('❌ Erreur: $e');
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildTestButton(
                'Test: Lancer tous les tests',
                '🚀',
                () async {
                  setState(() => _isLoading = true);
                  _addLog('Lancement de tous les tests...');
                  try {
                    await NotificationTestHelper.runAllTests();
                    _addLog('✅ Tous les tests sont terminés!');
                  } catch (e) {
                    _addLog('❌ Erreur: $e');
                  }
                  setState(() => _isLoading = false);
                },
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              // Log
              const Text(
                '📋 Logs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 250,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testLog.isEmpty
                        ? 'Les logs s\'afficheront ici...'
                        : _testLog,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _testLog = '');
                  _addLog('📝 Logs effacés');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Effacer les logs'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    String emoji,
    VoidCallback onPressed, {
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(label),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
