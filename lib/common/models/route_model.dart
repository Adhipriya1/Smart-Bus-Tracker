
class RouteStop {
  final String id;
  final String name;
  final int sequence;
  final double? lat;
  final double? long;

  RouteStop({required this.id, required this.name, required this.sequence,required this.lat,required this.long});

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'],
      name: json['stop_name'],
      sequence: json['sequence_order'],
      lat: (json['latitude'] as num?)?.toDouble(),
      long: (json['longitude'] as num?)?.toDouble(),
    );
  }
}