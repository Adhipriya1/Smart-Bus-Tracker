import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_maps_webservice_ex/places.dart' as ws; 
import 'package:google_api_headers/google_api_headers.dart';
import 'package:uuid/uuid.dart';

import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/services/database_service.dart';
import '../../common/services/location_service.dart';
import 'manage_occupancy_screen.dart';
import 'conductor_home_screen.dart';

const String googleMapsApiKey = "AIzaSyAby-Yt_aqeErBabBi_jUXVp2UlT-lLmxo"; 

class MapPlace {
  final String name;
  final String address;
  final double lat;
  final double long;

  MapPlace({required this.name, required this.address, required this.lat, required this.long});
}

class TicketingScreen extends StatefulWidget {
  final String busId;
  final String routeId;

  const TicketingScreen({super.key, required this.busId, required this.routeId});

  @override
  State<TicketingScreen> createState() => _TicketingScreenState();
}

class _TicketingScreenState extends State<TicketingScreen> {
  final _db = DatabaseService();
  final _loc = LocationService();
  final SupabaseClient supabase = Supabase.instance.client;

  StreamSubscription? _gpsSub;
  late final Stream<List<Map<String, dynamic>>> _busStream;
  
  MapPlace? _sourcePlace;
  MapPlace? _destPlace;
  
  double _calculatedFare = 0.0;
  double _tripDistance = 0.0;
  
  bool _isIssuing = false;
  bool _isCalculatingFare = false;
  
  String _currentLocationName = "Locating...";
  DateTime? _lastGeocodeTime;

  @override
  void initState() {
    super.initState();
    _busStream = supabase
        .from('buses')
        .stream(primaryKey: ['id'])
        .eq('id', widget.busId);

    _startGpsAndAutomation();
  }

  void _startGpsAndAutomation() async {
    if (await _loc.checkPermissions()) {
      _gpsSub = _loc.getStream().listen((Position pos) {
        _db.updateLocation(widget.busId, pos.latitude, pos.longitude);
        _updateCurrentLocationName(pos.latitude, pos.longitude);
        _checkForArrival(pos);
      });
    }
  }

  Future<void> _updateCurrentLocationName(double lat, double lng) async {
    if (_lastGeocodeTime != null && DateTime.now().difference(_lastGeocodeTime!).inSeconds < 10) {
      return;
    }
    _lastGeocodeTime = DateTime.now();

    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleMapsApiKey"
      );
      
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        String bestName = data['results'][0]['formatted_address'];
        if (bestName.contains(',')) {
          bestName = bestName.split(',')[0]; 
        }

        if (mounted) {
          setState(() {
            _currentLocationName = bestName;
            _sourcePlace ??= MapPlace(
                name: bestName, 
                address: data['results'][0]['formatted_address'], 
                lat: lat, 
                long: lng
              );
          });
        }
      }
    } catch (e) {
      debugPrint("Geocoding Error: $e");
    }
  }

  Future<void> _checkForArrival(Position pos) async {
    final response = await supabase
        .from('tickets')
        .select()
        .eq('bus_id', widget.busId)
        .filter('alighted_at', 'is', null);

    final activeTickets = List<Map<String, dynamic>>.from(response);
    int droppedCount = 0;

    for (var ticket in activeTickets) {
      final destLat = ticket['dest_lat']; 
      final destLong = ticket['dest_long'];

      if (destLat != null && destLong != null) {
        double dist = Geolocator.distanceBetween(pos.latitude, pos.longitude, destLat, destLong);
        if (dist < 150) { 
           await _dropPassenger(ticket['id']);
           droppedCount++;
        }
      }
    }

    if (droppedCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$droppedCount passengers arrived & dropped."), backgroundColor: Colors.orange)
      );
    }
  }

  Future<void> _dropPassenger(String ticketId) async {
    await supabase.from('tickets').update({'alighted_at': DateTime.now().toIso8601String()}).eq('id', ticketId);
    await supabase.rpc('decrement_occupancy', params: {'bus_id_param': widget.busId, 'count_param': 1});
  }

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
      debugPrint("Error fetching rules: $e");
    }
    return {'base': 10.0, 'rate': 5.0};
  }

  Future<void> _getRealtimeFare() async {
    if (_sourcePlace == null || _destPlace == null) return;

    setState(() => _isCalculatingFare = true);

    try {
      final rules = await _fetchFareRules();
      final baseFare = rules['base']!;
      final ratePerKm = rules['rate']!;

      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${_sourcePlace!.lat},${_sourcePlace!.long}"
        "&destination=${_destPlace!.lat},${_destPlace!.long}"
        "&mode=transit&key=$googleMapsApiKey"
      );

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final leg = data['routes'][0]['legs'][0];
        final int distanceMeters = leg['distance']['value'];
        final double distanceKm = distanceMeters / 1000.0;
        final double totalFare = baseFare + (distanceKm * ratePerKm);

        if (mounted) {
          setState(() {
            _tripDistance = distanceKm;
            _calculatedFare = totalFare.ceilToDouble();
            _isCalculatingFare = false;
          });
        }
      } else {
        throw "Google Map Error: ${data['status']}";
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCalculatingFare = false;
          _calculateFallbackFare(); 
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("API Error, using estimate: $e")));
      }
    }
  }

  void _calculateFallbackFare() {
     double meters = Geolocator.distanceBetween(
      _sourcePlace!.lat, _sourcePlace!.long, 
      _destPlace!.lat, _destPlace!.long
    );
    double km = meters / 1000;
    setState(() {
      _tripDistance = km;
      _calculatedFare = (15 + (km * 8)).ceilToDouble();
    });
  }

  Future<void> _processBooking() async {
    if (_sourcePlace == null || _destPlace == null) return;

    setState(() => _isIssuing = true);

    try {
      await supabase.from('tickets').insert({
        'bus_id': widget.busId,
        'route_id': widget.routeId,
        'source_name': _sourcePlace!.name,
        'dest_name': _destPlace!.name,
        'dest_lat': _destPlace!.lat,
        'dest_long': _destPlace!.long,
        'amount_paid': _calculatedFare.toInt(),
        'issued_at': DateTime.now().toIso8601String(),
      });
      
      await supabase.rpc('increment_occupancy', params: {'bus_id_param': widget.busId});
      
      if (mounted) {
        setState(() { 
          _isIssuing = false; 
          _destPlace = null; 
          _calculatedFare = 0.0;
          _tripDistance = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket Issued"), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _isIssuing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _openSearch(bool isSource) async {
    try {
      final sessionToken = const Uuid().v4();
      final places = ws.GoogleMapsPlaces(
        apiKey: googleMapsApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );

      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: googleMapsApiKey,
        mode: Mode.overlay,
        language: "en",
        sessionToken: sessionToken,
        types: ["transit_station"],
        hint: "Search Bus Stop...",
        components: [const Component(Component.country, "in")],
        onError: (response) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.errorMessage ?? "Error"), backgroundColor: Colors.red),
            );
          }
        },
      );

      if (p != null && p.placeId != null) {
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
          });
          
          await _getRealtimeFare();
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Ticketing", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageOccupancyScreen(busId: widget.busId))),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const ConductorHomeScreen()), (r) => false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _busStream,
              builder: (context, snapshot) {
                String plateNumber = "...";
                int seatsLeft = 0;
                
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final busData = snapshot.data!.first;
                  plateNumber = busData['license_plate'] ?? "Unknown";
                  seatsLeft = busData['seats_available'] ?? 0;
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.green[900] : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("BUS: $plateNumber", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.my_location, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Container(
                                constraints: const BoxConstraints(maxWidth: 150),
                                child: Text(
                                  _currentLocationName, 
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text("$seatsLeft", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                          Text("Seats Left", style: TextStyle(fontSize: 10, color: textColor)),
                        ],
                      )
                    ],
                  ),
                );
              }
            ),

            const SizedBox(height: 24),
            
            Card(
              elevation: 4,
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Issue Ticket", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const Divider(height: 30),

                    _buildMapInput(
                      label: "Source",
                      value: _sourcePlace?.name,
                      icon: Icons.trip_origin,
                      color: Colors.blue,
                      onTap: () => _openSearch(true),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Container(height: 20, width: 2, color: Colors.grey[300]),
                    ),

                    _buildMapInput(
                      label: "Destination",
                      value: _destPlace?.name,
                      icon: Icons.location_on,
                      color: Colors.red,
                      onTap: () => _openSearch(false),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Distance", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              Text("${_tripDistance.toStringAsFixed(1)} km", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("TOTAL FARE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                              _isCalculatingFare 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text("₹$_calculatedFare", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blue)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.print),
                        label: _isIssuing 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text("GENERATE TICKET"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: (_isIssuing || _isCalculatingFare || _calculatedFare == 0) ? null : _processBooking,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapInput({required String label, String? value, required IconData icon, required Color color, required VoidCallback onTap}) {
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
              child: Text(
                value ?? "Search $label",
                style: TextStyle(
                  color: value == null ? Colors.grey : textColor,
                  fontWeight: value == null ? FontWeight.normal : FontWeight.bold,
                  fontSize: 16
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.search, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}