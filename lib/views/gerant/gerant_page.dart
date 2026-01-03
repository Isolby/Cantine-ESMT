import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/gerant_viewmodel.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/loading_indicator.dart';
import '../widgets/commande_card.dart';

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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GerantViewModel>().refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
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
                          padding: const EdgeInsets.all(16),
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
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GerantViewModel>().logout(context);
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}