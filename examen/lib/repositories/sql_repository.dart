import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/dog_breed.dart';
import '../utils/logger.dart';
import 'local_repository.dart';

/// Implementación Relacional (SQL) del [LocalRepository] usando `sqflite`.
///
/// Esquema de la tabla `dog_breeds`:
///   id              INTEGER PRIMARY KEY AUTOINCREMENT
///   name            TEXT    NOT NULL
///   origin          TEXT    NOT NULL
///   size            TEXT    NOT NULL
///   lifeExpectancy  INTEGER NOT NULL
///   description     TEXT    NOT NULL
class SqlRepository implements LocalRepository {
  SqlRepository({DatabaseFactory? factory, String? dbPath})
      : _factory = factory,
        _dbPath = dbPath ?? 'dog_breeds.db';

  static const String _table = 'dog_breeds';
  static const int _dbVersion = 1;

  final DatabaseFactory? _factory;
  final String _dbPath;
  Database? _db;

  @override
  String get sourceName => 'SQLite (SQL)';

  Future<Database> _open() async {
    if (_db != null) return _db!;

    final factory = _factory ?? databaseFactory;
    final path = p.join(await factory.getDatabasesPath(), _dbPath);

    Log.d('SqlRepository', 'Abriendo base de datos en $path');
    _db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: (db, version) async {
          Log.i('SqlRepository', 'Creando tabla $_table (v$version)');
          await db.execute('''
            CREATE TABLE $_table (
              id              INTEGER PRIMARY KEY AUTOINCREMENT,
              name            TEXT    NOT NULL,
              origin          TEXT    NOT NULL,
              size            TEXT    NOT NULL,
              lifeExpectancy  INTEGER NOT NULL,
              description     TEXT    NOT NULL
            )
          ''');
        },
      ),
    );
    return _db!;
  }

  @override
  Future<void> init() async {
    try {
      await _open();
      Log.i('SqlRepository', 'init() completado');
    } catch (e, st) {
      Log.e('SqlRepository', 'Error en init()', e, st);
      rethrow;
    }
  }

  @override
  Future<List<DogBreed>> getAll() async {
    try {
      final db = await _open();
      final rows = await db.query(_table, orderBy: 'id ASC');
      Log.d('SqlRepository', 'getAll() -> ${rows.length} registros');
      return rows.map(DogBreed.fromMap).toList();
    } catch (e, st) {
      Log.e('SqlRepository', 'Error en getAll()', e, st);
      rethrow;
    }
  }

  @override
  Future<DogBreed> insert(DogBreed breed) async {
    try {
      final db = await _open();
      final values = Map<String, Object?>.from(breed.toMap())..remove('id');
      final id = await db.insert(_table, values);
      Log.i('SqlRepository', 'Insertado registro id=$id -> $breed');
      return breed.copyWith(id: id);
    } catch (e, st) {
      Log.e('SqlRepository', 'Error en insert()', e, st);
      rethrow;
    }
  }

  @override
  Future<int> update(DogBreed breed) async {
    if (breed.id == null) {
      throw ArgumentError('No se puede actualizar sin id');
    }
    try {
      final db = await _open();
      final affected = await db.update(
        _table,
        breed.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [breed.id],
      );
      Log.i('SqlRepository',
          'Actualizado id=${breed.id} (filas afectadas=$affected)');
      return affected;
    } catch (e, st) {
      Log.e('SqlRepository', 'Error en update()', e, st);
      rethrow;
    }
  }

  @override
  Future<int> delete(int id) async {
    try {
      final db = await _open();
      final affected =
          await db.delete(_table, where: 'id = ?', whereArgs: [id]);
      Log.i('SqlRepository', 'Eliminado id=$id (filas afectadas=$affected)');
      return affected;
    } catch (e, st) {
      Log.e('SqlRepository', 'Error en delete()', e, st);
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      final db = await _open();
      await db.delete(_table);
      Log.i('SqlRepository', 'Tabla $_table vaciada');
    } catch (e, st) {
      Log.e('SqlRepository', 'Error en clear()', e, st);
      rethrow;
    }
  }

  /// Cierra la conexión. Útil en pruebas.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
