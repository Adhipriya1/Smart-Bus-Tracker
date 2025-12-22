import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/admin/screens/admin_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bus, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text("Smart Bus Tracker", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 60),
            
            // 1. PASSENGER LOGIN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person, color: Colors.white), // Fixed color for contrast
                label: const Text("Passenger Login", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/passenger-login'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 2. CONDUCTOR LOGIN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.badge, color: Colors.black), // Changed icon to badge for professional look
                label: const Text("Conductor Login", style: TextStyle(color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/conductor-login'),
              ),
            ),

            const SizedBox(height: 30),

            // 3. ADMIN LOGIN (New Addition)
            // Using a discreet TextButton or subtle OutlinedButton
            TextButton.icon(
              icon: const Icon(Icons.admin_panel_settings, size: 18, color: Colors.grey),
              label: const Text("Admin Access", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              onPressed: () {
                // Navigate directly to the Admin Login file
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen())
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}