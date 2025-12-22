class Bus {
  final String id;
  final String routeId;
  final String licensePlate;
  final int capacity;
  final int seatsOccupied;
  final double? lat;
  final double? long;

  Bus({
    required this.id,
    required this.routeId,
    required this.licensePlate,
    required this.capacity,
    required this.seatsOccupied,
    this.lat,
    this.long,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      routeId: json['route_id'],
      licensePlate: json['license_plate'],
      capacity: json['seating_capacity'],
      seatsOccupied: json['seats_occupied'] ?? 0, // Ensure SQL trigger updates this
      lat: (json['current_latitude'] as num?)?.toDouble(),
      long: (json['current_longitude'] as num?)?.toDouble(),
    );
  }
  
  // Helper to calculate available seats
  int get seatsAvailable => capacity - seatsOccupied;
}