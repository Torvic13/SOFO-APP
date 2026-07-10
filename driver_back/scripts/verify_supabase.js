import 'dotenv/config';

import { randomUUID } from 'node:crypto';

import request from 'supertest';

import { createApp } from '../src/app.js';
import { createRepository } from '../src/config/repository.js';

async function main() {
  const repository = createRepository();
  const app = createApp(repository);
  const unitId = `bus-verification-${randomUUID().slice(0, 8)}`;

  const health = await request(app).get('/api/health');
  assertStatus('health', health.status, 200);

  const start = await request(app)
    .post('/api/trips/start')
    .send({ unitId, corridor: '201' });
  assertStatus('iniciar recorrido', start.status, 201);

  const tripId = start.body.trip?.id;
  if (!tripId) throw new Error('Supabase no devolvió el ID del recorrido');

  const update = await request(app)
    .post(`/api/trips/${tripId}/location`)
    .send({ latitude: -12.091378, longitude: -77.026176 });
  assertStatus('guardar ubicación', update.status, 201);

  const current = await request(app).get(`/api/buses/${unitId}/location`);
  assertStatus('consultar ubicación', current.status, 200);
  if (
    current.body.location?.latitude !== -12.091378 ||
    current.body.location?.longitude !== -77.026176
  ) {
    throw new Error('La ubicación consultada no coincide con la enviada');
  }

  const activeBus = await request(app).get('/api/corridors/201/active-bus');
  assertStatus('consultar corredor activo', activeBus.status, 200);
  if (
    activeBus.body.bus?.unitId !== unitId ||
    activeBus.body.bus?.location?.routeStop?.name !== 'La Positiva'
  ) {
    throw new Error('El corredor activo no devolvió la ubicación esperada');
  }

  const finish = await request(app).post(`/api/trips/${tripId}/finish`);
  assertStatus('finalizar recorrido', finish.status, 200);
  if (finish.body.trip?.status !== 'finished') {
    throw new Error('El recorrido no quedó finalizado');
  }

  console.info('Verificación Supabase completada correctamente');
  console.info(`Unidad de prueba: ${unitId}`);
  console.info(`Recorrido finalizado: ${tripId}`);
}

function assertStatus(operation, actual, expected) {
  if (actual !== expected) {
    throw new Error(`${operation}: HTTP ${actual}; se esperaba HTTP ${expected}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
