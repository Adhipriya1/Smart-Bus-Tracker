import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/passenger/screens/home_map_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import

class AdminBusSelectScreen extends StatefulWidget {
  const AdminBusSelectScreen({super.key});

  @override
  State<AdminBusSelectScreen> createState() => _AdminBusSelectScreenState();
}

class _AdminBusSelectScreenState extends State<AdminBusSelectScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText("Select Bus to Track"),
        backgroundColor: Colors.blue[900], 
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('buses')
            .stream(primaryKey: ['id'])
            .eq('is_active', true)
            .order('license_plate', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: TranslatedText("No active buses found."));

          final buses = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              final plate = bus['license_plate'] ?? "Unknown Bus";
              final seats = bus['seats_available'] ?? 0;
              final isMoving = bus['current_latitude'] != null;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isMoving ? Colors.green[100] : Colors.grey[200],
                    child: Icon(Icons.directions_bus, color: isMoving ? Colors.green : Colors.grey),
                  ),
                  title: Text(plate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Row(
                    children: [
                      if (isMoving) ...[
                        const TranslatedText("Active • ", style: TextStyle(color: Colors.green)),
                        Text("$seats ", style: const TextStyle(color: Colors.green)),
                        const TranslatedText("seats free", style: TextStyle(color: Colors.green)),
                      ] else 
                        const TranslatedText("Location unavailable", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PassengerMapScreen(focusedBusId: bus['id'])));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}