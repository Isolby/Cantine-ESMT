import 'package:flutter/material.dart';
import 'package:projet_flutter/views/gerant/add_plat_plage.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/manage_plats_viewmodel.dart';
import '../../constants/app_colors.dart';
import '../../widgets/loading_indicator.dart';
import '../../models/plat_model.dart';
import '../../services/firestore_service.dart';
import 'edit_plat_page.dart';

class ManagePlatsPage extends StatelessWidget {
  const ManagePlatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ManagePlatsViewModel(firestoreService: FirestoreService()),
      child: const _ManagePlatsPageContent(),
    );
  }
}

class _ManagePlatsPageContent extends StatelessWidget {
  const _ManagePlatsPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les plats'),
        backgroundColor: AppColors.secondary,
        actions: [
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlatPage()),
          );
          
          if (result == true && context.mounted) {
            context.read<ManagePlatsViewModel>().refreshPlats();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Plat ajouté avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un plat'),
        backgroundColor: AppColors.success,
      ),
      body: Consumer<ManagePlatsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingIndicator(message: 'Chargement des plats...');
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.refreshPlats,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.plats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 100, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'Aucun plat dans le menu',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cliquez sur + pour ajouter un plat',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refreshPlats,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.plats.length,
              itemBuilder: (context, index) {
                final plat = viewModel.plats[index];
                return _PlatCard(
                  plat: plat,
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPlatPage(plat: plat),
                      ),
                    );
                    
                    if (result == true && context.mounted) {
                      context.read<ManagePlatsViewModel>().refreshPlats();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Plat modifié avec succès !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  onDelete: () => _confirmDelete(context, viewModel, plat),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ManagePlatsViewModel viewModel, PlatModel plat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${plat.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.supprimerPlat(plat.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${plat.nom} supprimé'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
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
              // Fermer le dialogue
              Navigator.pop(context);
              // Retourner à la page d'accueil (ferme toutes les pages jusqu'à la première)
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              );
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _PlatCard extends StatelessWidget {
  final PlatModel plat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlatCard({
    Key? key,
    required this.plat,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildImage(),
          ),
        ),
        title: Text(
          plat.nom,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${plat.prix.toStringAsFixed(0)} FCFA',
          style: TextStyle(
            color: AppColors.success,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Modifier',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Si pas d'image ou imageUrl null
    if (plat.imageUrl == null || plat.imageUrl!.isEmpty) {
      return const Icon(Icons.restaurant, size: 30, color: Colors.grey);
    }

    // Si c'est un emoji (moins de 10 caractères et pas d'URL)
    if (plat.imageUrl!.length < 10 && !plat.imageUrl!.contains('http')) {
      return Center(
        child: Text(
          plat.imageUrl!,
          style: const TextStyle(fontSize: 36),
        ),
      );
    }

    // Si c'est une image Firebase (URL)
    if (plat.imageUrl!.contains('http')) {
      return Image.network(
        plat.imageUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.restaurant, size: 30, color: Colors.grey);
        },
      );
    }

    return const Icon(Icons.restaurant, size: 30, color: Colors.grey);
  }
}