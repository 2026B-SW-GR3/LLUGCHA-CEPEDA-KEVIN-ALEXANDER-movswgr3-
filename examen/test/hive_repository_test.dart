import 'dart:io';

import 'package:examen/models/dog_breed.dart';
import 'package:examen/repositories/hive_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('HiveRepository (NoSQL)', () {
    late Directory tempDir;
    late Box<Map> box;
    late HiveRepository repo;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_repo_test_');
      Hive.init(tempDir.path);
      box = await Hive.openBox<Map>('dog_breeds_box_test_${DateTime.now().microsecondsSinceEpoch}');
      repo = HiveRepository(box: box);
      await repo.init();
    });

    tearDown(() async {
      await repo.close();
      await box.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('insert asigna un id autogenerado y persiste el documento',
        () async {
      final inserted = await repo.insert(const DogBreed(
        name: 'Husky Siberiano',
        origin: 'Rusia',
        size: 'Grande',
        lifeExpectancy: 12,
        description: 'Pelaje denso, gran resistencia.',
      ));
      expect(inserted.id, isNotNull);

      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.name, 'Husky Siberiano');
      expect(all.first.id, inserted.id);
    });

    test('getAll ordena por id ascendente', () async {
      await repo.insert(const DogBreed(
        name: 'Dálmata',
        origin: 'Croacia',
        size: 'Grande',
        lifeExpectancy: 12,
        description: 'Manchas características.',
      ));
      await repo.insert(const DogBreed(
        name: 'Yorkshire Terrier',
        origin: 'Inglaterra',
        size: 'Pequeño',
        lifeExpectancy: 14,
        description: 'Pelo largo y fino.',
      ));

      final all = await repo.getAll();
      expect(all.length, 2);
      expect(all.first.name, 'Dálmata');
      expect(all.last.name, 'Yorkshire Terrier');
    });

    test('update modifica el documento existente', () async {
      final inserted = await repo.insert(const DogBreed(
        name: 'Golden Retriever',
        origin: 'Escocia',
        size: 'Grande',
        lifeExpectancy: 11,
        description: 'Muy cariñoso.',
      ));

      final affected = await repo.update(inserted.copyWith(
        description: 'Muy cariñoso y juguetón.',
      ));
      expect(affected, 1);

      final all = await repo.getAll();
      expect(all.single.description, 'Muy cariñoso y juguetón.');
    });

    test('delete elimina el documento por id', () async {
      final inserted = await repo.insert(const DogBreed(
        name: 'Shiba Inu',
        origin: 'Japón',
        size: 'Mediano',
        lifeExpectancy: 14,
        description: 'Independiente y leal.',
      ));
      final affected = await repo.delete(inserted.id!);
      expect(affected, 1);
      expect(await repo.getAll(), isEmpty);
    });
  });
}
