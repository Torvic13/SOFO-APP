import request from 'supertest';
import { describe, expect, it } from 'vitest';

import { createApp } from '../src/app.js';
import { MemoryTripRepository } from '../src/repositories/memory_trip_repository.js';

describe('SOFO Driver API', () => {
  it('inicia, actualiza y finaliza un recorrido', async () => {
    const app = createApp(new MemoryTripRepository());

    const start = await request(app)
      .post('/api/trips/start')
      .send({ unitId: 'bus-201-01', corridor: '201' })
      .expect(201);
    const tripId = start.body.trip.id;
    expect(start.body.trip.status).toBe('active');

    await request(app)
      .post(`/api/trips/${tripId}/location`)
      .send({ latitude: -12.091378, longitude: -77.026176 })
      .expect(201);

    const current = await request(app)
      .get('/api/buses/bus-201-01/location')
      .expect(200);
    expect(current.body.location.latitude).toBe(-12.091378);

    const finish = await request(app)
      .post(`/api/trips/${tripId}/finish`)
      .expect(200);
    expect(finish.body.trip.status).toBe('finished');

    await request(app)
      .post(`/api/trips/${tripId}/location`)
      .send({ latitude: -12, longitude: -77 })
      .expect(409);
  });

  it('rechaza coordenadas fuera de rango', async () => {
    const app = createApp(new MemoryTripRepository());
    const start = await request(app)
      .post('/api/trips/start')
      .send({ unitId: 'bus-201-01', corridor: '201' });

    await request(app)
      .post(`/api/trips/${start.body.trip.id}/location`)
      .send({ latitude: -120, longitude: -77 })
      .expect(400);
  });
});
