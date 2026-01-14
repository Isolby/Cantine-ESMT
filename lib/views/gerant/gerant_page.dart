import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/gerant_viewmodel.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/loading_indicator.dart';
import '../widgets/commande_card.dart';
import 'manage_plats_page.dart';

class GerantPage extends StatelessWidget {
  const GerantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.espaceGerant),
        backgroundColor: AppColors.secondary,
        automaticallyImplyLeading: false,
        actions: [
          // Bouton pour gérer les plats
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Gérer les plats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManagePlatsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GerantViewModel>().refresh();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'manage_plats') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagePlatsPage(),
                  ),
                );
              } else if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'manage_plats',
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Gérer les plats'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Floating Action Button pour accès rapide
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManagePlatsPage(),
            ),
          );
        },
        icon: const Icon(Icons.restaurant_menu),
        label: const Text('Gérer les plats'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<GerantViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingIndicator(message: 'Chargement des commandes...');
          }

          return Column(
            children: [
              // Statistiques en haut
              _buildStatistiques(viewModel),
              
              // Liste des commandes
              Expanded(
                child: viewModel.commandes.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: viewModel.refresh,
                        child: ListView.builder(
                          itemCount: viewModel.commandes.length,
                          itemBuilder: (context, index) {
                            final commande = viewModel.commandes[index];
                            return CommandeCard(
                              commande: commande,
                              onMarquerPret: () => viewModel.marquerPret(commande.id),
                              onMarquerRupture: () => viewModel.marquerRupture(commande.id),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatistiques(GerantViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  viewModel.totalCommandes.toString(),
                  Icons.receipt_long,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'En attente',
                  viewModel.commandesEnAttente.toString(),
                  Icons.pending,
                  AppColors.etatEnAttente,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Prêt',
                  viewModel.commandesPret.toString(),
                  Icons.check_circle,
                  AppColors.etatPret,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Rupture',
                  viewModel.commandesRupture.toString(),
                  Icons.cancel,
                  AppColors.etatRupture,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: AppColors.success),
                const SizedBox(width: 8),
                const Text(
                  'Revenu total: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${viewModel.revenuTotal.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            AppStrings.aucuneCommande,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              // Fermer le dialogue
              Navigator.pop(dialogContext);
              
              // Déconnexion de Firebase Auth
              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.signOut();
              } catch (e) {
                print('Erreur déconnexion: $e');
              }
              
              // Retourner à la page d'accueil
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              }
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}