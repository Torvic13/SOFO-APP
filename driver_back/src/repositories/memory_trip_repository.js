import { randomUUID } from 'node:crypto';

export class MemoryTripRepository {
  constructor() {
    this.trips = new Map();
    this.currentLocations = new Map();
  }

  async startTrip(unitId, corridor) {
    const activeTrip = [...this.trips.values()].find(
      (trip) => trip.unitId === unitId && trip.status === 'active',
    );
    if (activeTrip) return activeTrip;

    const trip = {
      id: randomUUID(),
      unitId,
      corridor,
      status: 'active',
      startedAt: new Date().toISOString(),
      finishedAt: null,
    };
    this.trips.set(trip.id, trip);
    return trip;
  }

  async findTrip(tripId) {
    return this.trips.get(tripId) ?? null;
  }

  async saveLocation(trip, input) {
    const location = {
      id: randomUUID(),
      tripId: trip.id,
      unitId: trip.unitId,
      corridor: trip.corridor,
      latitude: input.latitude,
      longitude: input.longitude,
      recordedAt: input.recordedAt ?? new Date().toISOString(),
    };
    this.currentLocations.set(trip.unitId, location);
    return location;
  }

  async getCurrentLocation(unitId) {
    return this.currentLocations.get(unitId) ?? null;
  }

  async finishTrip(tripId) {
    const trip = this.trips.get(tripId);
    if (!trip) return null;

    const finishedTrip = {
      ...trip,
      status: 'finished',
      finishedAt: new Date().toISOString(),
    };
    this.trips.set(tripId, finishedTrip);
    return finishedTrip;
  }
}
