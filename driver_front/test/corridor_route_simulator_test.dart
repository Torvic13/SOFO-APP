import 'package:driver_front/simulation/corridor_route_simulator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recorre progresivamente todos los paraderos hasta Aviación', () {
    final route = SimulatedCorridorRoute(stepsPerSegment: 2);

    expect(route.position.latitude, -12.091378);
    expect(route.position.longitude, -77.026176);
    expect(route.nextStopName, 'Guardia Civil');
    expect(route.isAtStop, isTrue);

    final intermediate = route.advance();
    expect(intermediate.longitude, greaterThan(-77.026176));
    expect(intermediate.longitude, lessThan(-77.017311));
    expect(route.isAtStop, isFalse);

    route.advance();
    expect(route.currentStopName, 'La Positiva (inicio)');
    expect(route.nextStopName, 'Guardia Civil');
    expect(route.isAtStop, isFalse);

    for (var index = 0; index < 4; index++) {
      route.advance();
    }

    expect(route.isComplete, isTrue);
    expect(route.position.name, 'Aviación');
    expect(route.position.latitude, -12.088480);
    expect(route.position.longitude, -77.004552);
    expect(route.nextStopName, isNull);
  });
}
