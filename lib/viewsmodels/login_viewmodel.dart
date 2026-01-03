import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../constants/app_routes.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService authService;
  
  LoginViewModel({required this.authService});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(BuildContext context) async {
    clearError();
    
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _errorMessage = 'Veuillez remplir tous les champs';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Connexion avec Firebase Auth
      final userCredential = await authService.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential == null || userCredential.user == null) {
        throw 'Erreur de connexion';
      }

      // Vérifier que l'utilisateur est bien un admin
      final firestoreService = FirestoreService();
      bool isAdmin = await firestoreService.isAdmin(userCredential.user!.uid);

      if (!isAdmin) {
        await authService.signOut();
        throw 'Vous n\'êtes pas autorisé à accéder à cette interface';
      }

      _isLoading = false;
      notifyListeners();

      // Navigation vers la page gérant
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.gerant);
      }

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authService.signOut();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}