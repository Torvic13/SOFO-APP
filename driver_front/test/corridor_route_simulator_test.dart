import 'package:driver_front/simulation/corridor_route_simulator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recorre progresivamente todos los paraderos hasta San Luis', () {
    final route = SimulatedCorridorRoute(stepsPerSegment: 2);

    expect(route.position.latitude, -12.091378);
    expect(route.position.longitude, -77.026176);
    expect(route.nextStopName, 'Ricardo Palma');
    expect(route.isAtStop, isTrue);

    final intermediate = route.advance();
    expect(intermediate.longitude, greaterThan(-77.026176));
    expect(intermediate.longitude, lessThan(-77.017311));
    expect(route.isAtStop, isFalse);

    route.advance();
    expect(route.currentStopName, 'Ricardo Palma');
    expect(route.nextStopName, 'Guardia Civil');
    expect(route.isAtStop, isTrue);

    for (var index = 0; index < 6; index++) {
      route.advance();
    }

    expect(route.isComplete, isTrue);
    expect(route.position.name, 'San Luis');
    expect(route.position.latitude, -12.087383);
    expect(route.position.longitude, -76.996908);
    expect(route.nextStopName, isNull);
  });
}
