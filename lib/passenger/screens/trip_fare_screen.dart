import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';
import 'package:smart_bus_tracker/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

// --- GOOGLE PLACES IMPORTS (Matches your Ticketing Screen) ---
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_maps_webservice_ex/places.dart' as ws; 
import 'package:google_api_headers/google_api_headers.dart';

// --- HELPER MODEL ---
class MapPlace {
  final String name;
  final String address;
  final double lat;
  final double long;

  MapPlace({required this.name, required this.address, required this.lat, required this.long});
}

class TripFareScreen extends StatefulWidget {
  const TripFareScreen({super.key});

  @override
  State<TripFareScreen> createState() => _TripFareScreenState();
}

class _TripFareScreenState extends State<TripFareScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Replaced Controllers with MapPlace objects
  MapPlace? _sourcePlace;
  MapPlace? _destPlace;
  
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  // ⚠️ USE YOUR API KEY HERE
  static const String _googleApiKey = "AIzaSyAby-Yt_aqeErBabBi_jUXVp2UlT-lLmxo"; 

  // --- 1. SEARCH FUNCTION (Copied & Adapted from TicketingScreen) ---
  Future<void> _openSearch(bool isSource) async {
    try {
      final sessionToken = const Uuid().v4();
      final places = ws.GoogleMapsPlaces(
        apiKey: _googleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );

      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: _googleApiKey,
        mode: Mode.overlay, // Full screen overlay search
        language: "en",
        sessionToken: sessionToken,
        types: [], // Empty list allows addresses + establishments
        hint: "Search Bus Stop...",
        components: [const Component(Component.country, "in")], // Restrict to India
        onError: (response) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: TranslatedText(response.errorMessage ?? "Error"), backgroundColor: Colors.red),
            );
          }
        },
      );

      if (p != null && p.placeId != null) {
        // Fetch Details (Lat/Lng)
        ws.PlacesDetailsResponse detail = await places.getDetailsByPlaceId(
          p.placeId!,
          sessionToken: sessionToken,
        );

        final geometry = detail.result!.geometry;

        if (geometry != null) {
          final lat = geometry.location.lat;
          final lng = geometry.location.lng;
          final name = detail.result!.name ?? "Unknown Location";      
          final address = detail.result!.formattedAddress ?? "Unknown Address";

          setState(() {
            final place = MapPlace(name: name, address: address, lat: lat, long: lng);
            if (isSource) {
              _sourcePlace = place;
            } else {
              _destPlace = place;
            }
            // Clear previous result when selection changes
            _result = null; 
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: TranslatedText(loc?.errorSending(e) ?? 'Error: $e')));
      }
    }
  }

  // --- 2. FETCH FARE RULES ---
  Future<Map<String, double>> _fetchFareRules() async {
    try {
      final data = await supabase.from('fare_rules').select().maybeSingle();
      if (data != null) {
        return {
          'base': (data['base_fare'] as num).toDouble(),
          'rate': (data['rate_per_km'] as num).toDouble(),
        };
      }
    } catch (e) {
      debugPrint("Error fetching fare rules: $e");
    }
    return {'base': 10.0, 'rate': 5.0};
  }

  // --- 3. GOOGLE DIRECTIONS API LOGIC ---
  Future<void> _calculateTrip() async {
    if (_sourcePlace == null || _destPlace == null) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: TranslatedText(loc?.pleaseSelectSourceDestination ?? 'Please select Source and Destination')),
      );
      return;
    }

    setState(() { _isLoading = true; _result = null; });

    try {
      final rates = await _fetchFareRules();
      final baseFare = rates['base']!;
      final ratePerKm = rates['rate']!;

      // Use Lat/Lng coordinates directly for better accuracy
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${_sourcePlace!.lat},${_sourcePlace!.long}"
        "&destination=${_destPlace!.lat},${_destPlace!.long}"
        "&mode=transit"
        "&key=$_googleApiKey"
      );

      final response = await http.get(url);
      final googleData = json.decode(response.body);

      if (googleData['status'] == 'OK') {
        final route = googleData['routes'][0];
        final leg = route['legs'][0];

        final int distanceMeters = leg['distance']['value'];
        final int durationSeconds = leg['duration']['value'];
        
        // We use the names from our Place selection, but you can also use leg['start_address']
        final double distanceKm = distanceMeters / 1000.0;
        final int durationMins = (durationSeconds / 60).ceil();
        final double totalFare = baseFare + (distanceKm * ratePerKm);

        if (mounted) {
          setState(() {
            _result = {
              'start_address': _sourcePlace!.name, // Display friendly name
              'end_address': _destPlace!.name,
              'distance': distanceKm.toStringAsFixed(1),
              'duration': durationMins,
              'fare': totalFare.ceil(),
              'rate_used': ratePerKm,
            };
            _isLoading = false;
          });
        }
      } else {
        throw "Google Maps Error: ${googleData['status']}";
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TranslatedText(loc?.errorSending(e) ?? 'Calculation Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[800] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(title: TranslatedText(AppLocalizations.of(context)?.tripFareCalculator ?? 'Trip Fare Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INPUT CARD ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // SOURCE INPUT (Clickable)
                    _buildMapInput(
                      label: "Source",
                      value: _sourcePlace?.name,
                      address: _sourcePlace?.address,
                      icon: Icons.trip_origin,
                      color: Colors.green,
                      onTap: () => _openSearch(true),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Container(height: 20, width: 2, color: Colors.grey[300]),
                    ),

                    // DESTINATION INPUT (Clickable)
                    _buildMapInput(
                      label: "Destination",
                      value: _destPlace?.name,
                      address: _destPlace?.address,
                      icon: Icons.location_on,
                      color: Colors.red,
                      onTap: () => _openSearch(false),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.search, color: Colors.white),
                        label: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : TranslatedText(AppLocalizations.of(context)?.getRealtimeFare ?? 'GET REALTIME FARE', style: const TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _calculateTrip,
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- RESULT SECTION ---
            if (_result != null) ...[
              TranslatedText(AppLocalizations.of(context)?.tripDetails ?? 'Trip Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 10),
              
              // 1. FARE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade500]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    TranslatedText(AppLocalizations.of(context)?.estimatedFare ?? 'ESTIMATED FARE', style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
                    const SizedBox(height: 5),
                    TranslatedText(
                      "₹${_result!['fare']}", 
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. STATS ROW
              Row(
                children: [
                  Expanded(child: _buildResultTile(Icons.straighten, "${_result!['distance']} km", "Distance", Colors.orange, isDark)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildResultTile(Icons.timer, "${_result!['duration']} mins", "Time", Colors.blue, isDark)),
                ],
              ),
              
              const SizedBox(height: 20),
              Center(
                child: TranslatedText("${AppLocalizations.of(context)?.routeLabel ?? 'Route:'} ${_result!['start_address']} ➝ ${_result!['end_address']}", 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- REUSABLE CLICKABLE INPUT WIDGET ---
  Widget _buildMapInput({
    required String label, 
    String? value, 
    String? address, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    value ?? "Search $label",
                    style: TextStyle(
                      color: value == null ? Colors.grey : textColor,
                      fontWeight: value == null ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address != null)
                    TranslatedText(
                      address,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Icon(Icons.search, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(IconData icon, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          TranslatedText(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          TranslatedText(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}