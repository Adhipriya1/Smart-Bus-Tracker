import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import
import 'package:smart_bus_tracker/common/services/translation_service.dart';
import 'package:smart_bus_tracker/common/widgets/language_selector.dart'; // Ensure LanguageSelector is available
import '../../common/theme_manager.dart';
import 'change_password_screen.dart';
import 'legal_content_screen.dart';
import 'admin_edit_profile_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _darkTheme = themeNotifier.value == ThemeMode.dark;
  bool _translateUserContent = true;

  @override
  void initState() {
    super.initState();
    // Assuming you have a getter for settings in TranslationService
    // TranslationService.instance.loadSettings().then((_) {
    //   setState(() => _translateUserContent = TranslationService.instance.isEnabled);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Admin Settings")),
      body: ListView(
        children: [
          // 1. Language Selector
          _buildSectionHeader("Preferences"),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TranslatedText("App Language"),
                LanguageButton(),
              ],
            ),
          ),

          const Divider(),

          // 2. Account Section
          _buildSectionHeader("Account"),
          _buildTile(Icons.person_outline, "Edit Profile", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEditProfileScreen()));
          }),
          _buildTile(Icons.lock_outline, "Change Password", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
          }),
          
          const Divider(),
          
          // 3. Theme Toggle
          SwitchListTile(
            secondary: Icon(Icons.dark_mode_outlined, color: Colors.grey[600]),
            title: TranslatedText("Dark Theme", style: TextStyle(color: textColor)),
            value: _darkTheme,
            onChanged: (val) {
              setState(() => _darkTheme = val);
              toggleTheme(val); 
            },
          ),

          // Translate user provided text toggle (Optional feature)
          
          SwitchListTile(
            secondary: Icon(Icons.translate, color: Colors.grey[600]),
            title: TranslatedText("Translate User Content", style: TextStyle(color: textColor)),
            value: _translateUserContent,
            onChanged: (val) async {
              // await TranslationService.instance.setEnabled(val);
              setState(() => _translateUserContent = val);
            },
          ),
          

          const Divider(),
          
          // 4. Support Section
          _buildSectionHeader("Support"),
          _buildTile(Icons.description_outlined, "Terms and Conditions", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(title: "Terms and Conditions", contentType: "terms")));
          }),
          _buildTile(Icons.privacy_tip_outlined, "Privacy Policy", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(title: "Privacy Policy", contentType: "privacy")));
          }),

          const Divider(),
          
          // 5. Session / Logout
          _buildSectionHeader("Session"),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const TranslatedText("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),

          const SizedBox(height: 30),
          Center(child: Text("Admin Portal v1.0.0", style: TextStyle(color: Colors.grey[500]))),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: TranslatedText(title, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTile(IconData icon, String title, {required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: TranslatedText(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}