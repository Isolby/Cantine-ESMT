import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodels/add_plat_viewmodel.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

// Widget de sélection d'image
class ImagePickerSection extends StatelessWidget {
  const ImagePickerSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPlatViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Photo du plat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Zone d'affichage de l'image
            GestureDetector(
              onTap: () => _showImageSourceDialog(context, viewModel),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: viewModel.selectedImage != null
                    ? Stack(
                        children: [
                          // Image sélectionnée
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              viewModel.selectedImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          
                          // Bouton supprimer
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => viewModel.removeSelectedImage(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 60,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Appuyez pour ajouter une photo',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Boutons Galerie et Caméra
            if (viewModel.selectedImage == null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => viewModel.pickImageFromGallery(),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galerie'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => viewModel.takePhoto(),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Caméra'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  void _showImageSourceDialog(BuildContext context, AddPlatViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir une source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Caméra'),
              onTap: () {
                Navigator.pop(context);
                viewModel.takePhoto();
              },
            ),
            if (viewModel.selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer la photo'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.removeSelectedImage();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class AddPlatPage extends StatelessWidget {
  const AddPlatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ✅ CORRECTION - Suppression du paramètre firestoreService
      create: (context) => AddPlatViewModel(),
      child: const _AddPlatPageContent(),
    );
  }
}

class _AddPlatPageContent extends StatelessWidget {
  const _AddPlatPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un plat'),
        backgroundColor: AppColors.secondary,
      ),
      body: Consumer<AddPlatViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Widget de sélection d'image
                  const ImagePickerSection(),
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
                    hint: 'Ex: Plat principal, Dessert, Boisson',
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

                  // Message de succès
                  if (viewModel.successMessage.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.successMessage,
                              style: const TextStyle(color: Colors.green),
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
                          text: 'Ajouter le plat',
                          backgroundColor: AppColors.success,
                          isLoading: viewModel.isSubmitting,
                          onPressed: () async {
                            // ✅ CORRECTION - Nouvelle méthode
                            if (!viewModel.formKey.currentState!.validate()) {
                              return;
                            }
                            
                            final success = await viewModel.ajouterPlat(
                              nom: viewModel.nomController.text.trim(),
                              prix: double.tryParse(viewModel.prixController.text.trim()) ?? 0,
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
}