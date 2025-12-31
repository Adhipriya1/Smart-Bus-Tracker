import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';
import 'home_map_screen.dart'; 

class RouteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> busData;
  const RouteDetailScreen({super.key, required this.busData});

  @override
  Widget build(BuildContext context) {
    // Logic for Availability
    final int capacity = busData['seating_capacity'] ?? 40;
    final int occupied = busData['seats_occupied'] ?? 0;
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
      appBar: AppBar(title: Text(busData['license_plate'])), // License plate is code
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // CROWD STATUS CARD
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
                  TranslatedText(
                    statusText, 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  const TranslatedText("Occupancy Status", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            ListTile(
              leading: const Icon(Icons.event_seat),
              title: const TranslatedText("Seats Available"),
              trailing: Text("${capacity - occupied}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const TranslatedText("Bus Type"),
              trailing: TranslatedText(busData['bus_type'] ?? "Standard"),
            ),

            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PassengerMapScreen(focusedBusId: busData['id'])));
                },
                icon: const Icon(Icons.map),
                label: const TranslatedText('View on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}