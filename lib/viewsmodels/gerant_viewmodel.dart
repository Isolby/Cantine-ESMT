import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plat_model.dart';
import '../models/commande_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class GerantViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  
  List<PlatModel> _plats = [];
  List<CommandeModel> _commandes = [];
  bool _isLoading = false;

  List<PlatModel> get plats => _plats;
  List<CommandeModel> get commandes => _commandes;
  bool get isLoading => _isLoading;

  // Getters pour les statistiques
  int get totalCommandes => _commandes.length;
  int get commandesEnAttente => _commandes.where((c) => c.etat == EtatCommande.enAttente).length;
  int get commandesPret => _commandes.where((c) => c.etat == EtatCommande.pret).length;
  int get commandesRupture => _commandes.where((c) => c.etat == EtatCommande.rupture).length;
  double get revenuTotal => _commandes.where((c) => c.etat == EtatCommande.pret).fold(0, (sum, c) => sum + c.total);

  GerantViewModel() {
    chargerPlats();
    chargerCommandes();
  }

  // Charger les plats
  void chargerPlats() {
    _firestoreService.getPlats().listen((plats) {
      _plats = plats;
      notifyListeners();
    });
  }

  // Charger les commandes
  void chargerCommandes() {
    _firestoreService.getCommandes().listen((commandes) {
      _commandes = commandes;
      notifyListeners();
    });
  }

  // Rafraîchir les données
  Future<void> refresh() async {
    chargerPlats();
    chargerCommandes();
  }

  // Marquer commande comme prête
  Future<void> marquerPret(String? commandeId) async {
    if (commandeId != null) {
      await _firestoreService.mettreAJourStatutCommande(commandeId, 'Prêt');
    }
  }

  // Marquer commande en rupture
  Future<void> marquerRupture(String? commandeId) async {
    if (commandeId != null) {
      await _firestoreService.mettreAJourStatutCommande(commandeId, 'Rupture');
    }
  }

  // Ajouter un plat
  Future<bool> ajouterPlat(String nom, double prix, String categorie, {File? imageFile}) async {
    if (nom.isEmpty || prix <= 0) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      
      // Uploader l'image si elle existe
      if (imageFile != null) {
        imageUrl = await _storageService.uploadPlatImage(imageFile, nom);
      }

      PlatModel plat = PlatModel(
        nom: nom,
        prix: prix,
        categorie: categorie,
        imageUrl: imageUrl,
      );

      await _firestoreService.ajouterPlat(plat);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Définir le plat du jour
  Future<bool> definirPlatDuJour(String platId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.definirPlatDuJour(platId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Changer la disponibilité d'un plat
  Future<void> changerDisponibilite(PlatModel plat) async {
    plat.disponible = !plat.disponible;
    await _firestoreService.mettreAJourPlat(plat);
  }

  // Supprimer un plat
  Future<bool> supprimerPlat(PlatModel plat) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.supprimerPlat(plat);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Modifier un plat
  Future<bool> modifierPlat(PlatModel plat, String nom, double prix, String categorie, {File? nouvelleImage, bool supprimerImage = false}) async {
    if (nom.isEmpty || prix <= 0) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      plat.nom = nom;
      plat.prix = prix;
      plat.categorie = categorie;

      // Gérer l'image
      if (supprimerImage && plat.imageUrl != null) {
        await _storageService.deletePlatImage(plat.imageUrl!);
        plat.imageUrl = null;
      }

      if (nouvelleImage != null) {
        if (plat.imageUrl != null) {
          await _storageService.deletePlatImage(plat.imageUrl!);
        }
        plat.imageUrl = await _storageService.uploadPlatImage(nouvelleImage, nom);
      }

      await _firestoreService.mettreAJourPlat(plat);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour le statut d'une commande
  Future<void> mettreAJourStatutCommande(String commandeId, String statut) async {
    await _firestoreService.mettreAJourStatutCommande(commandeId, statut);
  }
}