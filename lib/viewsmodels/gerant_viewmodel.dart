import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plat_model.dart';
import '../models/commande_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/fcm_service.dart';

class GerantViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final FCMService _fcmService = FCMService();
  
  List<PlatModel> _plats = [];
  List<CommandeModel> _commandes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlatModel> get plats => _plats;
  List<CommandeModel> get commandes => _commandes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters pour les statistiques
  int get totalCommandes => _commandes.length;
  int get commandesEnAttente => _commandes.where((c) => c.etat == EtatCommande.enAttente).length;
  int get commandesPret => _commandes.where((c) => c.etat == EtatCommande.pret).length;
  int get commandesRupture => _commandes.where((c) => c.etat == EtatCommande.rupture).length;
  double get totalRevenu => _commandes
      .where((c) => c.etat == EtatCommande.pret)
      .fold(0.0, (sum, c) => sum + c.total);
  double get revenuTotal => totalRevenu; // Alias pour compatibilité UI

  GerantViewModel() {
    _initializeData();
  }

  void _initializeData() {
    chargerPlats();
    _listenToCommandes();
  }

  // Charger les plats
  void chargerPlats() {
    _firestoreService.getPlats().listen((plats) {
      _plats = plats;
      notifyListeners();
    });
  }

  // ✅ NOUVEAU: Écouter les commandes en temps réel via stream
  void _listenToCommandes() {
    _firestoreService.commandesStream.listen(
      (commandes) {
        _commandes = commandes;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        print('✅ ${commandes.length} commandes chargées');
      },
      onError: (error) {
        _errorMessage = 'Erreur de connexion: $error';
        _isLoading = false;
        notifyListeners();
        print('❌ Erreur écoute commandes: $error');
      },
    );
  }

  // ✅ NOUVEAU: Retourner les commandes filtrées par statut
  List<CommandeModel> getCommandesByStatut(String statut) {
    return _commandes.where((c) {
      return c.etat.toString().toLowerCase() == statut.toLowerCase();
    }).toList();
  }

  // ✅ NOUVEAU: Charger les commandes avec gestion d'erreur
  Future<void> loadCommandes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Les commandes sont chargées via le listener en arrière-plan
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des commandes';
      _isLoading = false;
      print('❌ Erreur loadCommandes: $e');
    }
    notifyListeners();
  }

  // ✅ Méthode de rafraîchissement (alias pour loadCommandes)
  Future<void> refresh() async {
    await loadCommandes();
  }

  // ✅ NOUVEAU: Mettre à jour le statut d'une commande
  Future<void> updateCommandeStatut(String? commandeId, String newStatut) async {
    if (commandeId == null || commandeId.isEmpty) {
      _errorMessage = 'ID commande invalide';
      notifyListeners();
      return;
    }

    try {
      print('🔄 Mise à jour statut: $commandeId -> $newStatut');
      await _firestoreService.mettreAJourStatutCommande(commandeId, newStatut);
      print('✅ Statut mis à jour avec succès');
      // La mise à jour se fera automatiquement via le listener
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du statut';
      notifyListeners();
      print('❌ Erreur updateCommandeStatut: $e');
    }
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

  // Mettre à jour le statut d'une commande (méthode pour CommandeCard)
  Future<void> mettreAJourStatutCommande(String commandeId, String statut) async {
    await updateCommandeStatut(commandeId, statut);
  }

  // ✅ NOUVEAU: Test de notification
  void testNotification() {
    print('🧪 Test notification');
    // Afficher un SnackBar avec le token FCM
    final token = _fcmService.currentToken;
    if (token != null) {
      print('🔑 Token FCM actif: ${token.substring(0, 20)}...');
    } else {
      print('⚠️ Aucun token FCM disponible');
    }
  }

  // ✅ NOUVEAU: Déconnexion améliorée avec gestion FCM
  Future<void> logout() async {
    try {
      print('🔄 Déconnexion en cours...');
      
      // Désabonner des topics FCM
      await _fcmService.unsubscribeFromTopic('nouvelles_commandes');
      
      // Nettoyer les données locales
      _commandes = [];
      _plats = [];
      _errorMessage = null;
      
      print('✅ Déconnexion effectuée');
      notifyListeners();
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
      _errorMessage = 'Erreur lors de la déconnexion';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}