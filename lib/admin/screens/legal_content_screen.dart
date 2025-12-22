import 'package:flutter/material.dart';


class LegalContentScreen extends StatelessWidget {
  final String title;
  final String contentType; // 'terms' or 'privacy'

  const LegalContentScreen({
    super.key,
    required this.title,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    String content = "";

    if (contentType == "terms") {
      content = """
**Terms and Conditions**

1. Usage: By using this app, you agree to track buses responsibly.
2. Conduct: Do not misuse the SOS feature.
3. Account: You are responsible for your account security.

(This is placeholder text for the Smart Bus App)
""";
    } else {
      content = """
**Privacy Policy**

1. Data Collection: We collect your email and location data for tracking.
2. Sharing: We do not sell your data to third parties.
3. Security: Your data is stored securely on Supabase.

(This is placeholder text for the Smart Bus App)
""";
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}