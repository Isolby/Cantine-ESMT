import 'package:flutter/material.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/commande_model.dart';
import '../constants/app_routes.dart';

class GerantViewModel extends ChangeNotifier {
  final FirestoreService firestoreService;
  
  GerantViewModel({required this.firestoreService}) {
    _loadCommandes();
    _loadStatistiques();
  }

  List<CommandeModel> _commandes = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<CommandeModel>>? _commandesSubscription;

  // Statistiques
  int _totalCommandes = 0;
  int _commandesEnAttente = 0;
  int _commandesPret = 0;
  int _commandesRupture = 0;
  double _revenuTotal = 0;

  List<CommandeModel> get commandes => _commandes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCommandes => _totalCommandes;
  int get commandesEnAttente => _commandesEnAttente;
  int get commandesPret => _commandesPret;
  int get commandesRupture => _commandesRupture;
  double get revenuTotal => _revenuTotal;

  // Charger les commandes en temps réel
  void _loadCommandes() {
    _isLoading = true;
    notifyListeners();

    _commandesSubscription?.cancel();
    _commandesSubscription = firestoreService.getCommandesStream().listen(
      (commandes) {
        _commandes = commandes;
        _isLoading = false;
        _errorMessage = null;
        _updateStatistiques();
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Charger les statistiques
  Future<void> _loadStatistiques() async {
    try {
      _totalCommandes = await firestoreService.getTotalCommandes();
      _revenuTotal = await firestoreService.getRevenuTotal();
      notifyListeners();
    } catch (e) {
      // Erreur silencieuse pour les stats
    }
  }

  // Mettre à jour les statistiques localement
  void _updateStatistiques() {
    _totalCommandes = _commandes.length;
    _commandesEnAttente = _commandes
        .where((c) => c.etat == EtatCommande.enAttente)
        .length;
    _commandesPret = _commandes
        .where((c) => c.etat == EtatCommande.pret)
        .length;
    _commandesRupture = _commandes
        .where((c) => c.etat == EtatCommande.rupture)
        .length;
    _revenuTotal = _commandes
        .where((c) => c.etat == EtatCommande.pret)
        .fold(0, (sum, c) => sum + c.total);
  }

  // Changer l'état d'une commande
  Future<void> changerEtatCommande(String commandeId, EtatCommande nouvelEtat) async {
    try {
      await firestoreService.updateCommandeEtat(commandeId, nouvelEtat);
      // Le stream se mettra à jour automatiquement
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Marquer comme Prêt
  Future<void> marquerPret(String commandeId) async {
    await changerEtatCommande(commandeId, EtatCommande.pret);
  }

  // Marquer comme Rupture
  Future<void> marquerRupture(String commandeId) async {
    await changerEtatCommande(commandeId, EtatCommande.rupture);
  }

  // Rafraîchir manuellement
  Future<void> refresh() async {
    _loadCommandes();
    await _loadStatistiques();
  }

  // Filtrer les commandes par état
  List<CommandeModel> getCommandesByEtat(EtatCommande etat) {
    return _commandes.where((c) => c.etat == etat).toList();
  }

  // Déconnexion
  Future<void> logout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context, 
        AppRoutes.home, 
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _commandesSubscription?.cancel();
    super.dispose();
  }
}