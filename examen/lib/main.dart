import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/repository_provider.dart';
import 'repositories/hive_repository.dart';
import 'repositories/local_repository.dart';
import 'repositories/sql_repository.dart';
import 'screens/dog_breed_screen.dart';
import 'utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Log.i('main', 'Inicializando aplicación');

  await Hive.initFlutter();
  Log.i('main', 'Hive inicializado correctamente');

  final provider = RepositoryProvider(
    sqlRepo: SqlRepository(),
    nosqlRepo: HiveRepository(),
    initial: StorageType.sql,
  );
  await provider.bootstrap();

  runApp(DogBreedsApp(provider: provider));
}

class DogBreedsApp extends StatelessWidget {
  const DogBreedsApp({super.key, required this.provider});
  final RepositoryProvider provider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RepositoryProvider>.value(
      value: provider,
      child: MaterialApp(
        title: 'Razas de Perros - Persistencia Dual',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const DogBreedScreen(),
      ),
    );
  }
}
