import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; 
import 'package:smart_bus_tracker/common/services/places_service.dart';
import 'package:smart_bus_tracker/common/widgets/language_selector.dart';

class PassengerMapScreen extends StatefulWidget {
  final String? focusedBusId;

  const PassengerMapScreen({super.key, this.focusedBusId});

  @override
  State<PassengerMapScreen> createState() => _PassengerMapScreenState();
}

class _PassengerMapScreenState extends State<PassengerMapScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final PlacesService _placesService = PlacesService();
  GoogleMapController? _mapController;
  final String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Set<Marker> _busMarkers = {};
  Set<Marker> _stopMarkers = {};
  Set<Polyline> _polylines = {}; 
  LatLng? _userLocation;
  String _etaText = "Locating bus...";
  
  StreamSubscription? _busSubscription;
  Timer? _directionsTimer;
  
  // 🔴 STRICT THROTTLING VARIABLES
  Timer? _throttleTimer;
  List<Map<String, dynamic>>? _pendingData;
  bool _isProcessing = false;

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777), // Mumbai Default
    zoom: 14, 
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
    _throttleTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    final latLng = LatLng(pos.latitude, pos.longitude);
    
    if (mounted) {
      setState(() => _userLocation = latLng);
      if (widget.focusedBusId == null) {
        _fetchBusStops(latLng);
      }
    }
  }

  Future<void> _fetchBusStops(LatLng center) async {
    final stops = await _placesService.getNearbyBusStops(center);
    if (mounted) {
      setState(() {
        _stopMarkers = stops.toSet();
      });
    }
  }

  double? _parseCoord(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _subscribeToBusUpdates() {
    _busSubscription = supabase
        .from('buses')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      
      // 1. Store the latest data immediately
      _pendingData = data;

      // 2. Only start the timer if it's not already running
      if (!_isProcessing) {
        _isProcessing = true;
        // 🔴 UPDATE INTERVAL: 1 Second (1000ms). This is safe for any device.
        _throttleTimer = Timer(const Duration(milliseconds: 1000), _processPendingData);
      }
    });
  }

  void _processPendingData() {
    if (!mounted || _pendingData == null) {
      _isProcessing = false;
      return;
    }

    final data = _pendingData!;
    _pendingData = null; // Clear queue

    final newMarkers = data.map((busData) {
      final int seats = busData['seats_available'] ?? 0;
      final double? lat = _parseCoord(busData['current_latitude']) ?? _parseCoord(busData['lat']);
      final double? long = _parseCoord(busData['current_longitude']) ?? _parseCoord(busData['long']);
      final String plate = busData['license_plate'] ?? "Bus";

      if (lat == null || long == null) return null; 

      final double hue = seats < 5 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen;

      return Marker(
        markerId: MarkerId(busData['id'].toString()),
        position: LatLng(lat, long),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(title: plate, snippet: "Seats Left: $seats"),
        onTap: () {
          _fetchBusStops(LatLng(lat, long));
        },
      );
    }).whereType<Marker>().toSet();

    // Handle Focused Bus Animation (Also Throttled now)
    if (widget.focusedBusId != null) {
      try {
        final focusedBus = data.firstWhere(
          (element) => element['id'] == widget.focusedBusId,
          orElse: () => {},
        );
        
        if (focusedBus.isNotEmpty) {
            final double? lat = _parseCoord(focusedBus['current_latitude']) ?? _parseCoord(focusedBus['lat']);
            final double? long = _parseCoord(focusedBus['current_longitude']) ?? _parseCoord(focusedBus['long']);
            
            if (lat != null && long != null) {
              final busPos = LatLng(lat, long);
              _mapController?.animateCamera(CameraUpdate.newLatLng(busPos));
              
              if (_userLocation != null) {
                _fetchDirections(busPos, _userLocation!);
              }
            }
        }
      } catch (e) {
        debugPrint("Error processing focused bus: $e");
      }
    }

    setState(() {
      _busMarkers = newMarkers;
    });

    // Allow next update
    _isProcessing = false; 
  }

  Future<void> _fetchDirections(LatLng origin, LatLng dest) async {
    if (_directionsTimer != null && _directionsTimer!.isActive) return;
    _directionsTimer = Timer(const Duration(seconds: 10), () {});

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
      appBar: AppBar(
        title: const TranslatedText("Live Tracking"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageButton(), 
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kInitialPosition,
            markers: _busMarkers.union(_stopMarkers),
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
            onCameraIdle: () {}, // Do nothing on idle to prevent loops
          ),

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
                          const TranslatedText("Estimated Arrival", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          TranslatedText(
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