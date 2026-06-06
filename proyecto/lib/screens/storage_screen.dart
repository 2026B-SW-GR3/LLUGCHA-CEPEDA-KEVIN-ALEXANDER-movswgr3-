import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/storage_provider.dart';
import '../services/storage_service.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  StorageMechanism _selectedMechanism = StorageMechanism.encryptedShared;

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StorageProvider>();
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo 3 · Almacenamiento Seguro'),
        backgroundColor: const Color(0xFF2A9D8F),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _InfoBanner(),
                const SizedBox(height: 16),
                _MechanismSelector(
                  value: _selectedMechanism,
                  enabled: !isLoading,
                  onChanged: (v) => setState(() => _selectedMechanism = v),
                ),
                const SizedBox(height: 16),
                _SaveCard(
                  keyController: _keyController,
                  valueController: _valueController,
                  enabled: !isLoading,
                  onSave: () {
                    provider.save(
                      mechanism: _selectedMechanism,
                      key: _keyController.text,
                      value: _valueController.text,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _RetrieveCard(
                  keyController: _keyController,
                  enabled: !isLoading,
                  onRetrieve: () {
                    provider.retrieve(
                      mechanism: _selectedMechanism,
                      key: _keyController.text,
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (provider.feedbackMessage != null)
                  _FeedbackCard(
                    state: provider.state,
                    message: provider.feedbackMessage!,
                    revealedValue: provider.lastRetrievedValue,
                  ),
                const SizedBox(height: 20),
                const _ComparisonTable(),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Accediendo al almacenamiento seguro...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A9D8F).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A9D8F).withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield, color: Color(0xFF2A9D8F)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta pantalla es transaccional: guarda y recupera un secreto por '
              'vez. No se listan llaves en pantalla por seguridad. Si la clave '
              'no existe, se muestra un mensaje genérico.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _MechanismSelector extends StatelessWidget {
  final StorageMechanism value;
  final bool enabled;
  final ValueChanged<StorageMechanism> onChanged;
  const _MechanismSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mecanismo de almacenamiento',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<StorageMechanism>(
              initialValue: value,
              isExpanded: true,
              onChanged: enabled
                  ? (v) {
                      if (v != null) onChanged(v);
                    }
                  : null,
              items: StorageMechanism.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.displayName,
                          overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Android nativo', value.androidEquivalent),
                  _kv('Paquete Flutter', value.flutterPackage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(k,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Text(v,
                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
            ),
          ],
        ),
      );
}

class _SaveCard extends StatelessWidget {
  final TextEditingController keyController;
  final TextEditingController valueController;
  final bool enabled;
  final VoidCallback onSave;
  const _SaveCard({
    required this.keyController,
    required this.valueController,
    required this.enabled,
    required this.onSave,
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
            const Row(
              children: [
                Icon(Icons.save_outlined, color: Color(0xFF2A9D8F)),
                SizedBox(width: 8),
                Text('Acción · Guardar secreto',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              enabled: enabled,
              decoration: const InputDecoration(
                labelText: 'Llave',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: valueController,
              enabled: enabled,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Valor (token JWT, credencial, etc.)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: enabled ? onSave : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2A9D8F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.save),
                label: const Text('Guardar en el compartimento elegido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RetrieveCard extends StatelessWidget {
  final TextEditingController keyController;
  final bool enabled;
  final VoidCallback onRetrieve;
  const _RetrieveCard({
    required this.keyController,
    required this.enabled,
    required this.onRetrieve,
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
            const Row(
              children: [
                Icon(Icons.search, color: Color(0xFF2A9D8F)),
                SizedBox(width: 8),
                Text('Acción · Recuperar secreto',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Ingrese la llave y presione recuperar. Si el secreto no existe, '
              'se mostrará una notificación genérica (sin pistas del error).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: enabled ? onRetrieve : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF2A9D8F), width: 1.5),
                  foregroundColor: const Color(0xFF2A9D8F),
                ),
                icon: const Icon(Icons.lock_open),
                label: const Text('Recuperar del compartimento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final StorageUiState state;
  final String message;
  final String? revealedValue;
  const _FeedbackCard({
    required this.state,
    required this.message,
    this.revealedValue,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (state) {
      case StorageUiState.success:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case StorageUiState.notFound:
        color = Colors.orange;
        icon = Icons.help_outline;
        break;
      case StorageUiState.error:
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.blueGrey;
        icon = Icons.info_outline;
    }
    return Card(
      color: color.withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (revealedValue != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: SelectableText(
                  revealedValue!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Mapeo Android nativo ↔ Flutter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 8),
            _Row(
                android: 'SharedPreferences',
                flutter: 'shared_preferences',
                purpose: 'Texto plano (UI/temas)'),
            _Row(
                android: 'Jetpack DataStore',
                flutter: 'rx_shared_preferences (Streams)',
                purpose: 'Reactivo, no bloquea el hilo UI'),
            _Row(
                android: 'EncryptedSharedPreferences',
                flutter: 'flutter_secure_storage',
                purpose: 'AES-256 con Android Keystore'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String android;
  final String flutter;
  final String purpose;
  const _Row(
      {required this.android,
      required this.flutter,
      required this.purpose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(android,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.arrow_forward, size: 14, color: Colors.black45),
          const SizedBox(width: 4),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(flutter,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF2A9D8F))),
                Text(purpose,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
