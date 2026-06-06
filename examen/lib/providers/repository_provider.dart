import 'package:flutter/foundation.dart';

import '../models/dog_breed.dart';
import '../repositories/hive_repository.dart';
import '../repositories/local_repository.dart';
import '../repositories/sql_repository.dart';
import '../utils/logger.dart';

/// `ChangeNotifier` que encapsula el motor de persistencia activo y la lista
/// de razas de perros que se muestra en la UI.
///
/// La vista consume este provider con `context.watch<RepositoryProvider>()`
/// y/o `context.read<RepositoryProvider>()` para alternar entre motores
/// sin acoplarse a `sqflite` ni a `hive`.
class RepositoryProvider extends ChangeNotifier {
  RepositoryProvider({
    required this.sqlRepo,
    required this.nosqlRepo,
    StorageType initial = StorageType.sql,
  }) : _active = initial;

  final SqlRepository sqlRepo;
  final HiveRepository nosqlRepo;
  StorageType _active;
  bool _isLoading = false;
  String? _errorMessage;

  List<DogBreed> _breeds = const <DogBreed>[];
  List<DogBreed> get breeds => List.unmodifiable(_breeds);

  StorageType get active => _active;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LocalRepository get currentRepository =>
      _active == StorageType.sql ? sqlRepo : nosqlRepo;

  String get activeSourceLabel => currentRepository.sourceName;

  /// Inicializa ambos motores una sola vez.
  Future<void> bootstrap() async {
    Log.i('RepositoryProvider', 'bootstrap() inicializando motores');
    await sqlRepo.init();
    await nosqlRepo.init();
    await _refresh();
  }

  /// Conmuta el motor activo y recarga los datos desde el nuevo origen.
  Future<void> switchTo(StorageType type) async {
    if (type == _active) return;
    final previous = _active;
    _active = type;
    Log.i(
      'RepositoryProvider',
      'Cambio de motor: '
      '${previous == StorageType.sql ? "SQLite" : "Hive"} -> '
      '${type == StorageType.sql ? "SQLite" : "Hive"}',
    );
    notifyListeners();
    await _refresh();
  }

  Future<void> _refresh() async {
    _setLoading(true);
    try {
      _breeds = await currentRepository.getAll();
      _errorMessage = null;
      Log.d(
        'RepositoryProvider',
        'Lista refrescada desde ${currentRepository.sourceName}: '
        '${_breeds.length} elementos',
      );
    } catch (e, st) {
      Log.e('RepositoryProvider', 'Error refrescando datos', e, st);
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addBreed(DogBreed breed) async {
    await currentRepository.insert(breed);
    await _refresh();
  }

  Future<void> updateBreed(DogBreed breed) async {
    await currentRepository.update(breed);
    await _refresh();
  }

  Future<void> deleteBreed(int id) async {
    await currentRepository.delete(id);
    await _refresh();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
