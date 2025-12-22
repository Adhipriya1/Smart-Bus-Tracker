import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/theme_manager.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'report_issue_screen.dart';
import 'conductor_documents_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = themeNotifier.value == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    final sectionColor = Theme.of(context).brightness == Brightness.dark ? Colors.blue[200] : Colors.blue[900];

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          _buildSectionHeader("Account", sectionColor),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.folder_shared_outlined),
            title: const Text("My Documents"),
            subtitle: const Text("Upload License, Aadhar, PAN"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConductorDocumentsScreen())),
          ),

          const Divider(),

          _buildSectionHeader("Preferences", sectionColor),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text("Dark Theme"),
            value: _isDarkTheme,
            onChanged: (val) {
              setState(() => _isDarkTheme = val);
              toggleTheme(val); 
            },
          ),

          const Divider(),

          _buildSectionHeader("Support & Legal", sectionColor),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text("Report Bug"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIssueScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color? color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}