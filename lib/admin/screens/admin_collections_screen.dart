import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import

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

  Future<void> _deleteRecord(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TranslatedText("Delete Record?"),
        content: const TranslatedText("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const TranslatedText("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const TranslatedText("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Supabase.instance.client.from('daily_collections').delete().eq('id', id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Daily Collections")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('daily_collections').stream(primaryKey: ['id']).order('date', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final data = snapshot.data ?? [];
          if (data.isEmpty) return const Center(child: TranslatedText("No collections recorded yet."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final record = data[index];
              final amount = record['amount_collected'];
              final date = _formatDate(record['date']);
              final busId = record['bus_id'] ?? 'Unknown Bus';
              final id = record['id'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TranslatedText("Date: $date", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                            child: Text(busId, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const TranslatedText("Total: ", style: TextStyle(fontWeight: FontWeight.bold)),
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
                          
                          ElevatedButton.icon(
                            onPressed: () => _deleteRecord(context, id),
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                            label: const TranslatedText("Delete", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
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