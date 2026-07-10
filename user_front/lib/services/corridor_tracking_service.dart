import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;

class CorridorTrackingService {
  CorridorTrackingService({String corridor = '201', String? baseUrl})
    : _corridor = corridor,
      _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  final String _corridor;
  final String _baseUrl;
  final _locations = StreamController<BusLocation>.broadcast();
  final _errors = StreamController<String>.broadcast();
  io.Socket? _socket;
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  Stream<BusLocation> get locations => _locations.stream;
  Stream<String> get errors => _errors.stream;

  Future<void> start() async {
    _connectSocket();
    await _loadCurrentLocation();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      unawaited(_loadCurrentLocation());
    });
  }

  void _connectSocket() {
    final socket = io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );
    _socket = socket;
    socket.onConnect((_) => socket.emit('corridor:subscribe', _corridor));
    socket.on('bus:location-updated', (data) {
      final location = BusLocation.fromJson(data);
      if (location != null && location.corridor == _corridor) {
        _locations.add(location);
      }
    });
    socket.onConnectError((_) {
      _errors.add('No se pudo conectar al seguimiento en tiempo real');
    });
    socket.connect();
  }

  Future<void> _loadCurrentLocation() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final response = await http.get(
        Uri.parse(
          '${_baseUrl.replaceAll(RegExp(r'/$'), '')}/api/corridors/$_corridor/active-bus',
        ),
      );
      if (response.statusCode == 404) {
        _errors.add('Aún no hay un corredor 201 en recorrido');
        return;
      }
      if (response.statusCode != 200) {
        _errors.add('No se pudo consultar el corredor 201');
        return;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final bus = body['bus'];
      if (bus is Map<String, dynamic>) {
        final location = BusLocation.fromJson(bus['location']);
        if (location != null) _locations.add(location);
      }
    } catch (_) {
      _errors.add('No hay conexión con el backend de SOFO');
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> refresh() => _loadCurrentLocation();

  void dispose() {
    _refreshTimer?.cancel();
    _socket?.dispose();
    _locations.close();
    _errors.close();
  }
}

class BusLocation {
  const BusLocation({
    required this.unitId,
    required this.corridor,
    required this.latitude,
    required this.longitude,
    required this.stop,
  });

  final String unitId;
  final String corridor;
  final double latitude;
  final double longitude;
  final RouteStop? stop;

  static BusLocation? fromJson(dynamic value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final latitude = (json['latitude'] as num?)?.toDouble();
    final longitude = (json['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) return null;
    return BusLocation(
      unitId: json['unitId'] as String? ?? '',
      corridor: json['corridor'] as String? ?? '',
      latitude: latitude,
      longitude: longitude,
      stop: RouteStop.fromJson(json['routeStop']),
    );
  }
}

class RouteStop {
  const RouteStop({required this.name, required this.index});

  final String name;
  final int index;

  static RouteStop? fromJson(dynamic value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final name = json['name'];
    final index = json['index'];
    if (name is! String || index is! num) return null;
    return RouteStop(name: name, index: index.toInt());
  }
}
