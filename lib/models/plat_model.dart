import 'package:cloud_firestore/cloud_firestore.dart';

class PlatModel {
  final String id;
  final String nom;
  final double prix;
  final String image;

  PlatModel({
    required this.id,
    required this.nom,
    required this.prix,
    required this.image,
  });

  // Créer un Plat depuis Firestore
  factory PlatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PlatModel(
      id: doc.id,
      nom: data['nom'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      image: data['image'] ?? '🍽️',
    );
  }

  // Créer un Plat depuis Map
  factory PlatModel.fromMap(Map<String, dynamic> map, String id) {
    return PlatModel(
      id: id,
      nom: map['nom'] ?? '',
      prix: (map['prix'] ?? 0).toDouble(),
      image: map['image'] ?? '🍽️',
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prix': prix,
      'image': image,
    };
  }

  // Convertir en Map pour le panier (sans id)
  Map<String, dynamic> toPanierMap() {
    return {
      'nom': nom,
      'prix': prix,
      'image': image,
    };
  }

  // CopyWith pour créer une copie modifiée
  PlatModel copyWith({
    String? id,
    String? nom,
    double? prix,
    String? image,
  }) {
    return PlatModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prix: prix ?? this.prix,
      image: image ?? this.image,
    );
  }

  @override
  String toString() => 'PlatModel(id: $id, nom: $nom, prix: $prix)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlatModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}