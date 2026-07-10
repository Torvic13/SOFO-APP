# SOFO Driver Backend

API de recorridos y ubicación en tiempo real para la aplicación del conductor,
desarrollada con Node.js y JavaScript moderno (ES modules).

## Requisitos

- Node.js 20 o superior
- npm

## Inicio local

```bash
npm install
copy .env.example .env
npm run dev
```

Sin credenciales de Supabase, el servidor utiliza memoria temporal. La API queda
disponible en `http://localhost:3000`.

## Supabase

1. Abre el SQL Editor de tu proyecto.
2. Ejecuta `supabase/migrations/001_initial_schema.sql`.
3. Copia `.env.example` como `.env`.
4. Completa `SUPABASE_URL` y `SUPABASE_SECRET_KEY`.

La clave secreta (`sb_secret_...`) es privada: nunca debe agregarse a Flutter ni
subirse a Git. También se admite la clave heredada `service_role`. Al reiniciar
el servidor con ambas variables configuradas, se selecciona Supabase
automáticamente.

## API

- `GET /api/health`
- `POST /api/trips/start`
- `POST /api/trips/:tripId/location`
- `POST /api/trips/:tripId/finish`
- `GET /api/buses/:unitId/location`

Ejemplo para iniciar:

```json
{ "unitId": "bus-201-01", "corridor": "201" }
```

Ejemplo de ubicación:

```json
{ "latitude": -12.046374, "longitude": -77.042793 }
```

## Socket.IO

- El cliente pasajero emite `corridor:subscribe` con `"201"`.
- El conductor emite `location:update` con `tripId`, `latitude` y `longitude`.
- Los suscriptores reciben `bus:location-updated` y `trip:finished`.

## Verificación

```bash
npm run check
npm test
```

Con las credenciales configuradas, la integración real se comprueba con:

```bash
npm run verify:supabase
```
