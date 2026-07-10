import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SofoApp());
}

class SofoApp extends StatelessWidget {
  const SofoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOFO',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}