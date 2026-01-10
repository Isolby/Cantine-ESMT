import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plat_model.dart';
import '../models/commande_model.dart';
import '../services/storage_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  // ============ GESTION DES PLATS ============

  // Récupérer tous les plats
  Stream<List<PlatModel>> getPlats() {
    return _firestore
        .collection('plats')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PlatModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Récupérer les plats disponibles
  Future<List<PlatModel>> getPlatsDisponibles() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('plats')
          .where('disponible', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        return PlatModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('❌ Erreur récupération plats disponibles: $e');
      return [];
    }
  }

  // Ajouter un plat
  Future<void> ajouterPlat(PlatModel plat) async {
    try {
      await _firestore.collection('plats').add(plat.toMap());
      print('✅ Plat ajouté dans Firestore');
    } catch (e) {
      print('❌ Erreur ajout plat Firestore: $e');
      rethrow;
    }
  }

  // Mettre à jour un plat
  Future<void> mettreAJourPlat(PlatModel plat) async {
    try {
      if (plat.id == null) {
        throw Exception('ID du plat manquant');
      }
      await _firestore.collection('plats').doc(plat.id).update(plat.toMap());
      print('✅ Plat mis à jour dans Firestore');
    } catch (e) {
      print('❌ Erreur mise à jour plat Firestore: $e');
      rethrow;
    }
  }

  // Supprimer un plat (avec son image)
  Future<void> supprimerPlat(PlatModel plat) async {
    try {
      // Supprimer l'image si elle existe
      if (plat.imageUrl != null && plat.imageUrl!.isNotEmpty) {
        await _storageService.deletePlatImage(plat.imageUrl!);
      }

      // Supprimer le document Firestore
      if (plat.id != null) {
        await _firestore.collection('plats').doc(plat.id).delete();
      }

      print('✅ Plat supprimé de Firestore');
    } catch (e) {
      print('❌ Erreur suppression plat Firestore: $e');
      rethrow;
    }
  }

  // Récupérer un plat par ID
  Future<PlatModel?> getPlatById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('plats').doc(id).get();
      if (doc.exists) {
        return PlatModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération plat: $e');
      return null;
    }
  }

  // Définir le plat du jour
  Future<void> definirPlatDuJour(String platId) async {
    try {
      // Retirer le statut de tous les autres plats
      QuerySnapshot plats = await _firestore.collection('plats').get();
      for (var doc in plats.docs) {
        await _firestore
            .collection('plats')
            .doc(doc.id)
            .update({'estPlatDuJour': false});
      }

      // Définir le nouveau plat du jour
      await _firestore
          .collection('plats')
          .doc(platId)
          .update({'estPlatDuJour': true});

      print('✅ Plat du jour défini');
    } catch (e) {
      print('❌ Erreur définir plat du jour: $e');
      rethrow;
    }
  }

  // Changer la disponibilité d'un plat
  Future<void> changerDisponibilite(String platId, bool disponible) async {
    try {
      await _firestore
          .collection('plats')
          .doc(platId)
          .update({'disponible': disponible});
      print('✅ Disponibilité du plat mise à jour');
    } catch (e) {
      print('❌ Erreur changement disponibilité: $e');
      rethrow;
    }
  }

  // ============ GESTION DES COMMANDES ============

  // Récupérer toutes les commandes
  Stream<List<CommandeModel>> getCommandes() {
    return _firestore
        .collection('commandes')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommandeModel.fromFirestore(doc);
      }).toList();
    });
  }

  // Ajouter une commande
  Future<void> ajouterCommande(CommandeModel commande) async {
    try {
      await _firestore.collection('commandes').add(commande.toMap());
      print('✅ Commande ajoutée dans Firestore');
    } catch (e) {
      print('❌ Erreur ajout commande Firestore: $e');
      rethrow;
    }
  }

  // Mettre à jour le statut d'une commande
  Future<void> mettreAJourStatutCommande(String commandeId, String statut) async {
    try {
      await _firestore
          .collection('commandes')
          .doc(commandeId)
          .update({'etat': statut});
      print('✅ Statut de la commande mis à jour');
    } catch (e) {
      print('❌ Erreur mise à jour statut commande: $e');
      rethrow;
    }
  }

  // Récupérer une commande par ID
  Future<CommandeModel?> getCommandeById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('commandes').doc(id).get();
      if (doc.exists) {
        return CommandeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération commande: $e');
      return null;
    }
  }

  // ============ GESTION DES ADMINS ============

  // Vérifier si un utilisateur est admin
  Future<bool> isAdmin(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('admins').doc(userId).get();
      
      if (doc.exists) {
        print('✅ Utilisateur $userId est admin');
        return true;
      } else {
        print('⚠️ Utilisateur $userId n\'est PAS admin');
        return false;
      }
    } catch (e) {
      print('❌ Erreur vérification admin: $e');
      return false;
    }
  }

  // Ajouter un admin (pour créer des comptes admin)
  Future<void> ajouterAdmin(String userId, Map<String, dynamic> adminData) async {
    try {
      await _firestore.collection('admins').doc(userId).set({
        'email': adminData['email'],
        'nom': adminData['nom'] ?? '',
        'role': 'admin',
        'dateCreation': FieldValue.serverTimestamp(),
      });
      print('✅ Admin ajouté avec succès');
    } catch (e) {
      print('❌ Erreur ajout admin: $e');
      rethrow;
    }
  }

  // Supprimer un admin
  Future<void> supprimerAdmin(String userId) async {
    try {
      await _firestore.collection('admins').doc(userId).delete();
      print('✅ Admin supprimé avec succès');
    } catch (e) {
      print('❌ Erreur suppression admin: $e');
      rethrow;
    }
  }
}