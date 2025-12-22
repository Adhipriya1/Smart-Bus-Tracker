import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import 'package:geolocator/geolocator.dart';

class DatabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // 1. Get Stops for a specific route
  Future<List<RouteStop>> getRouteStops(String routeId) async {
    final response = await supabase
        .from('route_stops')
        .select()
        .eq('route_id', routeId)
        .order('sequence_order', ascending: true);
    
    return (response as List).map((e) => RouteStop.fromJson(e)).toList();
  }

  // 2. Issue Ticket (This triggers the occupancy update in SQL)
  Future<void> issueTicket(String busId, String sourceId, String destId) async {
    try {
      print("Attempting to issue ticket...");

      // 1. Fetch Coordinates safely
      final sourceData = await supabase
          .from('route_stops')
          .select('latitude, longitude')
          .eq('id', sourceId)
          .maybeSingle(); // Use maybeSingle() to avoid crash if ID is wrong
          
      final destData = await supabase
          .from('route_stops')
          .select('latitude, longitude')
          .eq('id', destId)
          .maybeSingle();

      int price = 15; // Default Base Fare

      // 2. Calculate Distance ONLY if data exists
      if (sourceData != null && destData != null &&
          sourceData['latitude'] != null && sourceData['longitude'] != null &&
          destData['latitude'] != null && destData['longitude'] != null) {
        
        double lat1 = (sourceData['latitude'] as num).toDouble();
        double lon1 = (sourceData['longitude'] as num).toDouble();
        double lat2 = (destData['latitude'] as num).toDouble();
        double lon2 = (destData['longitude'] as num).toDouble();

        // Calculate distance
        double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
        double distanceInKm = distanceInMeters / 1000;
        
        print("Distance: ${distanceInKm.toStringAsFixed(2)} km");

        // Price Logic: Base ₹10 + ₹5 per KM
        price = (10 + (distanceInKm * 5)).round();
        if (price < 10) price = 10;
      } else {
        print("Warning: Missing coordinates for stops. Using default fare ₹15.");
      }

      print("Final Price: ₹$price");

      // 3. Insert Ticket
      await supabase.from('tickets').insert({
        'bus_id': busId,
        'source_stop_id': sourceId,
        'destination_stop_id': destId,
        'amount_paid': price,
        'issued_at': DateTime.now().toIso8601String(),
      });
      
      print("Ticket inserted successfully!");

    } catch (e) {
      print("CRITICAL ERROR ISSUING TICKET: $e");
      // Re-throw so the UI knows it failed
      rethrow;
    }
  }

  // 3. Update GPS Location
  Future<void> updateLocation(String busId, double lat, double long) async {
    await supabase.from('buses').update({
      'current_latitude': lat,
      'current_longitude': long,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', busId);
  }
  
  // 4. Get Bus Data (One-time fetch)
  Future<Bus> getBus(String busId) async {
    final response = await supabase.from('buses').select().eq('id', busId).single();
    return Bus.fromJson(response);
  }

  // AUTOMATIC DROP-OFF: Mark all passengers destined for 'stopId' as alighted
  Future<int> autoAlightPassengers(String busId, String stopId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      // Update tickets where:
      // 1. Bus ID matches
      // 2. Destination matches the current stop
      // 3. Passenger hasn't alighted yet (alighted_at is null)
      final response = await supabase
          .from('tickets')
          .update({'alighted_at': now})
          .eq('bus_id', busId)
          .eq('destination_stop_id', stopId)
          .filter('alighted_at', 'is', null) // Only active passengers
          .select(); // Return updated rows to count them

      return (response as List).length; // Returns number of passengers dropped
    } catch (e) {
      print("Auto-drop error: $e");
      return 0;
    }
  }
}