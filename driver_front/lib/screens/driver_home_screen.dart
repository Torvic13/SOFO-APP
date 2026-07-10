import 'dart:async';

import 'package:flutter/material.dart';

import '../services/driver_api_service.dart';
import '../simulation/corridor_route_simulator.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key, this.gateway});

  final DriverTripGateway? gateway;

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  static const String _unitId = 'bus-201-01';
  static const String _corridor = '201';

  late final DriverTripGateway _gateway;
  late final bool _ownsGateway;
  SimulatedCorridorRoute _route = SimulatedCorridorRoute();
  bool _isTripActive = false;
  bool _isSendingLocation = false;
  bool _isBusy = false;
  bool _isWaitingAtStop = false;
  String? _tripId;
  double _latitude = SimulatedCorridorRoute.stops.first.latitude;
  double _longitude = SimulatedCorridorRoute.stops.first.longitude;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _ownsGateway = widget.gateway == null;
    _gateway = widget.gateway ?? DriverApiService();
  }

  Future<void> _startTrip() async {
    _resetSimulation(updateUi: false);
    setState(() {
      _isBusy = true;
      _latitude = _route.position.latitude;
      _longitude = _route.position.longitude;
    });
    try {
      final tripId = await _gateway.startTrip(
        unitId: _unitId,
        corridor: _corridor,
      );
      if (!mounted) return;
      setState(() {
        _tripId = tripId;
        _isTripActive = true;
        _isSendingLocation = true;
        _isWaitingAtStop = true;
        _isBusy = false;
      });

      await _sendLocation(showError: true);
      _scheduleNextMovement(const Duration(seconds: 10));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showError('No se pudo iniciar el recorrido: $error');
    }
  }

  void _resetSimulation({bool updateUi = true}) {
    _locationTimer?.cancel();
    _route = SimulatedCorridorRoute();

    void resetValues() {
      _latitude = _route.position.latitude;
      _longitude = _route.position.longitude;
      _isWaitingAtStop = false;
      _isSendingLocation = false;
    }

    if (updateUi) {
      setState(resetValues);
    } else {
      resetValues();
    }
  }

  void _scheduleNextMovement(Duration delay) {
    _locationTimer?.cancel();
    _locationTimer = Timer(delay, _advanceRoute);
  }

  void _advanceRoute() {
    if (!mounted || !_isTripActive || _route.isComplete) return;
    final position = _route.advance();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _isWaitingAtStop = _route.isAtStop && !_route.isComplete;
    });
    unawaited(_sendLocation());

    if (!_route.isComplete) {
      _scheduleNextMovement(
        _route.isAtStop
            ? const Duration(seconds: 10)
            : const Duration(seconds: 3),
      );
    }
  }

  Future<void> _sendLocation({bool showError = false}) async {
    final tripId = _tripId;
    if (tripId == null) return;
    try {
      await _gateway.sendLocation(
        tripId: tripId,
        latitude: _latitude,
        longitude: _longitude,
      );
      if (mounted && !_isSendingLocation) {
        setState(() => _isSendingLocation = true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSendingLocation = false);
      if (showError) _showError('No se pudo enviar la ubicación: $error');
    }
  }

  Future<void> _finishTrip() async {
    final tripId = _tripId;
    if (tripId == null) return;
    setState(() => _isBusy = true);
    try {
      await _gateway.finishTrip(tripId);
      _locationTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _tripId = null;
        _isTripActive = false;
        _isSendingLocation = false;
        _isWaitingAtStop = false;
        _isBusy = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isBusy = false);
      _showError('No se pudo finalizar el recorrido: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    if (_ownsGateway) _gateway.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('SOFO Conductor'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _VehicleCard(unitId: _unitId, corridor: _corridor),
                  const SizedBox(height: 20),
                  _StatusCard(isTripActive: _isTripActive),
                  const SizedBox(height: 20),
                  _RouteCard(
                    currentStop: _route.currentStopName,
                    nextStop: _route.nextStopName,
                    completedSegments: _route.completedSegments,
                    totalSegments: _route.totalSegments,
                    isWaitingAtStop: _isWaitingAtStop,
                  ),
                  const SizedBox(height: 20),
                  _LocationCard(
                    latitude: _latitude,
                    longitude: _longitude,
                    isSending: _isSendingLocation,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 64,
                    child: _isTripActive
                        ? FilledButton.icon(
                            key: const Key('finish-trip-button'),
                            onPressed: _isBusy ? null : _finishTrip,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onError,
                            ),
                            icon: _isBusy
                                ? const _ButtonProgress()
                                : const Icon(Icons.stop_rounded, size: 30),
                            label: const Text(
                              'FINALIZAR RECORRIDO',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: _isBusy ? null : _startTrip,
                            icon: _isBusy
                                ? const _ButtonProgress()
                                : const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 30,
                                  ),
                            label: const Text(
                              'INICIAR RECORRIDO',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  if (!_isTripActive) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        key: const Key('reset-simulation-button'),
                        onPressed: _isBusy ? null : _resetSimulation,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('REINICIAR SIMULACIÓN'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonProgress extends StatelessWidget {
  const _ButtonProgress();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.unitId, required this.corridor});

  final String unitId;
  final String corridor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.directions_bus_rounded, size: 48),
            const SizedBox(height: 12),
            _DataRow(label: 'Unidad', value: unitId),
            const Divider(height: 28),
            _DataRow(label: 'Corredor', value: corridor),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.isTripActive});

  final bool isTripActive;

  @override
  Widget build(BuildContext context) {
    final activeColor = isTripActive
        ? Colors.green.shade700
        : Colors.grey.shade700;

    return Semantics(
      liveRegion: true,
      label: isTripActive ? 'Recorrido activo' : 'Recorrido no iniciado',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                isTripActive ? Icons.check_circle : Icons.pause_circle,
                color: activeColor,
                size: 34,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ESTADO DEL RECORRIDO'),
                    const SizedBox(height: 4),
                    Text(
                      isTripActive ? 'RECORRIDO ACTIVO' : 'NO INICIADO',
                      style: TextStyle(
                        color: activeColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.currentStop,
    required this.nextStop,
    required this.completedSegments,
    required this.totalSegments,
    required this.isWaitingAtStop,
  });

  final String currentStop;
  final String? nextStop;
  final int completedSegments;
  final int totalSegments;
  final bool isWaitingAtStop;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'RUTA SIMULADA',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _DataRow(label: 'Último paradero', value: currentStop),
            const SizedBox(height: 10),
            _DataRow(label: 'Siguiente', value: nextStop ?? 'Ruta completada'),
            if (isWaitingAtStop) ...[
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esperando 10 segundos en el paradero',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalSegments == 0 ? 1 : completedSegments / totalSegments,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.latitude,
    required this.longitude,
    required this.isSending,
  });

  final double latitude;
  final double longitude;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'UBICACIÓN DE LA UNIDAD',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _DataRow(label: 'Latitud', value: latitude.toStringAsFixed(6)),
            const SizedBox(height: 10),
            _DataRow(label: 'Longitud', value: longitude.toStringAsFixed(6)),
            const Divider(height: 28),
            Row(
              children: [
                Icon(
                  isSending ? Icons.cloud_upload : Icons.cloud_off,
                  color: isSending ? Colors.green.shade700 : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isSending
                        ? 'Enviando ubicación'
                        : 'Envío de ubicación detenido',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (isSending)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
