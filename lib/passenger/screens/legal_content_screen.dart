import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';

class LegalContentScreen extends StatelessWidget {
  final String title;
  final String contentType; 

  const LegalContentScreen({super.key, required this.title, required this.contentType});

  @override
  Widget build(BuildContext context) {
    String content = "";
    
    if (contentType == 'terms') {
      content = """
1. Acceptance of Terms
By accessing and using the Smart Bus App, you accept and agree to be bound by the terms and provision of this agreement.

2. Use of Service
You agree to use this app only for lawful purposes. Misuse of the ticketing system or harassment of staff may result in account termination.

3. Ticketing & Refunds
All tickets purchased are digital. Refunds are subject to the operator's policy. Smart Bus is a facilitator and not responsible for bus delays.

4. User Accounts
You are responsible for maintaining the confidentiality of your password and account.
      """;
    } else {
      content = """
1. Information Collection
We collect information you provide directly to us, such as your name, email address, and payment information when you purchase tickets.

2. Location Data
To provide real-time tracking, we may access your location data while the app is in use.

3. Data Security
We implement appropriate security measures to protect your personal data from unauthorized access.

4. Third-Party Services
We may share data with bus operators solely for the purpose of fulfilling your travel request.
      """;
    }

    return Scaffold(
      appBar: AppBar(title: TranslatedText(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TranslatedText(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}