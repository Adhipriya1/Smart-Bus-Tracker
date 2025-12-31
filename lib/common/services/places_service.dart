import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesService {
  late GoogleMapsPlaces _places;

  PlacesService() {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    _places = GoogleMapsPlaces(apiKey: apiKey);
  }

  Future<List<Marker>> getNearbyBusStops(LatLng location) async {
    try {
      final response = await _places.searchNearbyWithRadius(
        Location(lat: location.latitude, lng: location.longitude),
        1000, // 1km radius
        type: "bus_station",
      );

      if (response.status == "OK") {
        return response.results.map((place) {
          return Marker(
            markerId: MarkerId(place.placeId),
            position: LatLng(place.geometry!.location.lat, place.geometry!.location.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(title: place.name, snippet: "Bus Stop"),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}