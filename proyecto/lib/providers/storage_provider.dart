import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

enum StorageUiState { idle, loading, success, error, notFound }

/// Provider del Módulo 3: Almacenamiento Seguro.
class StorageProvider extends ChangeNotifier {
  final StorageService _service;

  StorageProvider(this._service);

  StorageUiState _state = StorageUiState.idle;
  StorageUiState get state => _state;

  String? _lastRetrievedValue;
  String? get lastRetrievedValue => _lastRetrievedValue;

  String? _feedbackMessage;
  String? get feedbackMessage => _feedbackMessage;

  bool get isLoading => _state == StorageUiState.loading;

  /// Guarda la clave/valor en el mecanismo elegido.
  Future<void> save({
    required StorageMechanism mechanism,
    required String key,
    required String value,
  }) async {
    if (key.trim().isEmpty || value.trim().isEmpty) {
      _feedbackMessage = 'Llave y valor son obligatorios.';
      _state = StorageUiState.error;
      notifyListeners();
      return;
    }

    _state = StorageUiState.loading;
    _feedbackMessage = null;
    notifyListeners();

    try {
      await _service.save(mechanism, key.trim(), value.trim());
      _feedbackMessage =
          'Secreto guardado de forma segura en ${mechanism.displayName}.';
      _state = StorageUiState.success;
    } catch (e) {
      _feedbackMessage = 'No se pudo completar la operación.';
      _state = StorageUiState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Recupera el secreto. Si no existe, retorna estado `notFound`
  /// con mensaje GENÉRICO (no revela detalles por seguridad).
  Future<void> retrieve({
    required StorageMechanism mechanism,
    required String key,
  }) async {
    if (key.trim().isEmpty) {
      _feedbackMessage = 'Ingrese una llave para recuperar el secreto.';
      _state = StorageUiState.error;
      notifyListeners();
      return;
    }

    _state = StorageUiState.loading;
    _feedbackMessage = null;
    _lastRetrievedValue = null;
    notifyListeners();

    try {
      final value = await _service.read(mechanism, key.trim());
      if (value == null || value.isEmpty) {
        _feedbackMessage = 'El secreto solicitado no existe o está inaccesible.';
        _lastRetrievedValue = null;
        _state = StorageUiState.notFound;
      } else {
        _lastRetrievedValue = value;
        _feedbackMessage =
            'Secreto recuperado desde ${mechanism.displayName}.';
        _state = StorageUiState.success;
      }
    } catch (e) {
      _feedbackMessage = 'No se pudo completar la operación.';
      _state = StorageUiState.error;
    } finally {
      notifyListeners();
    }
  }

  void clearFeedback() {
    _feedbackMessage = null;
    _lastRetrievedValue = null;
    _state = StorageUiState.idle;
    notifyListeners();
  }
}
