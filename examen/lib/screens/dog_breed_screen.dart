import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dog_breed.dart';
import '../providers/repository_provider.dart';
import '../repositories/local_repository.dart';
import '../widgets/dog_breed_form.dart';
import '../widgets/source_indicator.dart';

class DogBreedScreen extends StatelessWidget {
  const DogBreedScreen({super.key});

  Future<void> _openForm(BuildContext context, {DogBreed? initial}) async {
    final provider = context.read<RepositoryProvider>();
    final result = await showDialog<DogBreed>(
      context: context,
      builder: (_) => DogBreedForm(initial: initial),
    );
    if (result == null) return;
    if (initial == null) {
      await provider.addBreed(result);
    } else {
      await provider.updateBreed(result);
    }
  }

  Future<void> _confirmDelete(BuildContext context, DogBreed breed) async {
    final provider = context.read<RepositoryProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar raza'),
        content: Text('¿Seguro que deseas eliminar "${breed.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true && breed.id != null) {
      await provider.deleteBreed(breed.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razas de Perros'),
        actions: [
          const _SourceSwitcher(),
          const SizedBox(width: 8),
          const _SourceChip(),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<RepositoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.breeds.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return _ErrorView(message: provider.errorMessage!);
          }
          if (provider.breeds.isEmpty) {
            return const _EmptyView();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.breeds.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final b = provider.breeds[index];
              return ListTile(
                leading: CircleAvatar(child: Text(_initials(b.name))),
                title: Text(
                  b.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${b.origin} · ${b.size} · ${b.lifeExpectancy} años\n${b.description}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar',
                      onPressed: () => _openForm(context, initial: b),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Eliminar',
                      onPressed: () => _confirmDelete(context, b),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva raza'),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _SourceSwitcher extends StatelessWidget {
  const _SourceSwitcher();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepositoryProvider>();
    final isSql = provider.active == StorageType.sql;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'SQL',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Switch(
          value: !isSql,
          onChanged: (value) => provider.switchTo(
            value ? StorageType.nosql : StorageType.sql,
          ),
        ),
        const Text(
          'NoSQL',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepositoryProvider>();
    return SourceIndicator(active: provider.active);
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets, size: 64, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'No hay razas registradas en este motor.\n'
            'Toca "Nueva raza" para empezar.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Ocurrió un error al leer el origen activo:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
