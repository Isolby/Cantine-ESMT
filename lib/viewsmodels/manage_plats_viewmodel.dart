import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/plat_model.dart';

class ManagePlatsViewModel extends ChangeNotifier {
  final FirestoreService firestoreService;

  ManagePlatsViewModel({required this.firestoreService}) {
    _loadPlats();
  }

  List<PlatModel> _plats = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlatModel> get plats => _plats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadPlats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Utiliser le stream et prendre le premier résultat
      await for (var platsList in firestoreService.getPlats()) {
        _plats = platsList;
        _isLoading = false;
        notifyListeners();
        break; // Sortir après le premier résultat
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshPlats() async {
    await _loadPlats();
  }

  Future<void> supprimerPlat(String? platId) async {
    if (platId == null) return;
    
    try {
      // Trouver le plat
      final plat = _plats.firstWhere((p) => p.id == platId);
      
      // Supprimer via le service
      await firestoreService.supprimerPlat(plat);
      
      // Mettre à jour la liste locale
      _plats.removeWhere((plat) => plat.id == platId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}