import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/theme_manager.dart';
import 'package:smart_bus_tracker/passenger/screens/passenger_edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'report_bug_screen.dart';
import 'legal_content_screen.dart';

class PassengerSettingsScreen extends StatefulWidget {
  const PassengerSettingsScreen({super.key});

  @override
  State<PassengerSettingsScreen> createState() => _PassengerSettingsScreenState();
}

class _PassengerSettingsScreenState extends State<PassengerSettingsScreen> {
  bool _darkTheme = themeNotifier.value == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          _buildSectionHeader("Account"),
          _buildTile(Icons.person_outline, "Edit Profile", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerEditProfileScreen()));
          }),
          _buildTile(Icons.lock_outline, "Change Password", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
          }),
          
          const Divider(),
          _buildSectionHeader("Preferences"),
          
          SwitchListTile(
            secondary: Icon(Icons.dark_mode_outlined, color: Colors.grey[600]),
            title: Text("Dark Theme", style: TextStyle(color: textColor)),
            value: _darkTheme,
            onChanged: (val) {
              setState(() => _darkTheme = val);
              toggleTheme(val);
            },
          ),
          
          const Divider(),
          _buildSectionHeader("Support"),
          _buildTile(Icons.bug_report_outlined, "Report Bug", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportBugScreen()));
          }),
          _buildTile(Icons.description_outlined, "Terms and Conditions", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(title: "Terms", contentType: "terms")));
          }),
          _buildTile(Icons.privacy_tip_outlined, "Privacy Policy", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(title: "Privacy", contentType: "privacy")));
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTile(IconData icon, String title, {required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}