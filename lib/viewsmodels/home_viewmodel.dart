import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  // Pas besoin de logique complexe pour la page d'accueil
  // Mais on garde cette structure pour la cohérence MVVM
  
  void navigateToEtudiant(BuildContext context) {
    Navigator.pushNamed(context, '/etudiant');
  }

  void navigateToGerant(BuildContext context) {
    Navigator.pushNamed(context, '/login-gerant');
  }
}