# 🔍 Diagnostic: Erreur lors de la commande

## Problème Identifié
Lors du passage d'une commande, l'utilisateur reçoit le message: **"Erreur lors de la commande"**

## Améliorations Appliquées

### 1. ✅ Messages d'Erreur Améliorés
- Ajout de logs détaillés dans `etudiant_viewmodel.dart`
- Affichage d'erreurs spécifiques (Permissions, Réseau, Collection manquante)
- Validation des données avant envoi

### 2. ✅ Affichage d'Erreur à l'Utilisateur  
- Ajout d'un SnackBar rouge en cas d'erreur dans `etudiant_page.dart`
- Le message d'erreur détaillé s'affiche maintenant

---

## 🔧 Causes Potentielles

### A. Permissions Firestore
**Symptôme**: "Permission denied" ou erreur 403
**Cause**: Règles de sécurité Firestore configurées strictement
**Solution**:
```
// firebase.json ou console Firebase
{
  "rules": {
    "commandes": {
      ".write": true,  // Ou vérifier l'authentification
      ".read": true
    }
  }
}
```

### B. Collection 'commandes' Inexistante
**Symptôme**: "Collection not found"
**Cause**: La collection n'a jamais été créée
**Solution**: Créer manuellement la collection dans l'export Firestore

### C. Données Malformées
**Symptôme**: "Invalid data"
**Cause**: Les plats du panier manquent de champs
**Solution**: Véri tous les champs requis

### D. Authentification Requise
**Symptôme**: "Authentication required"
**Cause**: Firebase nécessite une authentification
**Solution**: Implémenter Firebase Auth

### E. Problème de Connectivité
**Symptôme**: "Network error"
**Cause**: Pas de connexion internet
**Solution**: Vérifier la connexion

---

## 📋 Prochaines Étapes

### 1. Vérifier les Logs Console
Lancez l'app et regardez la console Flutter:
```
- En cas d'erreur d'autorisation → Corriger les règles Firestore
- En cas d'erreur réseau → Vérifier la connexion
- En cas d'erreur de données → Corriger les validations
```

### 2. Vérifier Firestore Rules (Console Firebase)
1. Aller à: Firestore Database → Rules
2. Vérifier la règle pour "commandes"
3. S'assurer que write: true est autorisé

### 3. Créer la Collection Manuellement
1. Aller à: Firestore Database → Collections
2. Créer une collection nommée "commandes"
3. Ajouter un document de test

### 4. Tester Manuellement
Dans Firebase console, créer une commande:
```json
{
  "etudiant": "Test",
  "plats": [{"nom": "Test", "prix": 1000}],
  "etat": "En attente",
  "total": 1000,
  "date": "2026-02-10T00:00:00Z"
}
```

---

## 🐛 Fichiers Modifiés
- ✅ `lib/viewsmodels/etudiant_viewmodel.dart` - Messages d'erreur améliorés
- ✅ `lib/views/etudiant/etudiant_page.dart` - Affichage des erreurs

## 📝 À Faire Après
1. Exécuter l'app et tester une commande
2. Vérifier les logs pour le message d'erreur exact
3. Appliquer la solution correspondante
