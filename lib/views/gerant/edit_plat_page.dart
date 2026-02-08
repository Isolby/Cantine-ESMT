import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/edit_plat_viewmodel.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../utils/validators.dart';
import '../../models/plat_model.dart';

class EditPlatPage extends StatelessWidget {
  final PlatModel plat;

  const EditPlatPage({Key? key, required this.plat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ✅ CORRECTION - Suppression du paramètre firestoreService
      create: (context) => EditPlatViewModel(plat: plat),
      child: _EditPlatPageContent(plat: plat),
    );
  }
}

class _EditPlatPageContent extends StatelessWidget {
  final PlatModel plat;
  
  const _EditPlatPageContent({Key? key, required this.plat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le plat'),
        backgroundColor: AppColors.secondary,
      ),
      body: Consumer<EditPlatViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prévisualisation de l'image
                  Center(
                    child: GestureDetector(
                      onTap: () => _showImageSourceDialog(context, viewModel),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildImagePreview(viewModel),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Boutons pour gérer l'image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showImageSourceDialog(context, viewModel),
                        icon: const Icon(Icons.edit),
                        label: const Text('Changer l\'image'),
                      ),
                      if (viewModel.hasNewImage) ...[
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: viewModel.removeNewImage,
                          icon: const Icon(Icons.undo, color: Colors.orange),
                          label: const Text('Annuler', style: TextStyle(color: Colors.orange)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Nom du plat
                  const Text(
                    'Nom du plat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Nom du plat',
                    hint: 'Ex: Riz au poulet',
                    prefixIcon: Icons.restaurant_menu,
                    controller: viewModel.nomController,
                    validator: (value) => Validators.validateNotEmpty(value, 'Nom'),
                  ),
                  const SizedBox(height: 24),

                  // Catégorie
                  const Text(
                    'Catégorie',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Catégorie',
                    hint: 'Ex: Plat principal',
                    prefixIcon: Icons.category,
                    controller: viewModel.categorieController,
                    validator: (value) => Validators.validateNotEmpty(value, 'Catégorie'),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description (optionnelle)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Description',
                    hint: 'Description du plat...',
                    prefixIcon: Icons.description,
                    controller: viewModel.descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Prix
                  const Text(
                    'Prix (FCFA)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Prix',
                    hint: 'Ex: 1500',
                    prefixIcon: Icons.attach_money,
                    controller: viewModel.prixController,
                    keyboardType: TextInputType.number,
                    validator: viewModel.validatePrix,
                  ),
                  const SizedBox(height: 32),

                  // Message d'erreur
                  if (viewModel.errorMessage.isNotEmpty) ...[
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
                              viewModel.errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: viewModel.isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          text: 'Enregistrer',
                          backgroundColor: AppColors.primary,
                          isLoading: viewModel.isSubmitting,
                          onPressed: () async {
                            if (!viewModel.formKey.currentState!.validate()) {
                              return;
                            }
                            
                            // Afficher la confirmation
                            final confirmed = await ConfirmationDialog.confirmEditPlat(
                              context,
                              viewModel.nomController.text.trim(),
                            );
                            
                            if (!confirmed || !context.mounted) return;
                            
                            final success = await viewModel.modifierPlat(
                              plat: plat,
                              nom: viewModel.nomController.text.trim(),
                              prix: double.tryParse(viewModel.prixController.text.trim()) ?? plat.prix,
                              categorie: viewModel.categorieController.text.trim(),
                              description: viewModel.descriptionController.text.trim(),
                            );
                            
                            if (success && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePreview(EditPlatViewModel viewModel) {
    // Si une nouvelle image a été sélectionnée
    if (viewModel.hasNewImage) {
      return Image.file(
        viewModel.newImage!,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    }

    // Si le plat a une image actuelle
    if (viewModel.currentImageUrl.isNotEmpty) {
      // Si c'est un emoji
      if (viewModel.currentImageUrl.length < 10 && 
          !viewModel.currentImageUrl.contains('http')) {
        return Center(
          child: Text(
            viewModel.currentImageUrl,
            style: const TextStyle(fontSize: 80),
          ),
        );
      }
      
      // Si c'est une URL d'image
      return Image.network(
        viewModel.currentImageUrl,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Image non disponible',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          );
        },
      );
    }

    // Aucune image
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          'Ajouter une photo',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context, EditPlatViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.secondary),
                title: const Text('Appareil photo'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.takePhoto();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}