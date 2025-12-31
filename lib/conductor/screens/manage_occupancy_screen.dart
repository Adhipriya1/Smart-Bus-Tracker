import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ManageOccupancyScreen extends StatefulWidget {
  final String busId;
  const ManageOccupancyScreen({super.key, required this.busId});

  @override
  State<ManageOccupancyScreen> createState() => _ManageOccupancyScreenState();
}

class _ManageOccupancyScreenState extends State<ManageOccupancyScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Function to drop a passenger
  Future<void> _dropPassenger(String ticketId) async {
    try {
      // 1. Mark ticket as alighted (dropped)
      await supabase.from('tickets').update({
        'alighted_at': DateTime.now().toIso8601String()
      }).eq('id', ticketId);

      // 2. Decrease bus occupancy count
      await supabase.rpc('decrement_occupancy', params: {
        'bus_id_param': widget.busId,
        'count_param': 1
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passenger Dropped", style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange)
        );
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.errorSending(e) ?? 'Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme variables
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[800];
    final cardColor = Theme.of(context).cardTheme.color;

    // REALTIME STREAM: Listens for any changes in the tickets table
    final passengerStream = supabase
        .from('tickets')
        .stream(primaryKey: ['id'])
        .eq('bus_id', widget.busId)
        .order('issued_at', ascending: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Passenger List")),
      // Switched from FutureBuilder to StreamBuilder for Realtime updates
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: passengerStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(isDark);
          }

          // Filter locally to show only those who haven't dropped yet
          final activeTickets = snapshot.data!.where((t) => t['alighted_at'] == null).toList();

          if (activeTickets.isEmpty) {
             return _buildEmptyState(isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeTickets.length,
            itemBuilder: (context, index) {
              final ticket = activeTickets[index];
              
              // 1. Get Short Ticket ID
              final ticketId = ticket['id'].toString().split('-').first.toUpperCase();
              
              // 2. Get Destination Name
              final destName = ticket['dest_name'] ?? "Unknown Stop";

              // 3. Get Amount
              final amount = ticket['amount_paid'] ?? 0;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // TOP SECTION: Ticket Details
                      Row(
                        children: [
                          // Ticket Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.directions_bus_filled, color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          
                          // DETAILS COLUMN
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ticket #$ticketId",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: isDark ? Colors.grey : Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    const Text("To: ", style: TextStyle(color: Colors.grey)), // Added prefix
                                    Expanded(
                                      child: Text(
                                        destName,
                                        style: TextStyle(color: subTextColor, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Paid: ₹$amount",
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16), // Spacing
                      
                      // BOTTOM SECTION: Full Width Drop Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: Colors.red.withOpacity(0.3)),
                          ),
                          onPressed: () => _dropPassenger(ticket['id']),
                          child: const Text("DROP PASSENGER", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_seat, size: 60, color: isDark ? Colors.grey[600] : Colors.grey),
          const SizedBox(height: 10),
          const Text("Bus is Empty", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }
}