import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusTimetableScreen extends StatelessWidget {
  const BusTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    
    // Theme Awareness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final cardColor = Theme.of(context).cardTheme.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Real-Time Timetable"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('routes').stream(primaryKey: ['id']).order('route_number'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final routes = snapshot.data!;

          if (routes.isEmpty) return const Center(child: Text("No routes active"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              final duration = route['estimated_duration_mins'] ?? 60;
              
              // --- REAL TIME LOGIC ---
              final now = DateTime.now();
              const freq = 20; 
              final nextBusIn = freq - (now.minute % freq);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TOP SECTION: Route Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              route['route_number'], 
                              style: TextStyle(
                                color: isDark ? Colors.blue[200] : Colors.blue, 
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  route['name'], 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined, size: 14, color: subTextColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Duration: $duration mins", 
                                      style: TextStyle(color: subTextColor, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 2. BOTTOM SECTION: Next Bus Indicator (Full Width)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50, 
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.green.withOpacity(0.3) : Colors.green.shade100
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
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