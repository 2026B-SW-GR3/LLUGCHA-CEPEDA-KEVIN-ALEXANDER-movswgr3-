# Red & Seguridad · FIS-EPN (Flutter)

Proyecto de la materia **Red y Seguridad** de la FIS-EPN. El enfoque es
**conectividad REST asíncrona** y **almacenamiento seguro simulado** mapeando
las APIs nativas de Android a sus equivalentes en Flutter, todo ambientado
en **ciudades del Ecuador**.

## Módulos cubiertos

| Módulo | Peso | Implementación |
|---|---|---|
| 1 · Conectividad REST | 30% | `lib/screens/posts_screen.dart` |
| 3 · Almacenamiento Seguro | 30% | `lib/screens/storage_screen.dart` |
| Gestión de Estado y Reactividad | 20% | `lib/providers/*` (Provider) |

## Arquitectura

```
lib/
├── main.dart                    # MultiProvider + rutas
├── models/
│   ├── post.dart                # Modelo del JSONPlaceholder
│   └── ciudad.dart              # 8 ciudades del Ecuador
├── services/
│   ├── api_service.dart         # GET / PUT con paquete http
│   └── storage_service.dart     # 3 mecanismos de almacenamiento
├── providers/                   # ChangeNotifier (Provider)
│   ├── post_provider.dart
│   ├── storage_provider.dart
│   └── city_provider.dart
└── screens/
    ├── home_screen.dart         # Selector de ciudad + módulos
    ├── posts_screen.dart        # Módulo 1
    └── storage_screen.dart      # Módulo 3
```

## Módulo 1 · Conectividad REST

- **GET** `/posts/{id}` con campo numérico (filtra `digitsOnly`).
- **PUT** `/posts/{id}` con el JSON del post editado.
- Se valida explícitamente el `statusCode == 200` antes de notificar éxito.
- **Loading states**: mientras la petición esté en tránsito se deshabilitan
  los campos de texto y los botones, y se muestra un `CircularProgressIndicator`
  sobre un `AbsorbPointer` (overlay que bloquea la UI).

## Módulo 3 · Almacenamiento Seguro

Mapeo **Android nativo ↔ Flutter**:

| Android nativo | Flutter | Uso |
|---|---|---|
| `SharedPreferences` | `shared_preferences` (vía `RxSharedPreferences`) | Texto plano (UI/temas) |
| `Jetpack DataStore` | `rx_shared_preferences` (Streams) | Reactivo, no bloquea el hilo UI |
| `EncryptedSharedPreferences` | `flutter_secure_storage` (AES-256) | Tokens JWT / credenciales |

La UI es **transaccional** (no lista llaves en pantalla):
- **Guardar**: campo Llave + campo Valor + `DropdownButtonFormField` para
  elegir el mecanismo → persiste.
- **Recuperar**: ingresa la Llave + selecciona el compartimento → si existe
  se revela; si no, **mensaje genérico** (no da pistas del error).

## Gestión de Estado y Reactividad

- `Provider` + `ChangeNotifier` con `notifyListeners()` en cada mutación.
- Las pantallas usan `context.watch<T>()` para reconstruirse ante cambios.
- El método `watchDataStoreValue(key)` expone el `Stream<String?>` del
  `rx_shared_preferences` para mostrar reactividad en vivo.

## Configuración

- `android/app/src/main/AndroidManifest.xml` → permiso `INTERNET`.
- `android/app/build.gradle.kts` → `minSdk = 23` (requerido por
  `flutter_secure_storage` para AES con Android Keystore).
- `pubspec.yaml`:
  - `http` (REST)
  - `provider` (estado)
  - `shared_preferences` + `rx_shared_preferences` (DataStore reactivo)
  - `flutter_secure_storage` (AES-256)
  - `intl` (formato de números `es_EC`)

## Ejecución

```bash
flutter pub get
flutter run            # Android / iOS / Web
flutter test           # Tests unitarios
flutter analyze        # Análisis estático
```
