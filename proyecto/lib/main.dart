import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/city_provider.dart';
import 'providers/post_provider.dart';
import 'providers/storage_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  runApp(MyApp(storageService: storageService));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  const MyApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(
          create: (_) => PostProvider(ApiService()),
        ),
        ChangeNotifierProvider(
          create: (_) => StorageProvider(storageService),
        ),
      ],
      child: MaterialApp(
        title: 'Red & Seguridad · FIS-EPN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A4D8F)),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
