import 'package:flutter/material.dart';
import '../models/plat_model.dart';
import '../models/commande_model.dart';
import '../services/firestore_service.dart';

class EtudiantViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<PlatModel> _plats = [];
  List<PlatModel> _panier = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  
  final TextEditingController nomController = TextEditingController();

  List<PlatModel> get plats => _plats;
  List<PlatModel> get panier => _panier;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int get panierCount => _panier.length;
  double get total => totalPanier;

  // Récupérer le plat du jour
  PlatModel? get platDuJour {
    try {
      return _plats.firstWhere((plat) => plat.estPlatDuJour && plat.disponible);
    } catch (e) {
      return null;
    }
  }

  // Récupérer les plats disponibles (hors plat du jour)
  List<PlatModel> get platsDisponibles {
    return _plats.where((plat) => !plat.estPlatDuJour && plat.disponible).toList();
  }

  // Calculer le total du panier
  double get totalPanier {
    return _panier.fold(0, (sum, plat) => sum + plat.prix);
  }

  EtudiantViewModel() {
    chargerPlats();
  }

  // Charger les plats depuis Firebase
  void chargerPlats() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _firestoreService.getPlats().listen(
      (plats) {
        _plats = plats;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erreur de chargement des plats';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Rafraîchir les plats
  Future<void> refreshPlats() async {
    chargerPlats();
  }

  // Rafraîchir (alias pour compatibilité)
  Future<void> refresh() async {
    chargerPlats();
  }

  // Ajouter au panier
  void ajouterAuPanier(PlatModel plat) {
    _panier.add(plat);
    notifyListeners();
  }

  // Retirer du panier
  void retirerDuPanier(int index) {
    if (index >= 0 && index < _panier.length) {
      _panier.removeAt(index);
      notifyListeners();
    }
  }

  // Vider le panier
  void viderPanier() {
    _panier.clear();
    nomController.clear();
    notifyListeners();
  }

  // Passer la commande (prend le nom depuis le controller)
  Future<bool> passerCommande(String nomEtudiant) async {
    // Validations préalables
    if (_panier.isEmpty) {
      _errorMessage = 'Le panier est vide';
      notifyListeners();
      return false;
    }

    if (nomEtudiant.isEmpty) {
      _errorMessage = 'Veuillez entrer votre nom';
      notifyListeners();
      return false;
    }

    if (totalPanier <= 0) {
      _errorMessage = 'Le total de la commande est invalide';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validation des plats du panier
      print('📦 Validation du panier (${_panier.length} plats)');
      print('💰 Total: ${totalPanier} FCFA');
      print('👤 Étudiant: $nomEtudiant');
      
      for (int i = 0; i < _panier.length; i++) {
        final plat = _panier[i];
        if (plat.nom.isEmpty) {
          throw Exception('Plat $i: nom vide');
        }
        if (plat.prix <= 0) {
          throw Exception('Plat ${plat.nom}: prix invalide (${plat.prix})');
        }
        print('  ✅ Plat ${i + 1}: ${plat.nom} (${plat.prix} FCFA)');
      }

      // Convertir les plats du panier en format Map avec validation
      List<Map<String, dynamic>> platsCommande = [];
      for (var plat in _panier) {
        final map = plat.toPanierMap();
        
        // Valider la structure
        if (map['nom'] == null || map['nom'].toString().isEmpty) {
          throw Exception('Champ nom manquant ou vide');
        }
        if (map['prix'] == null || map['prix'] <= 0) {
          throw Exception('Champ prix manquant ou invalide');
        }
        
        platsCommande.add(map);
      }

      if (platsCommande.isEmpty) {
        throw Exception('Impossible de convertir les plats du panier');
      }

      print('📤 Conversion réussie de ${platsCommande.length} plat(s)');

      // Créer la commande avec validation
      CommandeModel commande = CommandeModel(
        id: '', // Sera généré par Firestore
        etudiant: nomEtudiant.trim(),
        plats: platsCommande,
        total: totalPanier,
        etat: EtatCommande.enAttente,
        date: DateTime.now(),
      );

      print('📝 Modèle de commande créé:');
      print('   ID: ${commande.id.isEmpty ? "sera généré" : commande.id}');
      print('   Étudiant: ${commande.etudiant}');
      print('   État: ${commande.etat.label}');
      print('   Total: ${commande.total} FCFA');
      print('   Nombre de plats: ${commande.nombrePlats}');

      // Convertir en Map pour Firestore
      final commandeMap = commande.toMap();
      print('🔍 Données à envoyer à Firestore:');
      print('   $commandeMap');

      // Envoyer à Firestore
      print('🚀 Envoi de la commande à Firestore...');
      await _firestoreService.ajouterCommande(commande);
      
      print('✅ Commande envoyée avec succès');
      viderPanier();
      _isSubmitting = false;
      _errorMessage = null;
      notifyListeners();
      return true;
      
    } catch (e) {
      String detailedError = '';
      final errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains('permission')) {
        detailedError = '❌ Permissions insuffisantes: Vérifiez les règles Firestore';
      } else if (errorStr.contains('network') || errorStr.contains('socket')) {
        detailedError = '❌ Erreur réseau: Vérifiez votre connexion Internet';
      } else if (errorStr.contains('not found') || errorStr.contains('collection')) {
        detailedError = '❌ Collection manquante: Créez "commandes" dans Firestore';
      } else if (errorStr.contains('invalid')) {
        detailedError = '❌ Données invalides: Vérifiez les informations de la commande';
      } else if (errorStr.contains('authentication')) {
        detailedError = '❌ Authentification requise: Connectez-vous';
      } else if (errorStr.contains('timeout')) {
        detailedError = '❌ Timeout: La requête a pris trop de temps, vérifiez votre connexion';
      } else {
        detailedError = 'Erreur: ${e.toString().split('\n').first}';
      }
      
      _errorMessage = detailedError;
      print('❌ Erreur passage commande: $e');
      print('📋 Type d\'erreur: ${e.runtimeType}');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    super.dispose();
  }
}