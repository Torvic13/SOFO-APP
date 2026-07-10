import 'package:flutter_test/flutter_test.dart';
import 'package:sofo_front/services/corridor_tracking_service.dart';

void main() {
  test('interpreta ubicación y paradero enviados por el backend', () {
    final location = BusLocation.fromJson({
      'unitId': 'bus-201-01',
      'corridor': '201',
      'latitude': -12.088926,
      'longitude': -77.008042,
      'routeStop': {'name': 'Guardia Civil', 'index': 2},
    });

    expect(location, isNotNull);
    expect(location!.unitId, 'bus-201-01');
    expect(location.stop?.name, 'Guardia Civil');
    expect(location.stop?.index, 2);
  });
}
