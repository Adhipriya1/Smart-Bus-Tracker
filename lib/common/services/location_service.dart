import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  // Config
  static const int _interval = 5; // 5 seconds
  static const int _distanceFilter = 10; // 10 meters

  // Request Permissions
  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  // Get Stream
  Stream<Position> getStream() {
    late LocationSettings settings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _distanceFilter,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: _interval),
        // Optional: Keep alive in background with notification
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "SmartBus Active",
          notificationText: "Broadcasting location...",
          enableWakeLock: true,
        ),
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _distanceFilter,
      );
    }

    return Geolocator.getPositionStream(locationSettings: settings);
  }
}