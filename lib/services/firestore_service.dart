import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plat_model.dart';
import '../models/commande_model.dart';
import '../models/admin_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ PLATS ============
  
  // Obtenir tous les plats (Stream)
  Stream<List<PlatModel>> getPlatsStream() {
    return _db
        .collection('plats')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PlatModel.fromFirestore(doc))
            .toList());
  }

  // Obtenir tous les plats (Future)
  Future<List<PlatModel>> getPlats() async {
    try {
      QuerySnapshot snapshot = await _db.collection('plats').get();
      return snapshot.docs
          .map((doc) => PlatModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Erreur lors de la récupération des plats: $e';
    }
  }

  // Ajouter un plat
  Future<void> addPlat(PlatModel plat) async {
    try {
      await _db.collection('plats').add(plat.toMap());
    } catch (e) {
      throw 'Erreur lors de l\'ajout du plat: $e';
    }
  }

  // Mettre à jour un plat
  Future<void> updatePlat(PlatModel plat) async {
    try {
      await _db.collection('plats').doc(plat.id).update(plat.toMap());
    } catch (e) {
      throw 'Erreur lors de la mise à jour du plat: $e';
    }
  }

  // Supprimer un plat
  Future<void> deletePlat(String platId) async {
    try {
      await _db.collection('plats').doc(platId).delete();
    } catch (e) {
      throw 'Erreur lors de la suppression du plat: $e';
    }
  }

  // ============ COMMANDES ============
  
  // Obtenir toutes les commandes (Stream)
  Stream<List<CommandeModel>> getCommandesStream() {
    return _db
        .collection('commandes')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommandeModel.fromFirestore(doc))
            .toList());
  }

  // Obtenir les commandes d'un étudiant
  Stream<List<CommandeModel>> getCommandesEtudiantStream(String nomEtudiant) {
    return _db
        .collection('commandes')
        .where('etudiant', isEqualTo: nomEtudiant)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommandeModel.fromFirestore(doc))
            .toList());
  }

  // Ajouter une commande
  Future<String> addCommande(CommandeModel commande) async {
    try {
      DocumentReference docRef = await _db.collection('commandes').add(commande.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Erreur lors de l\'ajout de la commande: $e';
    }
  }

  // Mettre à jour l'état d'une commande
  Future<void> updateCommandeEtat(String commandeId, EtatCommande etat) async {
    try {
      await _db.collection('commandes').doc(commandeId).update({
        'etat': etat.label,
      });
    } catch (e) {
      throw 'Erreur lors de la mise à jour de la commande: $e';
    }
  }

  // Supprimer une commande
  Future<void> deleteCommande(String commandeId) async {
    try {
      await _db.collection('commandes').doc(commandeId).delete();
    } catch (e) {
      throw 'Erreur lors de la suppression de la commande: $e';
    }
  }

  // Obtenir une commande par ID
  Future<CommandeModel?> getCommandeById(String commandeId) async {
    try {
      DocumentSnapshot doc = await _db.collection('commandes').doc(commandeId).get();
      if (doc.exists) {
        return CommandeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Erreur lors de la récupération de la commande: $e';
    }
  }

  // ============ ADMIN ============
  
  // Vérifier si un utilisateur est admin
  Future<bool> isAdmin(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('admin').doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw 'Erreur lors de la vérification admin: $e';
    }
  }

  // Obtenir les infos d'un admin
  Future<AdminModel?> getAdminInfo(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('admin').doc(uid).get();
      if (doc.exists) {
        return AdminModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Erreur lors de la récupération des infos admin: $e';
    }
  }

  // Ajouter un admin
  Future<void> addAdmin(String uid, String email) async {
    try {
      await _db.collection('admin').doc(uid).set({
        'email': email,
        'role': 'gerant',
      });
    } catch (e) {
      throw 'Erreur lors de l\'ajout de l\'admin: $e';
    }
  }

  // ============ STATISTIQUES ============
  
  // Obtenir le nombre total de commandes
  Future<int> getTotalCommandes() async {
    try {
      AggregateQuerySnapshot snapshot = await _db
          .collection('commandes')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Obtenir le nombre de commandes par état
  Future<Map<String, int>> getCommandesParEtat() async {
    try {
      QuerySnapshot snapshot = await _db.collection('commandes').get();
      Map<String, int> stats = {
        'En attente': 0,
        'Prêt': 0,
        'Rupture': 0,
      };

      for (var doc in snapshot.docs) {
        String etat = doc['etat'] ?? 'En attente';
        stats[etat] = (stats[etat] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      return {'En attente': 0, 'Prêt': 0, 'Rupture': 0};
    }
  }

  // Obtenir le revenu total
  Future<double> getRevenuTotal() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('commandes')
          .where('etat', isEqualTo: 'Prêt')
          .get();
      
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc['total'] ?? 0).toDouble();
      }
      
      return total;
    } catch (e) {
      return 0;
    }
  }
}