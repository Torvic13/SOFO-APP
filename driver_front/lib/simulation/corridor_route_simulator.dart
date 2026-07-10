class RoutePoint {
  const RoutePoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isStop = true,
  });

  final String name;
  final double latitude;
  final double longitude;
  final bool isStop;
}

class SimulatedCorridorRoute {
  SimulatedCorridorRoute({this.stepsPerSegment = 10})
    : assert(stepsPerSegment > 0);

  static const stops = <RoutePoint>[
    RoutePoint(
      name: 'La Positiva (inicio)',
      latitude: -12.091378,
      longitude: -77.026176,
    ),
    RoutePoint(
      name: 'Punto de ruta',
      latitude: -12.090196,
      longitude: -77.017311,
      isStop: false,
    ),
    RoutePoint(
      name: 'Guardia Civil',
      latitude: -12.088926,
      longitude: -77.008042,
    ),
    RoutePoint(name: 'Aviación', latitude: -12.088480, longitude: -77.004552),
  ];

  final int stepsPerSegment;
  int _segmentIndex = 0;
  int _stepInSegment = 0;

  RoutePoint get position {
    if (isComplete) return stops.last;
    final origin = stops[_segmentIndex];
    final destination = stops[_segmentIndex + 1];
    final fraction = _stepInSegment / stepsPerSegment;
    return RoutePoint(
      name: origin.name,
      latitude:
          origin.latitude + (destination.latitude - origin.latitude) * fraction,
      longitude:
          origin.longitude +
          (destination.longitude - origin.longitude) * fraction,
    );
  }

  String get currentStopName {
    for (var index = _segmentIndex; index >= 0; index--) {
      if (stops[index].isStop) return stops[index].name;
    }
    return stops.first.name;
  }

  String? get nextStopName {
    for (var index = _segmentIndex + 1; index < stops.length; index++) {
      if (stops[index].isStop) return stops[index].name;
    }
    return null;
  }

  int get completedSegments => _segmentIndex;

  int get totalSegments => stops.length - 1;

  bool get isComplete => _segmentIndex >= stops.length - 1;

  bool get isAtStop => _stepInSegment == 0 && stops[_segmentIndex].isStop;

  RoutePoint advance() {
    if (isComplete) return stops.last;
    _stepInSegment++;
    if (_stepInSegment >= stepsPerSegment) {
      _segmentIndex++;
      _stepInSegment = 0;
    }
    return position;
  }
}
