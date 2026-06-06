import 'package:flutter/material.dart';

import '../models/dog_breed.dart';

/// Diálogo modal para crear o editar una [DogBreed]. Devuelve la raza
/// construida si el usuario confirma, o `null` si cancela.
class DogBreedForm extends StatefulWidget {
  const DogBreedForm({super.key, this.initial});

  final DogBreed? initial;

  @override
  State<DogBreedForm> createState() => _DogBreedFormState();
}

class _DogBreedFormState extends State<DogBreedForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _origin;
  late final TextEditingController _life;
  late final TextEditingController _description;
  late String _size;

  static const _sizes = <String>['Pequeño', 'Mediano', 'Grande', 'Gigante'];

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i?.name ?? '');
    _origin = TextEditingController(text: i?.origin ?? '');
    _life = TextEditingController(
      text: i?.lifeExpectancy != null ? '${i!.lifeExpectancy}' : '',
    );
    _description = TextEditingController(text: i?.description ?? '');
    _size = i?.size ?? _sizes.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _origin.dispose();
    _life.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final result = DogBreed(
      id: widget.initial?.id,
      name: _name.text.trim(),
      origin: _origin.text.trim(),
      size: _size,
      lifeExpectancy: int.parse(_life.text.trim()),
      description: _description.text.trim(),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return AlertDialog(
      title: Text(isEdit ? 'Editar raza' : 'Nueva raza'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _origin,
                decoration: const InputDecoration(labelText: 'Origen *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _size,
                decoration: const InputDecoration(labelText: 'Tamaño'),
                items: _sizes
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _size = v ?? _sizes.first),
              ),
              TextFormField(
                controller: _life,
                decoration: const InputDecoration(
                  labelText: 'Esperanza de vida (años) *',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Número positivo';
                  return null;
                },
              ),
              TextFormField(
                controller: _description,
                decoration:
                    const InputDecoration(labelText: 'Descripción *'),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
