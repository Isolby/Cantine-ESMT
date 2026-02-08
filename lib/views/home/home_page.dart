import 'package:flutter/material.dart';
import 'package:projet_flutter/viewsmodels/home_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 40),
              const Text(
                AppStrings.bienvenue,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              _buildButton(
                context,
                label: AppStrings.jesuisEtudiant,
                icon: Icons.school,
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.etudiant),
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                label: AppStrings.jesuisGerant,
                icon: Icons.admin_panel_settings,
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.loginGerant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}