import 'package:flutter/material.dart';
import '../../models/plat_model.dart';

/// ================= WIDGET IMAGE DU PLAT =================
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
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant,
        size: width * 0.5,
        color: Colors.grey[600],
      ),
    );
  }
}

/// ================= PLAT CARD PRINCIPAL =================
class PlatCard extends StatelessWidget {
  final PlatModel plat;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              PlatImageWidget(
                plat: plat,
                width: 80,
                height: 80,
              ),

              const SizedBox(width: 15),

              /// INFOS PLAT
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// NOM + BADGE "DU JOUR"
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plat.nom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (plat.estPlatDuJour)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
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

                    const SizedBox(height: 4),

                    /// CATÉGORIE
                    Text(
                      plat.categorie,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    /// DESCRIPTION
                    if (plat.description != null &&
                        plat.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
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

                    const SizedBox(height: 8),

                    /// PRIX + DISPONIBILITÉ
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${plat.prix.toStringAsFixed(0)} FCFA',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                plat.disponible ? Colors.green : Colors.red,
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

              /// BOUTON AJOUTER
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
}

/// ================= VERSION SIMPLE =================
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${plat.prix.toStringAsFixed(0)} FCFA',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
