import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/plat_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class EditPlatViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers pour le formulaire
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categorieController = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitting = false;
  File? _newImage;
  bool _removeCurrentImage = false;
  String _errorMessage = '';
  String _successMessage = '';
  String _currentImageUrl = '';

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  File? get newImage => _newImage;
  File? get selectedImage => _newImage; // Alias pour compatibilité
  bool get removeCurrentImage => _removeCurrentImage;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  String get currentImageUrl => _currentImageUrl;
  bool get hasImage => _newImage != null || (!_removeCurrentImage && _currentImageUrl.isNotEmpty);
  bool get hasNewImage => _newImage != null;

  // Constructeur avec initialisation des champs
  EditPlatViewModel({PlatModel? plat}) {
    if (plat != null) {
      _initializeWithPlat(plat);
    }
  }

  void _initializeWithPlat(PlatModel plat) {
    nomController.text = plat.nom;
    prixController.text = plat.prix.toStringAsFixed(0);
    descriptionController.text = plat.description ?? '';
    categorieController.text = plat.categorie;
    _currentImageUrl = plat.imageUrl ?? '';
  }

  // Sélectionner une nouvelle image
  Future<void> pickNewImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _newImage = File(image.path);
        _removeCurrentImage = false;
        _errorMessage = '';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la sélection de l\'image';
      print('❌ Erreur pickNewImage: $e');
      notifyListeners();
    }
  }

  // Prendre une nouvelle photo
  Future<void> takeNewPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _newImage = File(image.path);
        _removeCurrentImage = false;
        _errorMessage = '';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la prise de photo';
      print('❌ Erreur takeNewPhoto: $e');
      notifyListeners();
    }
  }

  // Méthodes pour compatibilité ascendante
  Future<void> pickImageFromGallery() async => pickNewImage();
  Future<void> takePhoto() async => takeNewPhoto();

  // Marquer l'image actuelle pour suppression
  void markImageForRemoval() {
    _removeCurrentImage = true;
    _newImage = null;
    notifyListeners();
  }

  // Annuler la suppression de l'image
  void cancelImageRemoval() {
    _removeCurrentImage = false;
    notifyListeners();
  }

  // Supprimer la nouvelle image sélectionnée
  void removeNewImage() {
    _newImage = null;
    notifyListeners();
  }

  // Validation du prix
  String? validatePrix(String? value) {
    if (value == null || value.isEmpty) {
      return 'Prix requis';
    }
    final prix = double.tryParse(value);
    if (prix == null) {
      return 'Prix invalide';
    }
    if (prix <= 0) {
      return 'Le prix doit être supérieur à 0';
    }
    return null;
  }

  // Effacer les messages
  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }

  // Pour compatibilité ascendante
  void clearError() => clearMessages();

  // Modifier un plat
  Future<bool> modifierPlat({
    required PlatModel plat,
    required String nom,
    required double prix,
    required String categorie,
    String? description,
  }) async {
    // Validation
    if (nom.isEmpty || prix <= 0 || categorie.isEmpty) {
      _errorMessage = 'Veuillez remplir tous les champs obligatoires';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      String? finalImageUrl = plat.imageUrl;

      // Gérer l'image
      if (_removeCurrentImage && plat.imageUrl != null) {
        // ✅ CORRECTION - Utiliser deletePlatImage
        await _storageService.deletePlatImage(plat.imageUrl!);
        finalImageUrl = null;
      }

      if (_newImage != null) {
        // Remplacer par la nouvelle image
        finalImageUrl = await _storageService.replaceImage(
          plat.imageUrl,
          _newImage!,
          nom,
        );

        if (finalImageUrl == null) {
          _errorMessage = 'Erreur lors de l\'upload de la nouvelle image';
          _isLoading = false;
          _isSubmitting = false;
          notifyListeners();
          return false;
        }
      }

      // Créer le plat modifié
      PlatModel platModifie = plat.copyWith(
        nom: nom,
        prix: prix,
        categorie: categorie,
        description: description,
        imageUrl: finalImageUrl,
      );

      // Mettre à jour dans Firestore
      await _firestoreService.mettreAJourPlat(platModifie);

      _successMessage = 'Plat modifié avec succès !';
      
      // Réinitialiser
      _newImage = null;
      _removeCurrentImage = false;
      _isLoading = false;
      _isSubmitting = false;
      _currentImageUrl = finalImageUrl ?? '';
      notifyListeners();

      print('✅ Plat modifié avec succès');
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification du plat';
      _isLoading = false;
      _isSubmitting = false;
      print('❌ Erreur modifierPlat: $e');
      notifyListeners();
      return false;
    }
  }

  // Réinitialiser
  void reset() {
    _newImage = null;
    _removeCurrentImage = false;
    _errorMessage = '';
    _successMessage = '';
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    nomController.dispose();
    prixController.dispose();
    descriptionController.dispose();
    categorieController.dispose();
    super.dispose();
  }
}