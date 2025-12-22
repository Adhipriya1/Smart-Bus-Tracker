import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text("Please Log In")));

    return Scaffold(
      appBar: AppBar(title: const Text("My Rides")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // REAL TIME STREAM
        stream: supabase
            .from('passenger_trips')
            .stream(primaryKey: ['id'])
            .eq('passenger_id', user.id)
            .order('start_time', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final trips = snapshot.data!;

          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bus_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("No rides yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              final isCompleted = trip['status'] == 'completed';
              
              // Formatting timestamp (Simple split for demo)
              final date = trip['start_time'].toString().split(' ')[0];
              final time = trip['start_time'].toString().split(' ')[1].substring(0, 5);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCompleted ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                    child: Icon(isCompleted ? Icons.check : Icons.directions_bus, color: isCompleted ? Colors.green : Colors.blue),
                  ),
                  title: Text(isCompleted ? "Completed Trip" : "Ongoing Trip", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("$date at $time"),
                  trailing: trip['rating'] != null
                      ? Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text(" ${trip['rating']}")])
                      : (isCompleted ? const Text("Rate Now", style: TextStyle(color: Colors.orange, fontSize: 12)) : null),
                ),
              );
            },
          );
        },
      ),
    );
  }
}