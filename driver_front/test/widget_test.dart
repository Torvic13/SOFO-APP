import 'package:driver_front/main.dart';
import 'package:driver_front/services/driver_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('envía al backend el inicio, ubicación y final del recorrido', (
    tester,
  ) async {
    final gateway = _FakeDriverTripGateway();
    await tester.pumpWidget(SofoDriverApp(gateway: gateway));

    expect(find.text('bus-201-01'), findsOneWidget);
    expect(find.text('NO INICIADO'), findsOneWidget);
    expect(find.text('REINICIAR SIMULACIÓN'), findsOneWidget);

    final startButton = find.text('INICIAR RECORRIDO');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pump();
    await tester.pump();

    expect(gateway.startedUnitId, 'bus-201-01');
    expect(gateway.startedCorridor, '201');
    expect(gateway.sentLocations, hasLength(1));
    expect(find.text('RECORRIDO ACTIVO'), findsOneWidget);
    expect(find.text('Enviando ubicación'), findsOneWidget);
    expect(find.text('Esperando 10 segundos en el paradero'), findsOneWidget);

    final finishButton = find.byKey(const Key('finish-trip-button'));
    await tester.ensureVisible(finishButton);
    await tester.tap(finishButton);
    await tester.pump();
    await tester.pump();

    expect(gateway.finishedTripId, 'trip-123');
    expect(find.text('NO INICIADO'), findsOneWidget);
    expect(find.text('Envío de ubicación detenido'), findsOneWidget);

    final resetButton = find.byKey(const Key('reset-simulation-button'));
    await tester.ensureVisible(resetButton);
    await tester.tap(resetButton);
    await tester.pump();

    expect(find.text('-12.091378'), findsOneWidget);
    expect(find.text('-77.026176'), findsOneWidget);
    expect(find.text('La Positiva (inicio)'), findsOneWidget);
  });
}

class _FakeDriverTripGateway implements DriverTripGateway {
  String? startedUnitId;
  String? startedCorridor;
  String? finishedTripId;
  final sentLocations = <(double, double)>[];

  @override
  Future<String> startTrip({
    required String unitId,
    required String corridor,
  }) async {
    startedUnitId = unitId;
    startedCorridor = corridor;
    return 'trip-123';
  }

  @override
  Future<void> sendLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    sentLocations.add((latitude, longitude));
  }

  @override
  Future<void> finishTrip(String tripId) async {
    finishedTripId = tripId;
  }

  @override
  void close() {}
}
