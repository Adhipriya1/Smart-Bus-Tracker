import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_map_screen.dart'; // Ensure this points to your PassengerMapScreen

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Stream that listens to changes in the 'buses' table instantly
  late final Stream<List<Map<String, dynamic>>> _busesStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream ordered by license plate
    _busesStream = supabase
        .from('buses')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('license_plate', ascending: true);
  }

  @override
  Widget build(BuildContext context) {
    // Theme awareness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = Theme.of(context).cardTheme.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Bus"),
      ),
      // Switch to StreamBuilder for Realtime Updates
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _busesStream,
        builder: (context, snapshot) {
          // 1. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handle Error State
          if (snapshot.hasError) {
            return Center(child: Text("Error loading buses: ${snapshot.error}"));
          }

          // 3. Handle Empty State
          final buses = snapshot.data ?? [];
          if (buses.isEmpty) {
            return const Center(child: Text("No active buses found."));
          }

          // 4. Build the List
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              
              // LOGIC CHANGE: Use 'seats_available' directly (matches Conductor App)
              final int seatsLeft = bus['seats_available'] ?? 0;
              final String plate = bus['license_plate'] ?? "Unknown Bus";
              
              // Color logic: Red if low seats (< 5), Green otherwise
              final seatColor = seatsLeft < 5 ? Colors.red : Colors.green;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOP SECTION: Bus Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.directions_bus, color: Colors.blue, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plate,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.event_seat, size: 14, color: seatColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$seatsLeft seats available",
                                      style: TextStyle(
                                        color: seatColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
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
                          label:  const Text("TRACK LIVE LOCATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Ensure this maps to your PassengerMapScreen class
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