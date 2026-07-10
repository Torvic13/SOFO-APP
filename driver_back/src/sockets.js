import { parseLocation } from './validation/location.js';

export function configureSockets(io, repository) {
  io.on('connection', (socket) => {
    socket.on('corridor:subscribe', (corridor) => {
      if (typeof corridor === 'string' && corridor.trim()) {
        void socket.join(`corridor:${corridor.trim()}`);
      }
    });

    socket.on('location:update', async (payload, acknowledge) => {
      try {
        const tripId = typeof payload?.tripId === 'string' ? payload.tripId : '';
        const trip = tripId ? await repository.findTrip(tripId) : null;
        const locationInput = parseLocation(payload);

        if (!trip || trip.status !== 'active' || !locationInput) {
          acknowledge?.({ ok: false, error: 'Datos de ubicación inválidos' });
          return;
        }

        const location = await repository.saveLocation(trip, locationInput);
        io.to(`corridor:${trip.corridor}`).emit(
          'bus:location-updated',
          location,
        );
        acknowledge?.({ ok: true });
      } catch (error) {
        console.error(error);
        acknowledge?.({ ok: false, error: 'No se pudo guardar la ubicación' });
      }
    });
  });
}
