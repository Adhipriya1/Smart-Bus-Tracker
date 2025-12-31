import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_map_screen.dart'; 

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _busesStream;

  @override
  void initState() {
    super.initState();
    _busesStream = supabase
        .from('buses')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('license_plate', ascending: true);
  }

  // 🟢 HELPER: Determine Status based on seat count
  Widget _buildOccupancyBadge(int seats) {
    Color color;
    String statusText;
    IconData icon;

    if (seats > 20) {
      color = Colors.green;
      statusText = "LOW OCCUPANCY";
      icon = Icons.sentiment_satisfied_alt;
    } else if (seats > 5) {
      color = Colors.orange;
      statusText = "MEDIUM OCCUPANCY";
      icon = Icons.sentiment_neutral;
    } else {
      color = Colors.red;
      statusText = "HIGH OCCUPANCY";
      icon = Icons.sentiment_very_dissatisfied;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: color, 
              fontSize: 10, 
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Active Buses")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _busesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: TranslatedText("No active buses found."));
          }

          final buses = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              final int seats = bus['seats_available'] ?? 0;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // TOP SECTION: Bus Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.directions_bus, color: Colors.blue, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. License Plate
                                Text(
                                  bus['license_plate'], 
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // 2. Occupancy Badge (Moved Here)
                                _buildOccupancyBadge(seats),

                                const SizedBox(height: 8),
                                
                                // 3. Seat Count Text
                                Row(
                                  children: [
                                    const Icon(Icons.event_seat, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("$seats ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    const TranslatedText("Seats Available", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // BOTTOM SECTION: Track Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.location_on, size: 20),
                          label: const TranslatedText("TRACK LIVE LOCATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PassengerMapScreen(focusedBusId: bus['id']),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}