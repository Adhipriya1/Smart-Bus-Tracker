import 'package:flutter/material.dart';


class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help & About"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.directions_bus_filled, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text("Smart Bus Tracker", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const Center(
              child: Text("Version 1.0.0 (Beta)", style: TextStyle(color: Colors.grey)),
            ),
            const Divider(height: 40),
            
            const Text("About the App", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "Smart Bus Tracker helps conductors manage ticketing, track bus location in real-time, and manage passenger occupancy efficiently. This app is designed to streamline public transport operations.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            
            const SizedBox(height: 30),
            const Text("License Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration( borderRadius: BorderRadius.circular(8)),
              child: const Text(
                "Copyright © 2025 Smart Bus Inc.\nAll rights reserved.\n\nLicensed under the Apache License, Version 2.0.",
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const SizedBox(height: 30),
            const Center(
              child: Text("Need Support?", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Center(
              child: Text("contact@smartbus.com", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}