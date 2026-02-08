# 🔍 Guide de dépannage - Notifications FCM

## ✅ Étape 1 : Vérifier les diagnostics

1. **Lancez l'app** : `flutter run`
2. **Allez à** : `/fcm-diagnostics`
3. **Vérifiez** :
   - ✓ Token FCM trouvé
   - ✓ Permissions accordées
   - ✓ Topics abonnés
   - ✓ Listeners actifs

## 🔧 Si le token est `null`

```bash
# Arrêtez l'app
# Exécutez :
flutter clean
flutter pub get
flutter run
```

## 🚨 Si les permissions sont refusées

### Android :
1. **Paramètres** → **Applications** → **Projet Flutter**
2. **Permissions** → **Notifications** → **Autoriser**
3. Redémarrez l'app

### iOS :
1. **Paramètres** → **Notifications** → **Projet Flutter**
2. **Autoriser les notifications** → Activé

## 🔔 Si les notifications n'arrivent pas

### Checklist :

- [ ] Token FCM ≠ null
- [ ] Permissions = Authorized
- [ ] App abonnée au topic `nouvelles_commandes`
- [ ] Volume téléphone ≠ muet
- [ ] App pas tuée en arrière-plan
- [ ] Pas de mode Doze activé (Android)

### Solutions :

**1. Tester notification locale :**
```dart
await FCMService().testLocalNotification();
```

**2. Tester depuis Firebase Console :**
- Cloud Messaging → Envoyer le premier message
- Topic : `nouvelles_commandes`
- Cliquez : Envoyer

**3. Vérifier les logs Android :**
```bash
flutter logs
# Recherchez : "FCM", "notification", "error"
```

**4. Vérifier Logcat :**
```bash
adb logcat | grep -i "firebase\|messaging\|fcm"
```

## 📊 Vérifications de diagnostic

### Token FCM
```
✅ Token trouvé: cVMivOYJQ9aR9bP2qW9Gsv:APA91bGylWp...
```

### Permissions
```
Statut d'autorisation: AuthorizationStatus.authorized
Alert: true
Sound: true
Badge: true
```

### Topics
```
✅ Topic abonné: nouvelles_commandes
```

### Messages
```
🔴 Message au premier plan: LISTENER ACTIF
🔴 Message en arrière-plan: LISTENER ACTIF
```

## 🐛 Logs à chercher

### En cas de succès :
```
✅ Permissions FCM accordées
✅ Notifications locales initialisées
✅ Abonné au topic: nouvelles_commandes
🔑 Token FCM: cVMivOYJQ9aR9bP2qW9Gsv:APA91bGylWp...
```

### En cas d'erreur :
```
❌ Erreur abonnement topic: ...
❌ Erreur init notifications locales: ...
❌ Erreur affichage notification: ...
```

## 🎯 Procédure complète de test

1. **Ouvrir l'app**
2. **Aller à `/fcm-diagnostics`**
3. **Vérifier tous les points** ✓
4. **Si tout OK** → Aller à `/test-notifications`
5. **Cliquer** : "Test: Nouvelle commande"
6. **Chercher la notification** 📲

## 📝 Fichiers clés

- `lib/services/fcm_service.dart` - Service FCM
- `lib/views/debug/fcm_diagnostics_page.dart` - Page diagnostic
- `lib/views/debug/notification_test_page.dart` - Page test
- `functions/test-notifications.js` - Script test Node

## 🆘 Besoin d'aide ?

Si ça ne marche toujours pas :
1. Ouvrez Logcat : `flutter logs`
2. Cherchez les erreurs FCM
3. Vérifiez les permissions Android
4. Testez depuis Firebase Console directement
