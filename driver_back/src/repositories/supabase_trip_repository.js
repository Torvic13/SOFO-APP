import { createClient } from '@supabase/supabase-js';

export class SupabaseTripRepository {
  constructor(url, secretKey) {
    this.client = createClient(url, secretKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
  }

  async startTrip(unitId, corridor) {
    const { data: existing, error: findError } = await this.client
      .from('trips')
      .select('*')
      .eq('unit_id', unitId)
      .eq('status', 'active')
      .maybeSingle();
    if (findError) throw findError;
    if (existing) return mapTrip(existing);

    const { data, error } = await this.client
      .from('trips')
      .insert({ unit_id: unitId, corridor })
      .select('*')
      .single();
    if (error) throw error;
    return mapTrip(data);
  }

  async findTrip(tripId) {
    const { data, error } = await this.client
      .from('trips')
      .select('*')
      .eq('id', tripId)
      .maybeSingle();
    if (error) throw error;
    return data ? mapTrip(data) : null;
  }

  async saveLocation(trip, input) {
    const values = {
      trip_id: trip.id,
      unit_id: trip.unitId,
      corridor: trip.corridor,
      latitude: input.latitude,
      longitude: input.longitude,
      recorded_at: input.recordedAt,
    };

    const { data, error } = await this.client
      .from('bus_current_locations')
      .upsert(values, { onConflict: 'unit_id' })
      .select('*')
      .single();
    if (error) throw error;

    const { error: historyError } = await this.client
      .from('bus_location_history')
      .insert(values);
    if (historyError) throw historyError;
    return mapLocation(data);
  }

  async getCurrentLocation(unitId) {
    const { data, error } = await this.client
      .from('bus_current_locations')
      .select('*')
      .eq('unit_id', unitId)
      .maybeSingle();
    if (error) throw error;
    return data ? mapLocation(data) : null;
  }

  async finishTrip(tripId) {
    const { data, error } = await this.client
      .from('trips')
      .update({ status: 'finished', finished_at: new Date().toISOString() })
      .eq('id', tripId)
      .select('*')
      .maybeSingle();
    if (error) throw error;
    return data ? mapTrip(data) : null;
  }
}

function mapTrip(row) {
  return {
    id: row.id,
    unitId: row.unit_id,
    corridor: row.corridor,
    status: row.status,
    startedAt: row.started_at,
    finishedAt: row.finished_at,
  };
}

function mapLocation(row) {
  return {
    id: row.id,
    tripId: row.trip_id,
    unitId: row.unit_id,
    corridor: row.corridor,
    latitude: row.latitude,
    longitude: row.longitude,
    recordedAt: row.recorded_at,
  };
}
