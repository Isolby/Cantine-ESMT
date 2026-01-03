import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/etudiant_viewmodel.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/validators.dart';
import '../widgets/plat_card.dart';

class EtudiantPage extends StatelessWidget {
  const EtudiantPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.espaceEtudiant),
        actions: [
          Consumer<EtudiantViewModel>(
            builder: (context, viewModel, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => _showPanier(context, viewModel),
                  ),
                  if (viewModel.panierCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${viewModel.panierCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<EtudiantViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingIndicator(message: 'Chargement du menu...');
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

          return Column(
            children: [
              // Champ nom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomTextField(
                  label: AppStrings.votreNom,
                  prefixIcon: Icons.person,
                  controller: viewModel.nomController,
                  validator: (value) =>
                      Validators.validateNotEmpty(value, 'Nom'),
                ),
              ),
              
              // Titre menu
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.menuDuJour,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Liste des plats
              Expanded(
                child: RefreshIndicator(
                  onRefresh: viewModel.refreshPlats,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.plats.length,
                    itemBuilder: (context, index) {
                      final plat = viewModel.plats[index];
                      return PlatCard(
                        plat: plat,
                        onAdd: () {
                          viewModel.ajouterAuPanier(plat);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${plat.nom} ${AppStrings.ajouteAuPanier}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              
              // Panier résumé
              if (viewModel.panier.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.total,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${viewModel.total.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: AppStrings.passerCommande,
                        backgroundColor: AppColors.success,
                        isLoading: viewModel.isSubmitting,
                        onPressed: () async {
                          final success = await viewModel.passerCommande(context);
                          if (success && context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Succès'),
                                content: const Text(AppStrings.commandeEnregistree),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showPanier(BuildContext context, EtudiantViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.panier,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (viewModel.panier.isNotEmpty)
                  TextButton(
                    onPressed: viewModel.viderPanier,
                    child: const Text('Vider'),
                  ),
              ],
            ),
            const Divider(),
            if (viewModel.panier.isEmpty)
              const Expanded(
                child: Center(child: Text(AppStrings.panierVide)),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.panier.length,
                  itemBuilder: (context, index) {
                    final plat = viewModel.panier[index];
                    return ListTile(
                      leading: Text(plat.image, style: const TextStyle(fontSize: 30)),
                      title: Text(plat.nom),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${plat.prix} FCFA'),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => viewModel.retirerDuPanier(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}