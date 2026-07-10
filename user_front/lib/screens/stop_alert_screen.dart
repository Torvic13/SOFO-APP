import 'dart:async';

import 'package:flutter/material.dart';

import '../services/corridor_tracking_service.dart';
import 'arrival_screen.dart';

class StopAlertScreen extends StatefulWidget {
  const StopAlertScreen({super.key});

  @override
  State<StopAlertScreen> createState() => _StopAlertScreenState();
}

class _StopAlertScreenState extends State<StopAlertScreen> {
  static const _navy = Color(0xFF071426);
  static const _yellow = Color(0xFFFFD21F);
  static const _destinationStopIndex = 4;

  late final CorridorTrackingService _trackingService;
  StreamSubscription<BusLocation>? _locationSubscription;
  bool _arrivalOpened = false;

  @override
  void initState() {
    super.initState();
    _trackingService = CorridorTrackingService();
    _locationSubscription = _trackingService.locations.listen((location) {
      final stopIndex = location.stop?.index;
      if (stopIndex != null && stopIndex >= _destinationStopIndex) {
        _showArrival();
      }
    });
    unawaited(_trackingService.start());
  }

  void _showArrival() {
    if (!mounted || _arrivalOpened) return;
    _arrivalOpened = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ArrivalScreen()),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _trackingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
          child: Column(
            children: [
              const _TopControls(),
              const Spacer(flex: 2),
              Container(
                width: 145,
                height: 145,
                decoration: const BoxDecoration(
                  color: _yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications, color: _navy, size: 82),
              ),
              const SizedBox(height: 28),
              const Text(
                'Atención',
                style: TextStyle(
                  color: _yellow,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Estás a 1 paradero de tu\ndestino: PARADERO SAN LUIS',
                textAlign: TextAlign.center,
                style: _bodyStyle,
              ),
              const SizedBox(height: 24),
              const Text(
                'Acércate a la puerta\nde bajada.',
                textAlign: TextAlign.center,
                style: _bodyStyle,
              ),
              const Spacer(flex: 3),
              Semantics(
                liveRegion: true,
                child: const Text(
                  'Monitoreando llegada a San Luis...',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () {},
        tooltip: 'Configuración',
        icon: const Icon(Icons.settings, color: Colors.white),
      ),
    );
  }
}

const _bodyStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
  height: 1.4,
  fontWeight: FontWeight.w600,
);
