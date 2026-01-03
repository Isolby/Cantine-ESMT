import 'package:flutter/material.dart';
import '../../models/commande_model.dart';
import '../../constants/app_colors.dart';
import '../../utils/date_formatter.dart';

class CommandeCard extends StatelessWidget {
  final CommandeModel commande;
  final VoidCallback onMarquerPret;
  final VoidCallback onMarquerRupture;

  const CommandeCard({
    Key? key,
    required this.commande,
    required this.onMarquerPret,
    required this.onMarquerRupture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color etatColor = _getEtatColor(commande.etat);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : Nom + Badge + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commande.etudiant,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.getRelativeTime(commande.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: etatColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    commande.etat.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            
            // Liste des plats
            const Text(
              'Commande:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...commande.plats.map((plat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('${plat['nom']}'),
                    const Spacer(),
                    Text(
                      '${(plat['prix'] as num).toStringAsFixed(0)} FCFA',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 8),
            const Divider(),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${commande.total.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMarquerPret,
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Prêt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.etatPret,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMarquerRupture,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Rupture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.etatRupture,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getEtatColor(EtatCommande etat) {
    switch (etat) {
      case EtatCommande.enAttente:
        return AppColors.etatEnAttente;
      case EtatCommande.pret:
        return AppColors.etatPret;
      case EtatCommande.rupture:
        return AppColors.etatRupture;
    }
  }
}