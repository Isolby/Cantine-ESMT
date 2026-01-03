import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String uid;
  final String email;
  final String role;

  AdminModel({
    required this.uid,
    required this.email,
    required this.role,
  });

  // Créer un Admin depuis Firestore
  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'gerant',
    );
  }

  // Créer un Admin depuis Map
  factory AdminModel.fromMap(Map<String, dynamic> map, String uid) {
    return AdminModel(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? 'gerant',
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
    };
  }

  // Vérifier si c'est un gérant
  bool get isGerant => role == 'gerant';

  @override
  String toString() => 'AdminModel(uid: $uid, email: $email, role: $role)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}