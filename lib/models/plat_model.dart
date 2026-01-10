class PlatModel {
  String? id;
  String nom;
  double prix;
  String categorie;
  String? description;
  bool estPlatDuJour;
  bool disponible;
  String? imageUrl; // URL de l'image dans Firebase Storage
  DateTime? dateAjout;

  PlatModel({
    this.id,
    required this.nom,
    required this.prix,
    required this.categorie,
    this.description,
    this.estPlatDuJour = false,
    this.disponible = true,
    this.imageUrl,
    this.dateAjout,
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prix': prix,
      'categorie': categorie,
      'description': description,
      'estPlatDuJour': estPlatDuJour,
      'disponible': disponible,
      'imageUrl': imageUrl,
      'dateAjout': dateAjout?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Créer un objet PlatModel depuis Firestore
  factory PlatModel.fromMap(String id, Map<String, dynamic> map) {
    return PlatModel(
      id: id,
      nom: map['nom'] ?? '',
      prix: (map['prix'] ?? 0).toDouble(),
      categorie: map['categorie'] ?? '',
      description: map['description'],
      estPlatDuJour: map['estPlatDuJour'] ?? false,
      disponible: map['disponible'] ?? true,
      imageUrl: map['imageUrl'],
      dateAjout: map['dateAjout'] != null 
          ? DateTime.parse(map['dateAjout']) 
          : DateTime.now(),
    );
  }

  // Copier avec modifications
  PlatModel copyWith({
    String? id,
    String? nom,
    double? prix,
    String? categorie,
    String? description,
    bool? estPlatDuJour,
    bool? disponible,
    String? imageUrl,
    DateTime? dateAjout,
  }) {
    return PlatModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prix: prix ?? this.prix,
      categorie: categorie ?? this.categorie,
      description: description ?? this.description,
      estPlatDuJour: estPlatDuJour ?? this.estPlatDuJour,
      disponible: disponible ?? this.disponible,
      imageUrl: imageUrl ?? this.imageUrl,
      dateAjout: dateAjout ?? this.dateAjout,
    );
  }

  // Pour le panier (simplifié)
  Map<String, dynamic> toPanierMap() {
    return {
      'id': id,
      'nom': nom,
      'prix': prix,
      'imageUrl': imageUrl,
    };
  }
}