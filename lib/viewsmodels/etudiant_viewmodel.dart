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

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convertir les plats du panier en format Map
      List<Map<String, dynamic>> platsCommande = _panier
          .map((plat) => plat.toPanierMap())
          .toList();

      // Créer la commande
      CommandeModel commande = CommandeModel(
        id: '', // Sera généré par Firestore
        etudiant: nomEtudiant,
        plats: platsCommande,
        total: totalPanier,
        etat: EtatCommande.enAttente,
        date: DateTime.now(),
      );

      await _firestoreService.ajouterCommande(commande);
      
      viderPanier();
      _isSubmitting = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la commande';
      print('❌ Erreur passage commande: $e');
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