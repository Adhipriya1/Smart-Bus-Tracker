import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCollectionsScreen extends StatelessWidget {
  const AdminCollectionsScreen({super.key});

  String _formatDate(String? isoDate) {
    if (isoDate == null) return "Unknown Date";
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day}/${date.month}/${date.year}"; 
    } catch (e) {
      return isoDate;
    }
  }

  // Function to delete a record with confirmation
  Future<void> _deleteRecord(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Record?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Supabase.instance.client.from('daily_collections').delete().eq('id', id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Record deleted successfully.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Daily Collections")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('daily_collections')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No collections recorded yet."));
          }

          final collections = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: collections.length,
            itemBuilder: (ctx, i) {
              final item = collections[i];
              final amount = item['amount_collected'] ?? 0;
              final busId = item['bus_id'] ?? "Unknown Bus";
              final dateStr = _formatDate(item['date']);
              final id = item['id'];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isDark ? Colors.grey[800] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // --- TOP SECTION: DETAILS ---
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: const Icon(Icons.directions_bus, color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                busId, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text("Date: ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                  Text(
                                    dateStr, 
                                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(),
                      ),
                      
                      // --- BOTTOM SECTION: RATE & DELETE BUTTON ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // RATE (Amount)
                          Row(
                            children: [
                              const Text("Total: ", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                "₹$amount", 
                                style: const TextStyle(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.w800, 
                                  color: Colors.green
                                ),
                              ),
                            ],
                          ),
                          
                          // DELETE BUTTON
                          ElevatedButton.icon(
                            onPressed: () => _deleteRecord(context, id),
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                            label: const Text("Delete"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          )
                        ],
                      )
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