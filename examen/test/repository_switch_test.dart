import 'dart:io';

import 'package:examen/models/dog_breed.dart';
import 'package:examen/providers/repository_provider.dart';
import 'package:examen/repositories/hive_repository.dart';
import 'package:examen/repositories/local_repository.dart';
import 'package:examen/repositories/sql_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('RepositoryProvider (conmutación de motores)', () {
    late Directory tempDir;
    late Box<Map> hiveBox;
    late SqlRepository sqlRepo;
    late HiveRepository hiveRepo;
    late RepositoryProvider provider;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('switch_test_');
      Hive.init(tempDir.path);

      sqlRepo = SqlRepository(
        factory: databaseFactoryFfi,
        dbPath: '${tempDir.path}/switch.db',
      );
      hiveBox = await Hive.openBox<Map>(
        'switch_box_${DateTime.now().microsecondsSinceEpoch}',
      );
      hiveRepo = HiveRepository(box: hiveBox);

      provider = RepositoryProvider(
        sqlRepo: sqlRepo,
        nosqlRepo: hiveRepo,
        initial: StorageType.sql,
      );
      await provider.bootstrap();
    });

    tearDown(() async {
      await provider.sqlRepo.close();
      await hiveRepo.close();
      await hiveBox.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('arranca en SQL y lee del motor relacional', () {
      expect(provider.active, StorageType.sql);
      expect(provider.currentRepository, sqlRepo);
      expect(provider.activeSourceLabel, contains('SQLite'));
    });

    test(
        'los datos de SQL y NoSQL se mantienen aislados al conmutar motores',
        () async {
      // Solo SQL contiene "Pastor Alemán"
      await provider.addBreed(const DogBreed(
        name: 'Pastor Alemán',
        origin: 'Alemania',
        size: 'Grande',
        lifeExpectancy: 11,
        description: 'Perro de trabajo.',
      ));

      // Conmutamos a NoSQL y agregamos un registro distinto.
      await provider.switchTo(StorageType.nosql);
      expect(provider.active, StorageType.nosql);
      expect(provider.activeSourceLabel, contains('Hive'));

      await provider.addBreed(const DogBreed(
        name: 'Poodle',
        origin: 'Francia',
        size: 'Mediano',
        lifeExpectancy: 14,
        description: 'Pelo rizado.',
      ));

      // El motor NoSQL no debe contener el registro del motor SQL.
      expect(provider.breeds.length, 1);
      expect(provider.breeds.single.name, 'Poodle');

      // Volvemos a SQL: debe seguir mostrando solo el registro original.
      await provider.switchTo(StorageType.sql);
      expect(provider.breeds.length, 1);
      expect(provider.breeds.single.name, 'Pastor Alemán');

      // Una segunda vuelta a NoSQL: el Poodle sigue ahí, sin mezclarse.
      await provider.switchTo(StorageType.nosql);
      expect(provider.breeds.length, 1);
      expect(provider.breeds.single.name, 'Poodle');
    });

    test('switchTo hacia el motor actual no recarga innecesariamente',
        () async {
      await provider.addBreed(const DogBreed(
        name: 'Rottweiler',
        origin: 'Alemania',
        size: 'Grande',
        lifeExpectancy: 10,
        description: 'Guardián.',
      ));
      final firstSnapshot = provider.breeds;

      // Llamar switchTo al motor activo no debe lanzar excepciones ni
      // perder los datos ya cargados.
      await provider.switchTo(StorageType.sql);
      expect(provider.breeds, firstSnapshot);
    });

    test('delete afecta únicamente al motor activo', () async {
      // SQL: Pastor Alemán
      await provider.addBreed(const DogBreed(
        name: 'Pastor Alemán',
        origin: 'Alemania',
        size: 'Grande',
        lifeExpectancy: 11,
        description: 'Perro de trabajo.',
      ));
      // NoSQL: Poodle
      await provider.switchTo(StorageType.nosql);
      await provider.addBreed(const DogBreed(
        name: 'Poodle',
        origin: 'Francia',
        size: 'Mediano',
        lifeExpectancy: 14,
        description: 'Pelo rizado.',
      ));

      // Borramos el Poodle desde el motor NoSQL activo.
      final poodleId = provider.breeds.single.id!;
      await provider.deleteBreed(poodleId);
      expect(provider.breeds, isEmpty);

      // Al volver a SQL, el Pastor Alemán sigue intacto.
      await provider.switchTo(StorageType.sql);
      expect(provider.breeds.length, 1);
      expect(provider.breeds.single.name, 'Pastor Alemán');
    });
  });
}
