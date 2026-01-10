import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/../../models/commande_model.dart';

class CommandeCard extends StatelessWidget {
  final CommandeModel commande;
  final VoidCallback? onMarquerPret;
  final VoidCallback? onMarquerRupture;

  const CommandeCard({
    Key? key,
    required this.commande,
    this.onMarquerPret,
    this.onMarquerRupture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color etatColor;
    IconData etatIcon;
    
    switch (commande.etat) {
      case EtatCommande.pret:
        etatColor = Colors.green;
        etatIcon = Icons.check_circle;
        break;
      case EtatCommande.rupture:
        etatColor = Colors.red;
        etatIcon = Icons.cancel;
        break;
      default:
        etatColor = Colors.orange;
        etatIcon = Icons.access_time;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et statut
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
                        DateFormat('dd/MM/yyyy HH:mm').format(commande.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: etatColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: etatColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(etatIcon, color: etatColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        commande.etat.label,
                        style: TextStyle(
                          color: etatColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            // Liste des plats
            const Text(
              'Plats commandés:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...commande.plats.map((plat) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.restaurant_menu, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plat['nom'] ?? 'Plat inconnu',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${(plat['prix'] ?? 0).toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${commande.total.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            // Boutons d'action (seulement si en attente)
            if (commande.etat == EtatCommande.enAttente) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMarquerPret,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Prêt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMarquerRupture,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Rupture'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}