import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Uploader une image et retourner l'URL
  Future<String?> uploadPlatImage(File imageFile, String platNom) async {
    try {
      // Créer un nom unique pour l'image
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${platNom.replaceAll(' ', '_')}.jpg';
      
      // Référence vers le dossier 'plats' dans Storage
      Reference ref = _storage.ref().child('plats/$fileName');
      
      // Uploader le fichier
      UploadTask uploadTask = ref.putFile(imageFile);
      
      // Attendre la fin de l'upload
      TaskSnapshot snapshot = await uploadTask;
      
      // Récupérer l'URL de téléchargement
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Image uploadée avec succès: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erreur upload image: $e');
      return null;
    }
  }

  // Supprimer une image de Storage à partir de son URL
  Future<bool> deletePlatImage(String imageUrl) async {
    try {
      // Créer une référence à partir de l'URL
      Reference ref = _storage.refFromURL(imageUrl);
      
      // Supprimer le fichier
      await ref.delete();
      
      print('✅ Image supprimée avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur suppression image: $e');
      return false;
    }
  }

  // Remplacer une image (supprimer l'ancienne et uploader la nouvelle)
  Future<String?> replaceImage(String? oldImageUrl, File newImageFile, String platNom) async {
    try {
      // Supprimer l'ancienne image si elle existe
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await deletePlatImage(oldImageUrl);
      }
      
      // Uploader la nouvelle image
      String? newImageUrl = await uploadPlatImage(newImageFile, platNom);
      return newImageUrl;
    } catch (e) {
      print('❌ Erreur remplacement image: $e');
      return null;
    }
  }

  // Vérifier si une image existe
  Future<bool> imageExists(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }
}