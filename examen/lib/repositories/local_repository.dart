import '../models/dog_breed.dart';

/// Tipo de motor de persistencia activo.
enum StorageType { sql, nosql }

/// Interfaz común que cualquier motor de persistencia local debe implementar.
///
/// Gracias a esta abstracción, la UI nunca depende directamente de
/// `sqflite` ni de `hive`. Para alternar entre motores solo es necesario
/// inyectar una implementación distinta desde la capa de Provider.
abstract class LocalRepository {
  /// Identificador legible del motor (ej. "SQLite" o "Hive/NoSQL").
  String get sourceName;

  /// Inicializa el almacén. Debe invocarse una sola vez al arrancar la app
  /// (apertura de base de datos, registro de adaptadores, etc.).
  Future<void> init();

  /// Devuelve todas las razas de perros almacenadas.
  Future<List<DogBreed>> getAll();

  /// Inserta una nueva raza y devuelve el registro persistido (con `id`).
  Future<DogBreed> insert(DogBreed breed);

  /// Actualiza una raza existente a partir de su `id`.
  Future<int> update(DogBreed breed);

  /// Elimina una raza por su `id`. Devuelve el número de filas afectadas.
  Future<int> delete(int id);

  /// Elimina todos los registros. Útil para pruebas y reinicios.
  Future<void> clear();
}
