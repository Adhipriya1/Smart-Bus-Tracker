import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AdminReviewsScreen extends StatelessWidget {
  const AdminReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check for dark mode to adjust colors dynamically
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Ride Reviews")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('reviews')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No reviews yet"),
                ],
              ),
            );
          }

          final reviews = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (ctx, i) {
              final r = reviews[i];
              final rating = r['rating'] ?? 0;
              final comment = r['comment'] ?? "";
              final passenger = r['passenger_name'] ?? "Anonymous";
              final busId = r['bus_id'] ?? "Unknown";

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isDark ? Colors.grey[800] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER: Bus Info ---
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.directions_bus, size: 20, color: Colors.blue),
                          ),
                          const SizedBox(width: 10),
                          const Text("Bus: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            busId, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(),
                      ),

                      // --- STAR RATING ---
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 26, 
                            );
                          }),
                          const SizedBox(width: 10),
                          Text(
                            "$rating/5", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),

                      // --- COMMENT SECTION ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.grey[100], 
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!)
                        ),
                        child: comment.isNotEmpty 
                          ? Text(comment, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))
                          : const Text("No additional comments provided.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                      ),

                      const SizedBox(height: 8),

                      // --- FOOTER: PASSENGER NAME ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "- $passenger",
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
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