import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto/models/post.dart';
import 'package:proyecto/models/ciudad.dart';
import 'package:proyecto/services/storage_service.dart';

void main() {
  group('Post model', () {
    test('fromJson / toJson', () {
      final post = Post.fromJson({
        'id': 1,
        'userId': 10,
        'title': 'Hola',
        'body': 'Mundo',
      });
      expect(post.id, 1);
      expect(post.userId, 10);
      expect(post.title, 'Hola');
      expect(post.body, 'Mundo');
      expect(post.toJson()['title'], 'Hola');
    });

    test('copyWith modifica solo los campos indicados', () {
      final original = Post(id: 1, userId: 1, title: 'A', body: 'B');
      final copia = original.copyWith(title: 'Nuevo');
      expect(copia.title, 'Nuevo');
      expect(copia.body, 'B');
    });
  });

  group('StorageMechanism', () {
    test('displayName, androidEquivalent y flutterPackage definidos', () {
      for (final m in StorageMechanism.values) {
        expect(m.displayName, isNotEmpty);
        expect(m.androidEquivalent, isNotEmpty);
        expect(m.flutterPackage, isNotEmpty);
      }
    });
  });

  group('Ciudades del Ecuador', () {
    test('La lista contiene Quito y Guayaquil', () {
      final nombres = CiudadesEcuadorData.ciudades.map((c) => c.nombre).toList();
      expect(nombres, contains('Quito'));
      expect(nombres, contains('Guayaquil'));
    });
  });
}
