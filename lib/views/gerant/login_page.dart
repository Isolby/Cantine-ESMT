import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/login_viewmodel.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.connexionAdmin),
        backgroundColor: AppColors.secondary,
      ),
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      AppStrings.connexionAdmin,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Email
                    CustomTextField(
                      label: AppStrings.email,
                      prefixIcon: Icons.email,
                      controller: viewModel.emailController,
                      validator: Validators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    
                    // Password
                    CustomTextField(
                      label: AppStrings.motDePasse,
                      prefixIcon: Icons.lock,
                      suffixIcon: viewModel.obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onSuffixIconPressed: viewModel.togglePasswordVisibility,
                      controller: viewModel.passwordController,
                      validator: Validators.validatePassword,
                      obscureText: viewModel.obscurePassword,
                    ),
                    const SizedBox(height: 30),
                    
                    // Message d'erreur
                    if (viewModel.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Bouton de connexion
                    CustomButton(
                      text: AppStrings.seConnecter,
                      backgroundColor: AppColors.secondary,
                      isLoading: viewModel.isLoading,
                      onPressed: () => viewModel.login(context),
                    ),
                    const SizedBox(height: 20),
                    
                    // Info par défaut
                    Text(
                      AppStrings.defautLogin,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}