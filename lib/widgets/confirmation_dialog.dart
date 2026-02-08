import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ConfirmationDialog {
  /// Affiche une boîte de dialogue de confirmation
  /// Retourne true si l'utilisateur confirme, false sinon
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // L'utilisateur doit choisir une option
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isDangerous ? AppColors.error : AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey,
            ),
          ),
          actions: [
            // Bouton Annuler
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            
            // Bouton Confirmer
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? 
                    (isDangerous ? AppColors.error : AppColors.primary),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                confirmText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false; // Retourne false si l'utilisateur ferme le dialogue
  }

  /// Confirmation pour ajouter un plat
  static Future<bool> confirmAddPlat(BuildContext context) {
    return show(
      context: context,
      title: 'Ajouter ce plat ?',
      message: 'Voulez-vous vraiment ajouter ce plat au menu ?',
      confirmText: 'Ajouter',
      icon: Icons.add_circle_outline,
      confirmColor: AppColors.success, // Vert pour l'ajout
    );
  }

  /// Confirmation pour modifier un plat
  static Future<bool> confirmEditPlat(BuildContext context, String platName) {
    return show(
      context: context,
      title: 'Modifier le plat ?',
      message: 'Voulez-vous vraiment modifier "$platName" ?',
      confirmText: 'Modifier',
      icon: Icons.edit_outlined,
      confirmColor: AppColors.primary, // Bleu pour la modification
    );
  }

  /// Confirmation pour supprimer un plat
  static Future<bool> confirmDeletePlat(BuildContext context, String platName) {
    return show(
      context: context,
      title: 'Supprimer le plat ?',
      message: 'Voulez-vous vraiment supprimer "$platName" ?\nCette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDangerous: true, // Rouge (AppColors.error)
      icon: Icons.delete_forever_outlined,
    );
  }

  /// Confirmation pour déconnexion
  static Future<bool> confirmLogout(BuildContext context) {
    return show(
      context: context,
      title: 'Déconnexion',
      message: 'Voulez-vous vraiment vous déconnecter ?',
      confirmText: 'Déconnexion',
      icon: Icons.logout,
      isDangerous: true, // Rouge (AppColors.error)
    );
  }

  /// Confirmation générique pour actions avec avertissement
  static Future<bool> confirmWarningAction({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmer',
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      icon: Icons.warning_amber_rounded,
      confirmColor: AppColors.warning, // Orange pour les avertissements
    );
  }

  /// Confirmation générique pour actions dangereuses
  static Future<bool> confirmDangerousAction({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmer',
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      isDangerous: true,
      icon: Icons.error_outline,
    );
  }

  /// Confirmation pour actions de succès
  static Future<bool> confirmSuccessAction({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      icon: Icons.check_circle_outline,
      confirmColor: AppColors.success, // Vert pour le succès
    );
  }
}