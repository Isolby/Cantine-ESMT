import 'package:cloud_firestore/cloud_firestore.dart';

enum EtatCommande {
  enAttente,
  pret,
  rupture;

  String get label {
    switch (this) {
      case EtatCommande.enAttente:
        return 'En attente';
      case EtatCommande.pret:
        return 'Prêt';
      case EtatCommande.rupture:
        return 'Rupture';
    }
  }

  static EtatCommande fromString(String etat) {
    switch (etat.toLowerCase()) {
      case 'prêt':
      case 'pret':
        return EtatCommande.pret;
      case 'rupture':
        return EtatCommande.rupture;
      default:
        return EtatCommande.enAttente;
    }
  }
}

class CommandeModel {
  final String id;
  final String etudiant;
  final List<Map<String, dynamic>> plats;
  final EtatCommande etat;
  final double total;
  final DateTime date;

  CommandeModel({
    required this.id,
    required this.etudiant,
    required this.plats,
    required this.etat,
    required this.total,
    required this.date,
  });

  // Créer une Commande depuis Firestore
  factory CommandeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return CommandeModel(
      id: doc.id,
      etudiant: data['etudiant'] ?? '',
      plats: List<Map<String, dynamic>>.from(data['plats'] ?? []),
      etat: EtatCommande.fromString(data['etat'] ?? 'En attente'),
      total: (data['total'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Créer une Commande depuis Map
  factory CommandeModel.fromMap(Map<String, dynamic> map, String id) {
    return CommandeModel(
      id: id,
      etudiant: map['etudiant'] ?? '',
      plats: List<Map<String, dynamic>>.from(map['plats'] ?? []),
      etat: EtatCommande.fromString(map['etat'] ?? 'En attente'),
      total: (map['total'] ?? 0).toDouble(),
      date: map['date'] is Timestamp 
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'etudiant': etudiant,
      'plats': plats,
      'etat': etat.label,
      'total': total,
      'date': Timestamp.fromDate(date),
    };
  }

  // CopyWith pour créer une copie modifiée
  CommandeModel copyWith({
    String? id,
    String? etudiant,
    List<Map<String, dynamic>>? plats,
    EtatCommande? etat,
    double? total,
    DateTime? date,
  }) {
    return CommandeModel(
      id: id ?? this.id,
      etudiant: etudiant ?? this.etudiant,
      plats: plats ?? this.plats,
      etat: etat ?? this.etat,
      total: total ?? this.total,
      date: date ?? this.date,
    );
  }

  // Calculer le nombre total d'items
  int get nombrePlats => plats.length;

  // Obtenir la liste des noms de plats
  List<String> get nomPlats => plats.map((p) => p['nom'] as String).toList();

  @override
  String toString() {
    return 'CommandeModel(id: $id, etudiant: $etudiant, etat: ${etat.label}, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommandeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}