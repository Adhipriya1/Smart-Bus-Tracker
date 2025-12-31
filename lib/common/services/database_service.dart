import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';

class DatabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // 1. Get Stops for a specific route
  Future<List<RouteStop>> getRouteStops(String routeId) async {
    try {
      final response = await supabase
          .from('route_stops')
          .select()
          .eq('route_id', routeId)
          .order('sequence_order', ascending: true);
      
      return (response as List).map((e) => RouteStop.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching stops: $e");
      return [];
    }
  }

  // 2. Issue Ticket
  Future<void> issueTicket(String busId, String sourceId, String destId) async {
    try {
      debugPrint("Attempting to issue ticket...");

      // Fetch coordinates safely
      final sourceData = await supabase
          .from('route_stops')
          .select('latitude, longitude')
          .eq('id', sourceId)
          .maybeSingle(); 
          
      final destData = await supabase
          .from('route_stops')
          .select('latitude, longitude')
          .eq('id', destId)
          .maybeSingle();

      if (sourceData == null || destData == null) {
        throw "Invalid Stop IDs selected";
      }

      // Logic to actually insert ticket would go here...
      
    } catch (e) {
      debugPrint("ERROR ISSUING TICKET: $e");
      rethrow;
    }
  }

  // 3. Update GPS Location (FIXED with Error Handling)
  Future<void> updateLocation(String busId, double lat, double long) async {
    try {
      await supabase.from('buses').update({
        'current_latitude': lat,
        'current_longitude': long,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', busId);
    } catch (e) {
      // Log error but don't crash app during background updates
      debugPrint("GPS Update Error: $e");
    }
  }
  
  // 4. Get Bus Data
  Future<Bus> getBus(String busId) async {
    final response = await supabase.from('buses').select().eq('id', busId).single();
    return Bus.fromJson(response);
  }

  // AUTOMATIC DROP-OFF
  Future<int> autoAlightPassengers(String busId, String stopId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Select tickets to update first (optional, for logic)
      // Then update
      final response = await supabase
          .from('tickets')
          .update({'alighted_at': now})
          .eq('bus_id', busId)
          .isFilter('alighted_at', null) // Only active tickets
          .select(); // Returns the updated rows

      return (response as List).length; 
    } catch (e) {
      debugPrint("Auto alight error: $e");
      return 0;
    }
  }
}