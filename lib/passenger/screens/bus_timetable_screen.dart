import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import
import 'package:supabase_flutter/supabase_flutter.dart';

class BusTimetableScreen extends StatelessWidget {
  const BusTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText("Real-Time Timetable"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('routes').stream(primaryKey: ['id']).order('route_number'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final routes = snapshot.data!;

          if (routes.isEmpty) return const Center(child: TranslatedText("No routes active"));

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              // Random time simulation for demo
              final nextBusIn = (index + 1) * 5; 

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  route['route_number'], 
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(route['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.green.withOpacity(0.1) : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.green.withOpacity(0.3) : Colors.green.shade100
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TranslatedText(
                              "NEXT BUS IN", 
                              style: TextStyle(
                                fontSize: 12, 
                                color: isDark ? Colors.green[100] : Colors.green[800], 
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$nextBusIn min", 
                              style: TextStyle(
                                color: isDark ? Colors.green[300] : Colors.green[700], 
                                fontWeight: FontWeight.bold, 
                                fontSize: 18
                              ),
                            ),
                          ],
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