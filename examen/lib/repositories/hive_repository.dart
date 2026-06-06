import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

import '../models/dog_breed.dart';
import '../utils/logger.dart';
import 'local_repository.dart';

/// Implementación No Relacional (NoSQL) del [LocalRepository] usando `hive`.
///
/// Cada registro se almacena como un `Map` dentro de un `Box`. Hive no exige
/// un esquema rígido, lo que permite guardar documentos dinámicos; aquí
/// mapeamos cada mapa a/desde [DogBreed] para mantener la abstracción.
///
/// La clave (`int`) que Hive asigna al insertar se reusa como `id` lógico
/// del modelo, de modo que `getAll()` puede reconstruir el identificador
/// aunque el documento almacenado no lo incluya.
class HiveRepository implements LocalRepository {
  HiveRepository({Box<Map>? box, this._boxName = 'dog_breeds_box'})
      : _injectedBox = box;

  final Box<Map>? _injectedBox;
  final String _boxName;
  Box<Map>? _box;
  static bool _hiveReady = false;

  @override
  String get sourceName => 'Hive (NoSQL)';

  Future<Box<Map>> _open() async {
    final injected = _injectedBox;
    if (injected != null) return injected;
    final current = _box;
    if (current != null) return current;

    // Resiliencia: si Hive aún no fue inicializado (p. ej. en pruebas
    // que instancian el repositorio sin un `setUp` que llame a
    // `Hive.init()`), usamos un directorio temporal como fallback y lo
    // dejamos registrado para esta y futuras cajas.
    if (!_hiveReady) {
      try {
        await Hive.openBox<Map>('__examen_sentinel__');
        await Hive.box<Map>('__examen_sentinel__').close();
        _hiveReady = true;
      } on HiveError {
        final fallback = p.join(Directory.systemTemp.path, 'examen_hive');
        Log.w(
          'HiveRepository',
          'Hive no estaba inicializado; usando fallback: $fallback',
        );
        Hive.init(fallback);
        _hiveReady = true;
      }
    }

    Box<Map> opened;
    if (!Hive.isBoxOpen(_boxName)) {
      opened = await Hive.openBox<Map>(_boxName);
    } else {
      opened = Hive.box<Map>(_boxName);
    }
    _box = opened;
    return opened;
  }

  @override
  Future<void> init() async {
    try {
      await _open();
      Log.i('HiveRepository', 'init() completado (box=$_boxName)');
    } catch (e, st) {
      Log.e('HiveRepository', 'Error en init()', e, st);
      rethrow;
    }
  }

  @override
  Future<List<DogBreed>> getAll() async {
    try {
      final box = await _open();
      final entries = box.toMap();
      final list = <DogBreed>[];
      entries.forEach((key, value) {
        final data = Map<String, Object?>.from(value);
        final breed = DogBreed.fromMap(data).copyWith(id: key as int);
        list.add(breed);
      });
      list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      Log.d('HiveRepository', 'getAll() -> ${list.length} registros');
      return list;
    } catch (e, st) {
      Log.e('HiveRepository', 'Error en getAll()', e, st);
      rethrow;
    }
  }

  @override
  Future<DogBreed> insert(DogBreed breed) async {
    try {
      final box = await _open();
      final key = await box.add(breed.toMap());
      Log.i(
        'HiveRepository',
        'Insertado registro key=$key -> $breed',
      );
      return breed.copyWith(id: key);
    } catch (e, st) {
      Log.e('HiveRepository', 'Error en insert()', e, st);
      rethrow;
    }
  }

  @override
  Future<int> update(DogBreed breed) async {
    if (breed.id == null) {
      throw ArgumentError('No se puede actualizar sin id');
    }
    try {
      final box = await _open();
      final key = breed.id!;
      final exists = box.containsKey(key);
      if (!exists) return 0;
      await box.put(key, breed.toMap());
      Log.i('HiveRepository', 'Actualizado id=${breed.id}');
      return 1;
    } catch (e, st) {
      Log.e('HiveRepository', 'Error en update()', e, st);
      rethrow;
    }
  }

  @override
  Future<int> delete(int id) async {
    try {
      final box = await _open();
      final existed = box.containsKey(id);
      await box.delete(id);
      Log.i(
        'HiveRepository',
        'Eliminado id=$id (eliminado=${existed ? 1 : 0})',
      );
      return existed ? 1 : 0;
    } catch (e, st) {
      Log.e('HiveRepository', 'Error en delete()', e, st);
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      final box = await _open();
      await box.clear();
      Log.i('HiveRepository', 'Box $_boxName vaciado');
    } catch (e, st) {
      Log.e('HiveRepository', 'Error en clear()', e, st);
      rethrow;
    }
  }

  /// Cierra el box. Útil en pruebas.
  Future<void> close() async {
    await _injectedBox?.close();
    await _box?.close();
    _box = null;
  }
}
