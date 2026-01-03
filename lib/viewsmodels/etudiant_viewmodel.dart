import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/plat_model.dart';
import '../models/commande_model.dart';

class EtudiantViewModel extends ChangeNotifier {
  final FirestoreService firestoreService;

  EtudiantViewModel({required this.firestoreService}) {
    _loadPlats();
  }

  final TextEditingController nomController = TextEditingController();
  
  List<PlatModel> _plats = [];
  List<PlatModel> _panier = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<PlatModel> get plats => _plats;
  List<PlatModel> get panier => _panier;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int get panierCount => _panier.length;
  
  double get total {
    return _panier.fold(0, (sum, plat) => sum + plat.prix);
  }

  bool get canSubmit => nomController.text.isNotEmpty && _panier.isNotEmpty;

  // Charger les plats depuis Firestore
  Future<void> _loadPlats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plats = await firestoreService.getPlats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Rafraîchir les plats
  Future<void> refreshPlats() async {
    await _loadPlats();
  }

  // Ajouter un plat au panier
  void ajouterAuPanier(PlatModel plat) {
    _panier.add(plat);
    notifyListeners();
  }

  // Retirer un plat du panier
  void retirerDuPanier(int index) {
    if (index >= 0 && index < _panier.length) {
      _panier.removeAt(index);
      notifyListeners();
    }
  }

  // Vider le panier
  void viderPanier() {
    _panier.clear();
    notifyListeners();
  }

  // Passer la commande
  Future<bool> passerCommande(BuildContext context) async {
    if (!canSubmit) {
      _errorMessage = nomController.text.isEmpty 
          ? 'Veuillez entrer votre nom'
          : 'Votre panier est vide';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convertir les plats du panier en Map
      List<Map<String, dynamic>> platsMap = _panier
          .map((plat) => plat.toPanierMap())
          .toList();

      // Créer la commande
      CommandeModel commande = CommandeModel(
        id: '', // Sera généré par Firestore
        etudiant: nomController.text.trim(),
        plats: platsMap,
        etat: EtatCommande.enAttente,
        total: total,
        date: DateTime.now(),
      );

      // Enregistrer dans Firestore
      await firestoreService.addCommande(commande);

      // Réinitialiser
      nomController.clear();
      _panier.clear();
      _isSubmitting = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
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