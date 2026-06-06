import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Petición GET a /posts/{id}
  /// Retorna el Post decodificado y el statusCode del servidor.
  Future<({Post post, int statusCode})> fetchPost(int id) async {
    final uri = Uri.parse('$_baseUrl/posts/$id');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return (post: Post.fromJson(json), statusCode: 200);
    } else {
      throw HttpException(
        'Error GET: ${response.statusCode} ${response.reasonPhrase}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Petición PUT a /posts/{id} con un JSON en el body.
  /// Retorna el Post actualizado por el servidor y el statusCode (200 OK).
  Future<({Post post, int statusCode})> updatePost(Post post) async {
    final uri = Uri.parse('$_baseUrl/posts/${post.id}');
    final response = await http
        .put(
          uri,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(post.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return (post: Post.fromJson(json), statusCode: 200);
    } else {
      throw HttpException(
        'Error PUT: ${response.statusCode} ${response.reasonPhrase}',
        statusCode: response.statusCode,
      );
    }
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  HttpException(this.message, {required this.statusCode});

  @override
  String toString() => message;
}
