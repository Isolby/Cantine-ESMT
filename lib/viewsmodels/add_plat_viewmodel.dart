import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/plat_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AddPlatViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categorieController = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitting = false;
  File? _selectedImage;
  String _errorMessage = '';
  String _successMessage = '';

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  File? get selectedImage => _selectedImage;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  bool get hasImage => _selectedImage != null;

  // Sélectionner une image depuis la galerie
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _errorMessage = '';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la sélection de l\'image';
      print('❌ Erreur pickImage: $e');
      notifyListeners();
    }
  }

  // Prendre une photo avec la caméra
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _errorMessage = '';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la prise de photo';
      print('❌ Erreur takePhoto: $e');
      notifyListeners();
    }
  }

  // Supprimer l'image sélectionnée
  void removeSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // Supprimer l'image (ancienne méthode pour compatibilité)
  void removeImage() {
    removeSelectedImage();
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

  // Ajouter un plat avec ou sans image (nouvelle version)
  Future<bool> ajouterPlat({
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
    _errorMessage = '';
    notifyListeners();

    try {
      String? imageUrl;

      // Uploader l'image si elle existe
      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadPlatImage(_selectedImage!, nom);
        
        if (imageUrl == null) {
          _errorMessage = 'Erreur lors de l\'upload de l\'image';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Créer le plat
      PlatModel plat = PlatModel(
        nom: nom,
        prix: prix,
        categorie: categorie,
        description: description,
        imageUrl: imageUrl,
        dateAjout: DateTime.now(),
      );

      // Ajouter à Firestore
      await _firestoreService.ajouterPlat(plat);

      // Réinitialiser
      _selectedImage = null;
      _isLoading = false;
      notifyListeners();

      print('✅ Plat ajouté avec succès');
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout du plat';
      _isLoading = false;
      print('❌ Erreur ajouterPlat: $e');
      notifyListeners();
      return false;
    }
  }

  // Ancienne méthode ajouterPlat pour compatibilité
  Future<bool> ajouterPlatAncien() async {
    clearMessages();

    if (!formKey.currentState!.validate()) {
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final prix = double.parse(prixController.text.trim());

      // Créer un ID temporaire pour le plat
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();

      // 1. Upload l'image dans Firebase Storage si elle existe
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _storageService.uploadPlatImage(_selectedImage!, tempId);
      }

      // 2. Créer le plat avec l'URL de l'image
      final nouveauPlat = PlatModel(
        id: '', // Sera généré par Firestore
        nom: nomController.text.trim(),
        prix: prix,
        imageUrl: imageUrl,
        categorie: categorieController.text.trim(),
        description: descriptionController.text.trim(),
        dateAjout: DateTime.now(),
      );

      // 3. Enregistrer le plat dans Firestore
      await _firestoreService.ajouterPlat(nouveauPlat);

      _successMessage = 'Plat ajouté avec succès !';
      _isSubmitting = false;
      notifyListeners();

      // Réinitialiser le formulaire
      nomController.clear();
      prixController.clear();
      descriptionController.clear();
      categorieController.clear();
      _selectedImage = null;

      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Réinitialiser le formulaire
  void reset() {
    _selectedImage = null;
    _errorMessage = '';
    _successMessage = '';
    _isLoading = false;
    _isSubmitting = false;
    nomController.clear();
    prixController.clear();
    descriptionController.clear();
    categorieController.clear();
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