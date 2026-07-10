import 'dart:async';

import 'package:flutter/material.dart';

import '../services/corridor_tracking_service.dart';
import 'boarding_confirmation_screen.dart';

class CorridorTrackingScreen extends StatefulWidget {
  const CorridorTrackingScreen({super.key});

  @override
  State<CorridorTrackingScreen> createState() => _CorridorTrackingScreenState();
}

class _CorridorTrackingScreenState extends State<CorridorTrackingScreen> {
  static const _navy = Color(0xFF071426);
  static const _yellow = Color(0xFFFFD21F);
  static const _boardingStopIndex = 2;

  late final CorridorTrackingService _trackingService;
  StreamSubscription<BusLocation>? _locationSubscription;
  StreamSubscription<String>? _errorSubscription;
  int? _stopsAway;
  String? _error;
  bool _confirmationOpened = false;

  @override
  void initState() {
    super.initState();
    _trackingService = CorridorTrackingService();
    _locationSubscription = _trackingService.locations.listen(_onLocation);
    _errorSubscription = _trackingService.errors.listen((message) {
      if (mounted) setState(() => _error = message);
    });
    unawaited(_trackingService.start());
  }

  void _onLocation(BusLocation location) {
    final stop = location.stop;
    if (!mounted || stop == null) return;
    final stopsAway = (_boardingStopIndex - stop.index).clamp(0, 99).toInt();
    setState(() {
      _stopsAway = stopsAway;
      _error = null;
    });
    if (stopsAway == 0) unawaited(_openBoardingConfirmation());
  }

  Future<void> _openBoardingConfirmation() async {
    if (!mounted || _confirmationOpened) return;
    setState(() => _confirmationOpened = true);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BoardingConfirmationScreen(),
      ),
    );
  }

  Future<void> _retryBoardingConfirmation() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BoardingConfirmationScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _errorSubscription?.cancel();
    _trackingService.dispose();
    super.dispose();
  }

  String get _status {
    if (_stopsAway == 0) return 'El corredor 201 se encuentra en tu paradero';
    if (_stopsAway != null) {
      return 'El corredor 201 está a $_stopsAway ${_stopsAway == 1 ? 'paradero' : 'paraderos'}';
    }
    return _error ?? 'Buscando la ubicación del corredor 201';
  }

  @override
  Widget build(BuildContext context) {
    final hasArrived = _stopsAway == 0;
    return Scaffold(
      backgroundColor: _navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const Spacer(),
              const Text(
                'CORREDOR 201',
                style: TextStyle(
                  color: _yellow,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Icon(
                hasArrived ? Icons.directions_bus_filled : Icons.directions_bus,
                color: hasArrived ? _yellow : Colors.white,
                size: 145,
              ),
              const SizedBox(height: 32),
              Semantics(
                liveRegion: true,
                label: _status,
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              if (hasArrived)
                _confirmationOpened
                    ? SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed: _retryBoardingConfirmation,
                          style: FilledButton.styleFrom(
                            backgroundColor: _yellow,
                            foregroundColor: _navy,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('CONFIRMAR QUE SUBÍ'),
                        ),
                      )
                    : const Text(
                        'Abriendo confirmación de abordaje...',
                        style: TextStyle(color: _yellow, fontSize: 17),
                      )
              else if (_error != null)
                FilledButton.tonalIcon(
                  onPressed: () => unawaited(_trackingService.refresh()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('REINTENTAR CONEXIÓN'),
                )
              else
                const LinearProgressIndicator(
                  color: _yellow,
                  backgroundColor: Colors.white12,
                  minHeight: 7,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
