import cors from 'cors';
import express from 'express';

import { parseLocation } from './validation/location.js';

export function createApp(repository, io) {
  const app = express();
  app.use(cors({ origin: process.env.CLIENT_ORIGIN ?? '*' }));
  app.use(express.json());

  app.get('/api/health', (_request, response) => {
    response.json({ status: 'ok', service: 'sofo-driver-back' });
  });

  app.post('/api/trips/start', async (request, response, next) => {
    try {
      const unitId = String(request.body.unitId ?? '').trim();
      const corridor = String(request.body.corridor ?? '').trim();
      if (!unitId || !corridor) {
        response.status(400).json({ error: 'unitId y corridor son obligatorios' });
        return;
      }

      const trip = await repository.startTrip(unitId, corridor);
      response.status(201).json({ trip });
    } catch (error) {
      next(error);
    }
  });

  app.post('/api/trips/:tripId/location', async (request, response, next) => {
    try {
      const trip = await repository.findTrip(request.params.tripId);
      if (!trip) {
        response.status(404).json({ error: 'Recorrido no encontrado' });
        return;
      }
      if (trip.status !== 'active') {
        response.status(409).json({ error: 'El recorrido ya finalizó' });
        return;
      }

      const input = parseLocation(request.body);
      if (!input) {
        response.status(400).json({ error: 'Coordenadas inválidas' });
        return;
      }

      const location = await repository.saveLocation(trip, input);
      io?.to(`corridor:${trip.corridor}`).emit('bus:location-updated', location);
      response.status(201).json({ location });
    } catch (error) {
      next(error);
    }
  });

  app.get('/api/buses/:unitId/location', async (request, response, next) => {
    try {
      const location = await repository.getCurrentLocation(request.params.unitId);
      if (!location) {
        response.status(404).json({ error: 'Ubicación no encontrada' });
        return;
      }
      response.json({ location });
    } catch (error) {
      next(error);
    }
  });

  app.post('/api/trips/:tripId/finish', async (request, response, next) => {
    try {
      const trip = await repository.finishTrip(request.params.tripId);
      if (!trip) {
        response.status(404).json({ error: 'Recorrido no encontrado' });
        return;
      }
      io?.to(`corridor:${trip.corridor}`).emit('trip:finished', trip);
      response.json({ trip });
    } catch (error) {
      next(error);
    }
  });

  app.use((error, _request, response, _next) => {
    console.error(error);
    response.status(500).json({ error: 'Error interno del servidor' });
  });

  return app;
}
