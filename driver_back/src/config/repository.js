import { MemoryTripRepository } from '../repositories/memory_trip_repository.js';
import { SupabaseTripRepository } from '../repositories/supabase_trip_repository.js';

export function createRepository() {
  const url = process.env.SUPABASE_URL;
  const key =
    process.env.SUPABASE_SECRET_KEY ?? process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (url && key) {
    console.info('Persistencia: Supabase');
    return new SupabaseTripRepository(url, key);
  }

  console.info('Persistencia: memoria (los datos se borran al reiniciar)');
  return new MemoryTripRepository();
}
