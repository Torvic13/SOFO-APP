import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract interface class DriverTripGateway {
  Future<String> startTrip({required String unitId, required String corridor});

  Future<void> sendLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  });

  Future<void> finishTrip(String tripId);

  void close();
}

class DriverApiService implements DriverTripGateway {
  DriverApiService({String? baseUrl, http.Client? client})
    : _baseUrl = baseUrl ?? _defaultBaseUrl,
      _client = client ?? http.Client();

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  final String _baseUrl;
  final http.Client _client;

  @override
  Future<String> startTrip({
    required String unitId,
    required String corridor,
  }) async {
    final response = await _client.post(
      _uri('/api/trips/start'),
      headers: _jsonHeaders,
      body: jsonEncode({'unitId': unitId, 'corridor': corridor}),
    );
    final body = _decodeResponse(response, expectedStatus: 201);
    final trip = body['trip'];
    if (trip is! Map<String, dynamic> || trip['id'] is! String) {
      throw const DriverApiException(
        'El backend devolvió un recorrido inválido',
      );
    }
    return trip['id'] as String;
  }

  @override
  Future<void> sendLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.post(
      _uri('/api/trips/$tripId/location'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'recordedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    _decodeResponse(response, expectedStatus: 201);
  }

  @override
  Future<void> finishTrip(String tripId) async {
    final response = await _client.post(_uri('/api/trips/$tripId/finish'));
    _decodeResponse(response, expectedStatus: 200);
  }

  Uri _uri(String path) =>
      Uri.parse('${_baseUrl.replaceAll(RegExp(r'/$'), '')}$path');

  Map<String, dynamic> _decodeResponse(
    http.Response response, {
    required int expectedStatus,
  }) {
    Map<String, dynamic> body = {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    }
    if (response.statusCode != expectedStatus) {
      throw DriverApiException(
        body['error'] as String? ??
            'Error de comunicación (${response.statusCode})',
      );
    }
    return body;
  }

  @override
  void close() => _client.close();

  static const _jsonHeaders = {'Content-Type': 'application/json'};
}

class DriverApiException implements Exception {
  const DriverApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
