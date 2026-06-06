import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/api_service.dart';

/// Estados posibles de la pantalla de Posts.
enum PostUiState { idle, loading, success, error }

/// Provider responsable del Módulo 1: Conectividad REST.
/// Maneja la carga (loading), el estado visual y los datos de la API.
class PostProvider extends ChangeNotifier {
  final ApiService _api;

  PostProvider(this._api);

  PostUiState _state = PostUiState.idle;
  PostUiState get state => _state;

  Post? _post;
  Post? get post => _post;

  int? _lastStatusCode;
  int? get lastStatusCode => _lastStatusCode;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == PostUiState.loading;

  /// GET /posts/{id} - Deshabilita controles mientras carga.
  Future<void> fetchPost(int id) async {
    _state = PostUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.fetchPost(id);
      _post = result.post;
      _lastStatusCode = result.statusCode;
      _state = PostUiState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = PostUiState.error;
    } finally {
      notifyListeners();
    }
  }

  /// PUT /posts/{id} - Valida el status 200 OK antes de notificar éxito.
  Future<void> updatePost({
    required int id,
    required String title,
    required String body,
  }) async {
    if (_post == null) {
      _errorMessage = 'No hay un post cargado. Realice primero una consulta GET.';
      _state = PostUiState.error;
      notifyListeners();
      return;
    }

    _state = PostUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = _post!.copyWith(id: id, title: title, body: body);
      final result = await _api.updatePost(updated);

      if (result.statusCode == 200) {
        _post = result.post;
        _lastStatusCode = 200;
        _state = PostUiState.success;
      } else {
        _errorMessage = 'Status inesperado: ${result.statusCode}';
        _state = PostUiState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = PostUiState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _state = PostUiState.idle;
    _post = null;
    _lastStatusCode = null;
    _errorMessage = null;
    notifyListeners();
  }
}
