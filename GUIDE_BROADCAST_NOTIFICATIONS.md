# 📢 Guide Système de Notifications Broadcast

## 📋 Vue d'ensemble

Le système de notifications broadcast permet d'envoyer des notifications à **TOUS les utilisateurs** (gérants et étudiants) à travers Firebase Cloud Messaging.

## 🏗️ Architecture

```
Flutter App
    ↓
NotificationBroadcastService (wrapper)
    ↓
Cloud Functions (Firebase)
    ↓
Firebase Cloud Messaging (FCM)
    ↓
Topic: 'nouvelles_commandes'
    ↓
Tous les appareils abonnés
```

## 🎯 Types de Notifications

### 1. **Test Immédiat** 🚀
- **Fonction**: `sendTestNotificationNow`
- **Couleur**: Orange (#FF9800)
- **Cas d'usage**: Tester rapidement si les notifications arrivent
- **Exemple**: Clic sur "Test Immédiat" dans l'app

### 2. **Nouveaux Produits** 🍽️
- **Fonction**: `notifyNewProductsAvailable`
- **Couleur**: Vert (#FF6B35)
- **Cas d'usage**: Informer les étudiants de nouveaux plats disponibles
- **Exemple**: 
  ```dart
  await NotificationBroadcastService.notifyNewProductsAvailable(
    productsCount: '5',
  );
  ```

### 3. **Offre Spéciale** 🎁
- **Fonction**: `notifySpecialOffer`
- **Couleur**: Rouge (#FF1744)
- **Cas d'usage**: Promouvoir une réduction ou une offre limitée
- **Exemple**:
  ```dart
  await NotificationBroadcastService.notifySpecialOffer(
    offerTitle: '🎁 Offre du jour',
    offerDescription: 'Moins cher le midi',
    discount: '30',
  );
  ```

### 4. **Annonce Générale** 📣
- **Fonction**: `broadcastAnnouncement`
- **Couleur**: Bleu
- **Cas d'usage**: Communiqués importants
- **Exemple**:
  ```dart
  await NotificationBroadcastService.broadcastAnnouncement(
    title: '⚠️ Cantine ferme à 14h',
    message: 'Lundi 10 février',
  );
  ```

### 5. **Notifications Programmées** ⏰
- **Fonction**: `sendTestNotificationEveryMinute`
- **Type**: Pubsub schedule (chaque minute)
- **Contrôle**: Variable `ENABLE_TEST_NOTIFICATIONS` dans index.js

## 📱 Accès depuis l'App

### Page de Test
**Route**: `/test-broadcast`

C'est une page complète pour tester tous les types de notifications:
- Boutons d'envoi rapide
- Affichage des logs en temps réel
- Statut de chargement

### Intégration dans GerantViewModel

Pour intégrer dans la page gérant:

```dart
final broadcastVM = Provider.of<NotificationBroadcastViewModel>(context);

ElevatedButton(
  onPressed: () => broadcastVM.announceNewProducts('3'),
  child: const Text('Annoncer 3 nouveaux plats'),
)
```

## ⚙️ Configuration

### Variables de Contrôle (index.js)

```javascript
// Activer/désactiver les notifications de test chaque minute
const ENABLE_TEST_NOTIFICATIONS = true; // Changer à false pour arrêter
```

Pour désactiver les tests programmés:
1. Ouvrir `functions/index.js`
2. Changer `ENABLE_TEST_NOTIFICATIONS = false`
3. Redéployer: `firebase deploy --only "functions"`

## 🚀 Déploiement

Toutes les fonctions sont déjà déployées ✅

Pour redéployer après modification:
```bash
cd c:\Users\ISSA\Desktop\coursflutter\projet_flutter
firebase deploy --only "functions"
```

## 📊 Logs et Monitoring

Voir les logs des Cloud Functions:
```bash
firebase functions:log
```

## ✅ Vérification du Statut

Lister toutes les fonctions:
```bash
firebase functions:list
```

## 🧪 Test Rapide

1. Naviguer vers `/test-broadcast`
2. Cliquer sur "🚀 Test Immédiat"
3. Vérifier sur votre téléphone si la notification arrive

## 🔧 Dépannage

### Les notifications n'arrivent pas?

1. Vérifier que vous avez démarré le mode debug sur le téléphone
2. Confirmer que l'app est abonnée au topic `nouvelles_commandes`:
   - Aller à `/fcm-diagnostics`
   - Chercher "Topics subscribed"
3. Vérifier les logs: `firebase functions:log`

### L'envoi échoue avec une erreur?

- Si "Notifications de test désactivées": Activer `ENABLE_TEST_NOTIFICATIONS = true` dans index.js
- Si "Authentication required": Vérifier que Firebase est initialisé correctement

## 📚 Fichiers Clés

- `functions/index.js` - Cloud Functions
- `lib/services/notification_broadcast_service.dart` - Service wrapper
- `lib/viewsmodels/notification_broadcast_viewmodel.dart` - ViewModel
- `lib/views/debug/test_broadcast_page.dart` - Page de test
- `lib/main.dart` - Routes et initialisation

## 🎯 Cas d'Usage Réels

### Matin - Annoncer le menu du jour
```dart
await broadcastVM.announceNewProducts('5 plats');
```

### Midi - Promotion
```dart
await broadcastVM.sendSpecialOffer(
  title: '🎁 Menu étudiant 1500 FCFA',
  description: 'Limité à 50 portions',
  discount: '25',
);
```

### Fermeture/Info importante
```dart
await broadcastVM.broadcastAnnouncement(
  title: '📢 Rupture de stock',
  message: 'Le riz blanc n\'est plus disponible',
);
```

---

**Version**: 2.0 (Optimisée pour temps réel)  
**Dernière mise à jour**: Février 2026  
**Statut**: ✅ Production
