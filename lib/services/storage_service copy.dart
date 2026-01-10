import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Import nécessaire pour Uint8List
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload une image de plat et retourne l'URL de téléchargement
  Future<String> uploadPlatImage(File imageFile, String platId) async {
    try {
      // Référence vers le dossier plats dans Storage
      final ref = _storage.ref().child('plats/$platId.jpg');

      // Upload du fichier
      final uploadTask = await ref.putFile(imageFile);

      // Récupérer l'URL de téléchargement
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Erreur lors de l\'upload de l\'image: $e';
    }
  }

  /// Upload une image depuis le web (pour Flutter Web)
  Future<String> uploadPlatImageWeb(Uint8List imageData, String platId) async {
    try {
      final ref = _storage.ref().child('plats/$platId.jpg');
      
      final uploadTask = await ref.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Erreur lors de l\'upload de l\'image: $e';
    }
  }

  /// Supprimer une image de plat
  Future<void> deletePlatImage(String imageUrl) async {
    try {
      // Extraire le chemin depuis l'URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Si l'image n'existe pas, on ignore l'erreur
      print('Erreur lors de la suppression de l\'image: $e');
    }
  }

  /// Vérifier si une URL est une image Firebase Storage
  bool isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }

  /// Obtenir l'URL d'une image placeholder par défaut
  String getDefaultPlaceholder() {
    return 'https://via.placeholder.com/200x200.png?text=Pas+d\'image';
  }
}
