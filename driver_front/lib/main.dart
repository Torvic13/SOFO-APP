import 'package:flutter/material.dart';

import 'screens/driver_home_screen.dart';
import 'services/driver_api_service.dart';

void main() {
  runApp(const SofoDriverApp());
}

class SofoDriverApp extends StatelessWidget {
  const SofoDriverApp({super.key, this.gateway});

  final DriverTripGateway? gateway;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOFO Conductor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155EEF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: DriverHomeScreen(gateway: gateway),
    );
  }
}
