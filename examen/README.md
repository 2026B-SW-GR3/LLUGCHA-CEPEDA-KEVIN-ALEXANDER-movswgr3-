# Examen — Persistencia Dual (SQL ↔ NoSQL) — Razas de Perros

Aplicación Flutter (CRUD de **razas de perros**) que demuestra el patrón de
**Persistencia Híbrida**: la UI nunca sabe si los datos viven en SQLite o en
Hive; ambos motores se intercambian **en tiempo de ejecución** mediante un
`Switch` en la `AppBar`, gracias al **Patrón Repositorio** y a `Provider`.

---

## 1. Objetivo

Transformar un CRUD local clásico en un sistema capaz de alternar entre un
almacén **Relacional (SQL)** y otro **No Relacional (NoSQL)**, sin alterar la
interfaz gráfica ni la lógica de las vistas.

---

## 2. Stack tecnológico

| Capa              | Paquete / API                  | Rol                                              |
| ----------------- | ------------------------------ | ------------------------------------------------ |
| Relacional (SQL)  | `sqflite` + `sqflite_common_ffi` | Persistencia con esquema, tipos y PK             |
| No relacional     | `hive` + `hive_flutter`        | Persistencia con `Box<Map>` (documentos)         |
| Estado / React.   | `provider` (`ChangeNotifier`)  | Conmutación de motor + refresco de la lista      |
| Logging           | `dart:developer` + `print`     | Trazas `[DEBUG]`, `[INFO]`, `[ERROR]`            |
| Pruebas           | `flutter_test`                 | Tests unitarios de repositorios y conmutación    |

Dependencias declaradas en [`pubspec.yaml`](pubspec.yaml).

---

## 3. Estructura del proyecto

```
lib/
├── main.dart                                  # Bootstrap + Provider raíz
├── models/
│   └── dog_breed.dart                         # Modelo de dominio
├── repositories/
│   ├── local_repository.dart                  # Interfaz abstracta + enum StorageType
│   ├── sql_repository.dart                    # Implementación sqflite
│   └── hive_repository.dart                   # Implementación Hive
├── providers/
│   └── repository_provider.dart               # ChangeNotifier (orquestador)
├── screens/
│   └── dog_breed_screen.dart                  # UI: AppBar con Switch + Chip + lista
├── widgets/
│   ├── source_indicator.dart                  # Chip "Origen: SQLite/Hive"
│   └── dog_breed_form.dart                    # Diálogo crear/editar
└── utils/
    └── logger.dart                            # Log.d / Log.i / Log.e

test/
├── sql_repository_test.dart                   # 4 tests del repo SQL
├── hive_repository_test.dart                  # 4 tests del repo NoSQL
└── repository_switch_test.dart                # 4 tests de aislamiento entre motores
```

---

## 4. Patrón Repositorio (aislamiento de la UI)

La interfaz [`LocalRepository`](lib/repositories/local_repository.dart) es el
único contrato que la vista conoce:

```dart
abstract class LocalRepository {
  String get sourceName;
  Future<void> init();
  Future<List<DogBreed>> getAll();
  Future<DogBreed> insert(DogBreed breed);
  Future<int> update(DogBreed breed);
  Future<int> delete(int id);
  Future<void> clear();
}
```

- `SqlRepository` (lib/repositories/sql_repository.dart) implementa la
  persistencia **relacional** con una tabla `dog_breeds` de esquema estricto
  (`id INTEGER PRIMARY KEY AUTOINCREMENT`, `name TEXT NOT NULL`, etc.).
- `HiveRepository` (lib/repositories/hive_repository.dart) implementa la
  persistencia **NoSQL** con un `Box<Map>` y la clave del box como `id`.

Las vistas (`DogBreedScreen`, `DogBreedForm`) **nunca importan** `sqflite` ni
`hive`: solo consumen `RepositoryProvider`.

---

## 5. Reactividad con Provider

`RepositoryProvider` (lib/providers/repository_provider.dart) mantiene:

- `active: StorageType` — motor actual (`sql` o `nosql`).
- `currentRepository` — el `LocalRepository` seleccionado.
- `breeds: List<DogBreed>` — lista visible, refrescada al conmutar.
- `addBreed`, `updateBreed`, `deleteBreed` — operaciones CRUD que siempre
  actúan sobre el motor activo.

Al llamar a `switchTo(StorageType.nosql)`:

1. Se registra el cambio con `Log.i`.
2. Se notifica a los `Consumer<RepositoryProvider>`.
3. Se relee la lista desde el nuevo origen y se vuelve a notificar.

---

## 6. UI

`DogBreedScreen` (lib/screens/dog_breed_screen.dart) implementa los 3
requisitos de interfaz:

| Requisito                                  | Implementación                                                   |
| ------------------------------------------ | ---------------------------------------------------------------- |
| **Switch / Toggle en la AppBar**           | `_SourceSwitcher` con etiquetas `SQL` ↔ `NoSQL`                  |
| **Reactividad instantánea**                | `provider.switchTo(...)` → `notifyListeners()` + `_refresh()`    |
| **Indicador de origen activo (Chip)**      | `SourceIndicator` con color indigo (SQL) o naranja (NoSQL)       |

Otras piezas:

- `FloatingActionButton.extended` → abre `DogBreedForm` para crear.
- Cada `ListTile` expone acciones `Editar` y `Eliminar` con confirmación.
- Estados especiales: `CircularProgressIndicator` mientras carga, vista de
  error si la lectura falla, vista vacía con icono `pets` si no hay datos.

---

## 7. Logs estructurados

`Log` (lib/utils/logger.dart) ofrece tres niveles con prefijos legibles:

```
[DEBUG] SqlRepository -> getAll() -> 3 registros
[INFO]  RepositoryProvider -> Cambio de motor: SQLite -> Hive
[ERROR] HiveRepository -> Error en delete() (con stack trace)
```

Cada cambio de motor y cada `insert/update/delete` se traza, lo que facilita
depurar comportamientos entre almacenes.

---

## 8. Pruebas unitarias

```bash
flutter test
```

Resultado actual: **12/12 tests OK** (3 archivos).

### Cobertura

- `test/sql_repository_test.dart` — `SqlRepository` con `sqflite_common_ffi`
  en directorio temporal: `insert`, `getAll` ordenado, `update`, `delete`.
- `test/hive_repository_test.dart` — `HiveRepository` con `Box<Map>` en
  directorio temporal: id autogenerado, orden por id, `update`, `delete`.
- `test/repository_switch_test.dart` — pruebas de **conmutación** que
  verifican que ambos almacenes **no mezclan ni corrompen** datos:
  - Arranque en SQL expone `SQLite` como origen.
  - Insertar en SQL y en NoSQL mantiene los datos **aislados** al alternar
    motores.
  - `switchTo` al motor activo no recarga innecesariamente.
  - `delete` afecta únicamente al motor activo.

---

## 9. Ejecución

```bash
flutter pub get
flutter test       # Ejecuta las pruebas unitarias
flutter run        # Lanza la app (Android/iOS/Web/Desktop)
```

> En Windows/Linux/macOS las pruebas usan `sqflite_common_ffi` para
> instanciar SQLite en memoria. En la app móvil real se usa el motor
> nativo vía `sqflite` estándar.

---

## 10. Modelo `DogBreed`

```dart
class DogBreed {
  final int? id;              // null al crear; lo asigna el motor
  final String name;          // "Labrador Retriever"
  final String origin;        // "Canadá"
  final String size;          // Pequeño | Mediano | Grande | Gigante
  final int lifeExpectancy;   // años
  final String description;
}
```

`toMap()` / `fromMap()` son el puente único hacia ambos motores: SQL lo
utiliza para `INSERT`/`SELECT` con tipos estrictos, y Hive lo serializa
dentro de su `Box<Map>`.
