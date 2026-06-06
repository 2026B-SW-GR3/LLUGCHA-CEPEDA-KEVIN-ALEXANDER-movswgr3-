import 'dart:io';

import 'package:examen/models/dog_breed.dart';
import 'package:examen/repositories/sql_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('SqlRepository (sqflite)', () {
    late Directory tempDir;
    late SqlRepository repo;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('sql_repo_test_');
      repo = SqlRepository(
        factory: databaseFactoryFfi,
        dbPath: '${tempDir.path}/test.db',
      );
      await repo.init();
    });

    tearDown(() async {
      await repo.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('insert persiste y asigna un id incremental', () async {
      final first = await repo.insert(const DogBreed(
        name: 'Labrador Retriever',
        origin: 'Canadá',
        size: 'Grande',
        lifeExpectancy: 12,
        description: 'Perro amigable y muy activo.',
      ));
      final second = await repo.insert(const DogBreed(
        name: 'Chihuahua',
        origin: 'México',
        size: 'Pequeño',
        lifeExpectancy: 14,
        description: 'Pequeño pero con gran personalidad.',
      ));

      expect(first.id, isNotNull);
      expect(second.id, isNotNull);
      expect(second.id, greaterThan(first.id!));
    });

    test('getAll devuelve los registros insertados en orden', () async {
      await repo.insert(const DogBreed(
        name: 'Border Collie',
        origin: 'Reino Unido',
        size: 'Mediano',
        lifeExpectancy: 13,
        description: 'Pastoreo inteligente.',
      ));
      await repo.insert(const DogBreed(
        name: 'San Bernardo',
        origin: 'Suiza',
        size: 'Gigante',
        lifeExpectancy: 10,
        description: 'Rescate en nieve.',
      ));

      final all = await repo.getAll();
      expect(all.length, 2);
      expect(all.first.name, 'Border Collie');
      expect(all.last.name, 'San Bernardo');
    });

    test('update modifica un registro existente', () async {
      final inserted = await repo.insert(const DogBreed(
        name: 'Beagle',
        origin: 'Reino Unido',
        size: 'Mediano',
        lifeExpectancy: 12,
        description: 'Sabueso.',
      ));

      final affected = await repo.update(inserted.copyWith(
        name: 'Beagle (actualizado)',
        lifeExpectancy: 13,
      ));
      expect(affected, 1);

      final all = await repo.getAll();
      expect(all.single.name, 'Beagle (actualizado)');
      expect(all.single.lifeExpectancy, 13);
    });

    test('delete elimina por id', () async {
      final inserted = await repo.insert(const DogBreed(
        name: 'Pug',
        origin: 'China',
        size: 'Pequeño',
        lifeExpectancy: 13,
        description: 'Cara aplastada.',
      ));

      final affected = await repo.delete(inserted.id!);
      expect(affected, 1);
      expect(await repo.getAll(), isEmpty);
    });
  });
}
