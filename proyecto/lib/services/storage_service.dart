import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

/// Enum que mapea los 3 mecanismos nativos de Android exigidos:
///  - sharedPreferences -> Texto plano (UI/temas, NO datos críticos)
///  - dataStore          -> Reactivo, basado en Streams (DataStore / Jetpack)
///  - encryptedShared    -> Cifrado AES-256 usando Android Keystore
enum StorageMechanism {
  sharedPreferences,
  dataStore,
  encryptedShared,
}

extension StorageMechanismX on StorageMechanism {
  String get displayName {
    switch (this) {
      case StorageMechanism.sharedPreferences:
        return 'SharedPreferences (Texto plano)';
      case StorageMechanism.dataStore:
        return 'Jetpack DataStore (Reactivo / Streams)';
      case StorageMechanism.encryptedShared:
        return 'EncryptedShared (AES-256 / Keystore)';
    }
  }

  String get androidEquivalent {
    switch (this) {
      case StorageMechanism.sharedPreferences:
        return 'android.content.SharedPreferences';
      case StorageMechanism.dataStore:
        return 'androidx.datastore:datastore-preferences';
      case StorageMechanism.encryptedShared:
        return 'androidx.security:security-crypto';
    }
  }

  String get flutterPackage {
    switch (this) {
      case StorageMechanism.sharedPreferences:
        return 'shared_preferences';
      case StorageMechanism.dataStore:
        return 'rx_shared_preferences (Streams)';
      case StorageMechanism.encryptedShared:
        return 'flutter_secure_storage';
    }
  }
}

/// Servicio de almacenamiento que envuelve los 3 mecanismos.
///
/// `RxSharedPreferences` implementa la interfaz `SharedPreferencesLike`
/// (texto plano + reactivo con Streams). Se inicializa una sola vez y
/// sirve a los dos primeros mecanismos. El tercero usa
/// `flutter_secure_storage` con AES-256 + Android Keystore.
class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  late final RxSharedPreferences _rxPrefs;
  final StreamController<Map<String, String>> _dataStoreChanges =
      StreamController<Map<String, String>>.broadcast();

  /// Inicializa el subsistema. Llamar una sola vez al arrancar la app.
  Future<void> init() async {
    _rxPrefs = RxSharedPreferences.getInstance();
  }

  Stream<Map<String, String>> get dataStoreStream => _dataStoreChanges.stream;

  void dispose() {
    _dataStoreChanges.close();
  }

  // ================== SAVE ==================
  Future<void> save(
      StorageMechanism mechanism, String key, String value) async {
    switch (mechanism) {
      case StorageMechanism.sharedPreferences:
        // Escritura directa (no reactiva, no notifica listeners).
        await _rxPrefs.setString(key, value);
        break;
      case StorageMechanism.dataStore:
        await _rxPrefs.setString(key, value);
        // Emitir cambio en el stream para suscriptores reactivos.
        _dataStoreChanges.add({key: value});
        break;
      case StorageMechanism.encryptedShared:
        await _secureStorage.write(key: key, value: value);
        break;
    }
  }

  // ================== READ ==================
  /// Retorna null si la clave no existe (módulo pide mensaje genérico
  /// sin dar pistas del error en la UI).
  Future<String?> read(StorageMechanism mechanism, String key) async {
    switch (mechanism) {
      case StorageMechanism.sharedPreferences:
      case StorageMechanism.dataStore:
        return _rxPrefs.getString(key);
      case StorageMechanism.encryptedShared:
        return await _secureStorage.read(key: key);
    }
  }

  // ================== DELETE ==================
  Future<void> delete(StorageMechanism mechanism, String key) async {
    switch (mechanism) {
      case StorageMechanism.sharedPreferences:
        await _rxPrefs.remove(key);
        break;
      case StorageMechanism.dataStore:
        await _rxPrefs.remove(key);
        _dataStoreChanges.add({key: '<removed>'});
        break;
      case StorageMechanism.encryptedShared:
        await _secureStorage.delete(key: key);
        break;
    }
  }

  // ================== STREAM REACTIVO (DataStore) ==================
  /// Stream reactivo del DataStore equivalente. La UI puede suscribirse
  /// para mostrar cambios en vivo (cuando cambia el valor, el Stream emite).
  Stream<String?> watchDataStoreValue(String key) {
    return _rxPrefs.getStringStream(key);
  }
}
