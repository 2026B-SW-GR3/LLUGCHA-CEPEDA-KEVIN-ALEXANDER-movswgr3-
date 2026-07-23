import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FitMapApp());
}

class FitMapApp extends StatelessWidget {
  const FitMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMap - Quedadas Deportivas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
