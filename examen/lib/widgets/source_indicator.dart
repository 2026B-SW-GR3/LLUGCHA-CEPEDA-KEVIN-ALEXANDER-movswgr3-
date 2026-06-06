import 'package:flutter/material.dart';

import '../repositories/local_repository.dart';

/// Etiqueta visual que muestra de forma clara el motor de persistencia que
/// está siendo utilizado en este momento.
class SourceIndicator extends StatelessWidget {
  const SourceIndicator({super.key, required this.active});

  final StorageType active;

  @override
  Widget build(BuildContext context) {
    final isSql = active == StorageType.sql;
    final label = isSql ? 'Origen: SQLite' : 'Origen: Hive (NoSQL)';
    final color = isSql ? Colors.indigo : Colors.orange;
    final icon = isSql ? Icons.storage : Icons.dataset_outlined;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        avatar: Icon(icon, size: 18, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        backgroundColor: color,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
