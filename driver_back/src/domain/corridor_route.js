export const corridor201Stops = [
  { name: 'La Positiva', latitude: -12.091378, longitude: -77.026176 },
  { name: 'Ricardo Palma', latitude: -12.090196, longitude: -77.017311 },
  { name: 'Guardia Civil', latitude: -12.088926, longitude: -77.008042 },
  { name: 'Aviación', latitude: -12.08848, longitude: -77.004552 },
  { name: 'San Luis', latitude: -12.087383, longitude: -76.996908 },
];

export function enrichLocation(location) {
  if (!location) return null;
  const stops = location.corridor === '201' ? corridor201Stops : [];
  let nearestStop = null;
  let nearestDistance = Number.POSITIVE_INFINITY;

  stops.forEach((stop, index) => {
    const distance = distanceInMeters(location, stop);
    if (distance < nearestDistance) {
      nearestDistance = distance;
      nearestStop = { ...stop, index };
    }
  });

  return {
    ...location,
    routeStop:
      nearestStop && nearestDistance <= 60
        ? { ...nearestStop, distanceMeters: Math.round(nearestDistance) }
        : null,
  };
}

function distanceInMeters(first, second) {
  const earthRadius = 6371000;
  const toRadians = (degrees) => (degrees * Math.PI) / 180;
  const latitudeDelta = toRadians(second.latitude - first.latitude);
  const longitudeDelta = toRadians(second.longitude - first.longitude);
  const firstLatitude = toRadians(first.latitude);
  const secondLatitude = toRadians(second.latitude);
  const a =
    Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(firstLatitude) *
      Math.cos(secondLatitude) *
      Math.sin(longitudeDelta / 2) ** 2;
  return earthRadius * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
