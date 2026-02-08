import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/gerant_viewmodel.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../models/commande_model.dart';
import '../widgets/commande_card.dart';

class GerantPage extends StatefulWidget {
  const GerantPage({Key? key}) : super(key: key);

  @override
  State<GerantPage> createState() => _GerantPageState();
}

class _GerantPageState extends State<GerantPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GerantViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Gestion Cantine'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              // Bouton test notification
              IconButton(
                icon: const Icon(Icons.notification_add),
                tooltip: 'Tester les notifications',
                onPressed: () {
                  viewModel.testNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification envoyé !'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              // Bouton gérer les plats
              IconButton(
                icon: const Icon(Icons.restaurant_menu),
                tooltip: 'Gérer les plats',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.managePlats);
                },
              ),
              // Bouton déconnexion
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Déconnexion',
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Êtes-vous sûr ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed != true) return;

                  await viewModel.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Toutes', icon: Icon(Icons.list_alt)),
                Tab(text: 'En attente', icon: Icon(Icons.pending)),
                Tab(text: 'Prêtes', icon: Icon(Icons.check_circle)),
                Tab(text: 'Rupture', icon: Icon(Icons.cancel)),
              ],
            ),
          ),
          body: _buildBody(viewModel),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => viewModel.loadCommandes(),
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildBody(GerantViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: viewModel.loadCommandes,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStatistics(viewModel),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCommandesList(
                viewModel,
                viewModel.commandes,
              ),
              _buildCommandesList(
                viewModel,
                viewModel.getCommandesByStatut('enAttente'),
              ),
              _buildCommandesList(
                viewModel,
                viewModel.getCommandesByStatut('pret'),
              ),
              _buildCommandesList(
                viewModel,
                viewModel.getCommandesByStatut('rupture'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(GerantViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              viewModel.totalCommandes.toString(),
              Icons.receipt_long,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'En attente',
              viewModel.commandesEnAttente.toString(),
              Icons.pending_actions,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Revenu',
              '${viewModel.totalRevenu.toStringAsFixed(0)} F',
              Icons.attach_money,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandesList(
    GerantViewModel viewModel,
    List<CommandeModel> commandes,
  ) {
    if (commandes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Aucune commande',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadCommandes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: commandes.length,
        itemBuilder: (context, index) {
          return CommandeCard(
            commande: commandes[index],
            onMarquerPret: () {
              viewModel.updateCommandeStatut(
                commandes[index].id,
                'pret',
              );
            },
            onMarquerRupture: () {
              viewModel.updateCommandeStatut(
                commandes[index].id,
                'rupture',
              );
            },
          );
        },
      ),
    );
  }
}
