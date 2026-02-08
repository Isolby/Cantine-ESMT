import 'package:flutter/material.dart';
import '../../services/notification_broadcast_service.dart';

class TestBroadcastPage extends StatefulWidget {
  const TestBroadcastPage({Key? key}) : super(key: key);

  @override
  State<TestBroadcastPage> createState() => _TestBroadcastPageState();
}

class _TestBroadcastPageState extends State<TestBroadcastPage> {
  String _log = '';
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _log = '$message\n$_log';
    });
  }

  Future<void> _sendTestNotificationNow() async {
    setState(() => _isLoading = true);
    try {
      final result = await NotificationBroadcastService.sendTestNotificationNow();
      _addLog('✅ Notification test immédiate: ${result['message']}');
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendNewProducts() async {
    setState(() => _isLoading = true);
    try {
      final result = await NotificationBroadcastService.notifyNewProductsAvailable(
        productsCount: '3',
      );
      _addLog('✅ Nouveaux produits annoncés: ${result['message']}');
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendSpecialOffer() async {
    setState(() => _isLoading = true);
    try {
      final result = await NotificationBroadcastService.notifySpecialOffer(
        offerTitle: '🎁 Offre spéciale - Diner gratuit !',
        offerDescription: 'Commandez maintenant et obtenez',
        discount: '50',
      );
      _addLog('✅ Offre spéciale envoyée: ${result['message']}');
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendAnnouncement() async {
    setState(() => _isLoading = true);
    try {
      final result = await NotificationBroadcastService.broadcastAnnouncement(
        title: '📢 Service de cantine disponible',
        message: 'La cantine est maintenant ouverte pour les commandes du jour',
      );
      _addLog('✅ Annonce envoyée: ${result['message']}');
    } catch (e) {
      _addLog('❌ Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearLog() {
    setState(() => _log = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Test Notifications Broadcast'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Boutons de test
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Test immédiat
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendTestNotificationNow,
                    icon: const Icon(Icons.send),
                    label: const Text('🚀 Test Immédiat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nouveaux produits
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendNewProducts,
                    icon: const Icon(Icons.restaurant),
                    label: const Text('🍽️ Nouveaux Produits'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Offre spéciale
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendSpecialOffer,
                    icon: const Icon(Icons.local_offer),
                    label: const Text('🎁 Offre Spéciale'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Annonce
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendAnnouncement,
                    icon: const Icon(Icons.announcement),
                    label: const Text('📣 Annonce Générale'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Effacer les logs
                  OutlinedButton.icon(
                    onPressed: _clearLog,
                    icon: const Icon(Icons.clear),
                    label: const Text('Effacer les logs'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Log
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Logs',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Text(
                        _log.isEmpty ? 'En attente...' : _log,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loader
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
