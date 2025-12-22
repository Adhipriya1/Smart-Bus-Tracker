import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class PassengerMapScreen extends StatefulWidget {
  final String? focusedBusId;

  const PassengerMapScreen({
    super.key,
    this.focusedBusId,
  });

  @override
  State<PassengerMapScreen> createState() => _PassengerMapScreenState();
}

class _PassengerMapScreenState extends State<PassengerMapScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  GoogleMapController? _mapController;
  final String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {}; // To store the route line
  LatLng? _userLocation;
  String _etaText = "Locating bus...";
  
  StreamSubscription? _busSubscription;
  Timer? _directionsTimer; // Throttle API calls

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _subscribeToBusUpdates();
  }

  @override
  void dispose() {
    _busSubscription?.cancel();
    _directionsTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // 1. GET USER LOCATION
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _userLocation = LatLng(pos.latitude, pos.longitude);
      });
    }
  }

  // 2. BUS UPDATES STREAM
  void _subscribeToBusUpdates() {
    _busSubscription = supabase
        .from('buses')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      
      final newMarkers = data.map((busData) {
        final int seats = busData['seats_available'] ?? 0;
        final double? lat = busData['current_latitude'] as double?; 
        final double? long = busData['current_longitude'] as double?;
        final String plate = busData['license_plate'] ?? "Bus";

        if (lat == null || long == null) return null; 

        final double hue = seats < 5 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen;

        return Marker(
          markerId: MarkerId(busData['id'].toString()),
          position: LatLng(lat, long),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(title: plate, snippet: "Seats Left: $seats"),
        );
      }).whereType<Marker>().toSet();

      // --- FOCUS & DIRECTIONS LOGIC ---
      if (widget.focusedBusId != null) {
        try {
          final focusedBus = data.firstWhere(
            (element) => element['id'] == widget.focusedBusId,
            orElse: () => {},
          );
          
          if (focusedBus.isNotEmpty) {
             final double? lat = focusedBus['current_latitude'];
             final double? long = focusedBus['current_longitude'];
             
             if (lat != null && long != null) {
                final busPos = LatLng(lat, long);
                
                // Animate Camera to Bus
                _mapController?.animateCamera(CameraUpdate.newLatLng(busPos));
                
                // Fetch Directions (Route Line)
                if (_userLocation != null) {
                  _fetchDirections(busPos, _userLocation!);
                }
             }
          }
        } catch (e) {
          debugPrint("Error processing focused bus: $e");
        }
      }

      if (mounted) {
        setState(() {
          _markers = newMarkers;
        });
      }
    });
  }

  // 3. DIRECTIONS API (Draws Line & Gets ETA)
  Future<void> _fetchDirections(LatLng origin, LatLng dest) async {
    // Throttle: Don't call API more than once every 5 seconds
    if (_directionsTimer != null && _directionsTimer!.isActive) return;
    
    _directionsTimer = Timer(const Duration(seconds: 5), () {});

    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${origin.latitude},${origin.longitude}"
        "&destination=${dest.latitude},${dest.longitude}"
        "&mode=transit"
        "&key=$googleMapsApiKey"
      );

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final route = data['routes'][0];
        final leg = route['legs'][0];
        
        final String duration = leg['duration']['text'];
        final String distance = leg['distance']['text'];

        // Decode Polyline
        final points = PolylinePoints.decodePolyline(route['overview_polyline']['points']);
        final List<LatLng> polylineCoords = points.map((p) => LatLng(p.latitude, p.longitude)).toList();

        if (mounted) {
          setState(() {
            _etaText = "$duration away ($distance)";
            _polylines = {
              Polyline(
                polylineId: const PolylineId("route"),
                color: Colors.blue,
                width: 5,
                points: polylineCoords,
              )
            };
          });
        }
      }
    } catch (e) {
      debugPrint("Directions API Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracking")),
      body: Stack(
        children: [
          // MAP
          GoogleMap(
            initialCameraPosition: _kInitialPosition,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
          ),

          // ETA CARD (Only if tracking a specific bus)
          if (widget.focusedBusId != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.directions_bus, color: Colors.blue, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Estimated Arrival", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            _etaText,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}