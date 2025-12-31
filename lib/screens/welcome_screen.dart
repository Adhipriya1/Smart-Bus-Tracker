import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/admin/screens/admin_login_screen.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; 
import 'package:smart_bus_tracker/common/widgets/language_selector.dart'; 

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 DETECT LANGUAGE: Check if current language is Tamil ('ta')
    final bool isTamil = Localizations.localeOf(context).languageCode == 'ta';

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: Column(
          children: [
            // 🌐 LANGUAGE SELECTOR (TOP RIGHT)
            const Align(
              alignment: Alignment.topRight,
              child: LanguageButton(), 
            ),

            const Spacer(),

            // 1️⃣ LOGO & TITLE
            const Icon(Icons.directions_bus_filled, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            TranslatedText(
              "Smart Bus Tracker",
              style: TextStyle(
                // 🟢 Reduced Font Size for Tamil
                fontSize: isTamil ? 18 : 28, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TranslatedText(
              "Track your journey in real-time",
              // 🟢 Reduced Font Size for Tamil
              style: TextStyle(fontSize: isTamil ? 12 : 16, color: Colors.grey),
            ),

            const Spacer(),

            // 2️⃣ PASSENGER LOGIN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person, color: Colors.white),
                label: TranslatedText(
                  "Passenger Login",
                  // 🟢 Reduced Font Size for Tamil
                  style: TextStyle(fontSize: isTamil ? 12 : 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, '/passenger-login'),
              ),
            ),

            const SizedBox(height: 16),

            // 3️⃣ CONDUCTOR LOGIN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.badge, color: Colors.black),
                label: TranslatedText(
                  "Conductor Login",
                  // 🟢 Reduced Font Size for Tamil
                  style: TextStyle(color: Colors.black, fontSize: isTamil ? 12 : 18),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, '/conductor-login'),
              ),
            ),

            const SizedBox(height: 30),

            // 4️⃣ ADMIN ACCESS
            TextButton.icon(
              icon: const Icon(
                Icons.admin_panel_settings,
                size: 18,
                color: Colors.grey,
              ),
              label: TranslatedText(
                "Admin Access",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: isTamil ? 12 : 14,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminLoginScreen(),
                  ),
                );
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}