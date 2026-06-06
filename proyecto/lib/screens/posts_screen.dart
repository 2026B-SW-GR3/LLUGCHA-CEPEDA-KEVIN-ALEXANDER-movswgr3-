import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _idController = TextEditingController(text: '1');
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _syncControllers(PostProvider provider) {
    final p = provider.post;
    if (p != null) {
      if (_titleController.text != p.title) _titleController.text = p.title;
      if (_bodyController.text != p.body) _bodyController.text = p.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostProvider>();
    final isLoading = provider.isLoading;
    final hasPost = provider.post != null;

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncControllers(provider));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo 1 · Conectividad REST'),
        backgroundColor: const Color(0xFF1A4D8F),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoBanner(
                  title: 'JSONPlaceholder · /posts/{id}',
                  subtitle:
                      'Fake API REST consumida con http. GET y PUT asíncronos.',
                ),
                const SizedBox(height: 16),
                _IdInputField(
                  controller: _idController,
                  enabled: !isLoading,
                  onFetch: () {
                    final id = int.tryParse(_idController.text.trim());
                    if (id == null) {
                      _showSnack('Ingrese un ID numérico válido (1-100).');
                      return;
                    }
                    provider.fetchPost(id);
                  },
                ),
                const SizedBox(height: 16),
                _StatusChip(
                  state: provider.state,
                  statusCode: provider.lastStatusCode,
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (hasPost)
                  _PostEditor(
                    idController: _idController,
                    titleController: _titleController,
                    bodyController: _bodyController,
                    enabled: !isLoading,
                    onUpdate: () {
                      final id = int.tryParse(_idController.text.trim()) ?? 0;
                      provider.updatePost(
                        id: id,
                        title: _titleController.text.trim(),
                        body: _bodyController.text.trim(),
                      );
                    },
                  )
                else
                  const _EmptyState(),
                const SizedBox(height: 32),
                _LegendCard(),
              ],
            ),
          ),
          if (isLoading)
            const _LoadingOverlay(
              message: 'Petición HTTP en tránsito...',
            ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const _InfoBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4D8F).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1A4D8F).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.http, color: Color(0xFF1A4D8F)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1A4D8F))),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onFetch;
  const _IdInputField({
    required this.controller,
    required this.enabled,
    required this.onFetch,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.tag, color: Color(0xFF1A4D8F)),
            const SizedBox(width: 8),
            const Text('ID del post:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '1-100',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: enabled ? onFetch : null,
              icon: const Icon(Icons.search),
              label: const Text('GET'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final PostUiState state;
  final int? statusCode;
  const _StatusChip({required this.state, this.statusCode});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;
    switch (state) {
      case PostUiState.idle:
        color = Colors.grey;
        label = 'Esperando acción del usuario';
        icon = Icons.hourglass_empty;
        break;
      case PostUiState.loading:
        color = Colors.orange;
        label = 'Cargando...';
        icon = Icons.cloud_sync;
        break;
      case PostUiState.success:
        color = Colors.green;
        label = statusCode == 200
            ? '200 OK · Operación exitosa'
            : 'OK · Status $statusCode';
        icon = Icons.check_circle;
        break;
      case PostUiState.error:
        color = Colors.red;
        label = 'Error en la petición';
        icon = Icons.error;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PostEditor extends StatelessWidget {
  final TextEditingController idController;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final bool enabled;
  final VoidCallback onUpdate;

  const _PostEditor({
    required this.idController,
    required this.titleController,
    required this.bodyController,
    required this.enabled,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Editar publicación (PUT)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              enabled: enabled,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyController,
              enabled: enabled,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Cuerpo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: enabled ? onUpdate : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4D8F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.save),
                label: const Text('PUT · Enviar actualización'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: const [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.black26),
            SizedBox(height: 8),
            Text(
              'Aún no se ha cargado ningún post.\nIngrese un ID y presione GET.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  final String message;
  const _LoadingOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          color: Colors.black.withValues(alpha: 0.25),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(message,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.amber),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Mientras la petición esté en tránsito, los campos y botones se '
                'deshabilitan automáticamente. Solo se confirma el éxito con el '
                'status HTTP 200 OK del servidor.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
