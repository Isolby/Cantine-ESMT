import 'package:flutter/material.dart';
import '../../models/plat_model.dart';

class PlatCard extends StatelessWidget {
  final PlatModel plat;
  final VoidCallback onAdd;

  const PlatCard({
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
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              plat.image,
              style: const TextStyle(fontSize: 36),
            ),
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