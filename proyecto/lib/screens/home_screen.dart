import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/ciudad.dart';
import '../providers/city_provider.dart';
import 'posts_screen.dart';
import 'storage_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cityProvider = context.watch<CityProvider>();
    final ciudad = cityProvider.selected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Red & Seguridad · FIS-EPN'),
        centerTitle: true,
        backgroundColor: ciudad.color,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _CityHeader(ciudad: ciudad),
          const _ModulesGrid(),
        ],
      ),
    );
  }
}

class _CityHeader extends StatelessWidget {
  final CiudadEcuador ciudad;
  const _CityHeader({required this.ciudad});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('es_EC');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ciudad.color, ciudad.color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ciudad actual del Ecuador',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(ciudad.icono, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                '${ciudad.nombre}  ·  ${ciudad.provincia}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Pob. ${fmt.format(ciudad.poblacion)}  ·  Alt. ${ciudad.altitud.toStringAsFixed(0)} msnm',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ModulesGrid extends StatelessWidget {
  const _ModulesGrid();

  @override
  Widget build(BuildContext context) {
    final cityProvider = context.watch<CityProvider>();
    final ciudad = cityProvider.selected;

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Selecciona una ciudad del Ecuador'),
            const SizedBox(height: 8),
            _CiudadesList(ciudad: ciudad),
            const SizedBox(height: 20),
            const _SectionTitle('Módulos de la práctica'),
            const SizedBox(height: 8),
            _ModuleCard(
              icon: Icons.cloud_download,
              color: const Color(0xFF1A4D8F),
              title: 'Módulo 1 · Conectividad REST',
              subtitle:
                  'GET / PUT a JSONPlaceholder con loading states y validación HTTP 200.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              icon: Icons.lock_outline,
              color: const Color(0xFF2A9D8F),
              title: 'Módulo 3 · Almacenamiento Seguro',
              subtitle:
                  'SharedPreferences, Jetpack DataStore (Streams) y EncryptedShared AES-256.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StorageScreen()),
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Atractivos de la ciudad'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ciudad.atractivos
                  .map(
                    (a) => Chip(
                      avatar: Icon(ciudad.icono,
                          size: 16, color: ciudad.color),
                      label: Text(a),
                      backgroundColor: ciudad.color.withValues(alpha: 0.08),
                      side: BorderSide(color: ciudad.color.withValues(alpha: 0.4)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

class _CiudadesList extends StatelessWidget {
  final CiudadEcuador ciudad;
  const _CiudadesList({required this.ciudad});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: CiudadesEcuadorData.ciudades.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = CiudadesEcuadorData.ciudades[i];
          final isSelected = c.nombre == ciudad.nombre;
          return GestureDetector(
            onTap: () => context.read<CityProvider>().select(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 130,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? c.color
                    : c.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: c.color,
                  width: isSelected ? 0 : 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(c.icono,
                      color: isSelected ? Colors.white : c.color, size: 22),
                  Text(
                    c.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : c.color,
                    ),
                  ),
                  Text(
                    c.provincia,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : c.color,
                    ),
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

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}
