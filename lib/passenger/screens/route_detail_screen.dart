import 'package:flutter/material.dart';
import 'home_map_screen.dart'; // Reuse your map

class RouteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> busData;
  const RouteDetailScreen({super.key, required this.busData});

  @override
  Widget build(BuildContext context) {
    // Logic for Availability
    final int capacity = busData['seating_capacity'] ?? 40;
    final int occupied = busData['seats_occupied'] ?? 0;
    final int available = capacity - occupied;
    final double fillPercentage = occupied / capacity;

    String statusText = "Comfortable";
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.sentiment_satisfied_alt;

    if (fillPercentage > 0.9) {
      statusText = "RUSHED / FULL";
      statusColor = Colors.red;
      statusIcon = Icons.groups;
    } else if (fillPercentage > 0.6) {
      statusText = "Medium Crowd";
      statusColor = Colors.orange;
      statusIcon = Icons.group;
    }

    return Scaffold(
      appBar: AppBar(title: Text(busData['license_plate'])),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // 1. CROWD STATUS CARD
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor, width: 4),
              ),
              child: Column(
                children: [
                  Icon(statusIcon, size: 50, color: statusColor),
                  const SizedBox(height: 10),
                  Text(statusText, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: statusColor)),
                  const SizedBox(height: 5),
                  Text("$available seats free", style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // 2. LIVE DELAY INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.timer, color: Colors.blue),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Estimated Arrival", style: TextStyle(color: Colors.grey)),
                      Text("5 mins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),

            const Spacer(),

            // 3. TRACK ON MAP BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
                icon: const Icon(Icons.map),
                label: const Text("TRACK ON MAP", style: TextStyle(fontSize: 18)),
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => PassengerMapScreen(focusedBusId: busData['id'])));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}