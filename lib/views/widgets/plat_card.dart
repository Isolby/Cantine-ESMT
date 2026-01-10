import 'package:flutter/material.dart';
import '../../models/plat_model.dart';

// NOUVEAU WIDGET POUR LES IMAGES
class PlatImageWidget extends StatelessWidget {
  final PlatModel plat;
  final double width;
  final double height;
  final BoxFit fit;

  const PlatImageWidget({
    Key? key,
    required this.plat,
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: plat.imageUrl != null && plat.imageUrl!.isNotEmpty
          ? Image.network(
              plat.imageUrl!,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        Icons.restaurant,
        size: width * 0.5,
        color: Colors.grey[600],
      ),
    );
  }
}

class PlatCard extends StatelessWidget {
  final PlatModel plat;
  final VoidCallback onAdd;
  final VoidCallback? onTap; // Ajouté pour plus de flexibilité

  const PlatCard({
    Key? key,
    required this.plat,
    required this.onAdd,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap, // Support pour le onTap optionnel
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image du plat - REMPLACÉ PAR LE NOUVEAU WIDGET
              PlatImageWidget(
                plat: plat,
                width: 80,
                height: 80,
              ),
              
              const SizedBox(width: 15),
              
              // Informations du plat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plat.nom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (plat.estPlatDuJour)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Du jour',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      plat.categorie ?? 'Sans catégorie',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (plat.description != null && plat.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          plat.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${plat.prix.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: plat.disponible ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            plat.disponible ? 'Disponible' : 'Rupture',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Bouton Ajouter - CONSERVÉ POUR LA COMPATIBILITÉ
              IconButton(
                icon: const Icon(Icons.add_circle, size: 36),
                color: Colors.green,
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode conservée pour la compatibilité ascendante
  Widget _buildImage() {
    // Si le plat n'a pas d'image
    if (plat.imageUrl == null || plat.imageUrl!.isEmpty) {
      return const Icon(Icons.restaurant, size: 30, color: Colors.grey);
    }

    // Si c'est une ancienne méthode avec vérification d'emoji
    if (plat.imageUrl!.length <= 5) { // Probablement un emoji
      return Center(
        child: Text(
          plat.imageUrl!,
          style: const TextStyle(fontSize: 36),
        ),
      );
    }

    // Si c'est une image Firebase Storage
    if (plat.imageUrl!.contains('firebasestorage.googleapis.com')) {
      return Image.network(
        plat.imageUrl!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.restaurant, size: 30, color: Colors.grey);
        },
      );
    }

    // Par défaut, afficher une icône
    return const Icon(Icons.restaurant, size: 30, color: Colors.grey);
  }
}

// Version simplifiée du PlatCard pour compatibilité ascendante
class PlatCardSimple extends StatelessWidget {
  final PlatModel plat;
  final VoidCallback onAdd;

  const PlatCardSimple({
    Key? key,
    required this.plat,
    required this.onAdd,
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
        leading: PlatImageWidget(
          plat: plat,
          width: 60,
          height: 60,
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
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, size: 36),
          color: Colors.green,
          onPressed: onAdd,
        ),
      ),
    );
  }
}