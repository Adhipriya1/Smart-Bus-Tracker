import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/services/translation_service.dart';
import 'package:smart_bus_tracker/common/theme_manager.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';
import 'package:smart_bus_tracker/common/widgets/language_selector.dart'; // Import Language Selector
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
  // bool _translateUserContent = true; 

  @override
  void initState() {
    super.initState();
    // TranslationService.instance.loadSettings().then((_) {
    //   setState(() => _translateUserContent = TranslationService.instance.isEnabled);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionColor = Theme.of(context).primaryColor;
    
    // Determine the icon color based on the theme
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Settings")),
      body: ListView(
        children: [
          _buildSectionHeader("Account", sectionColor),
          _buildTile(Icons.person_outline, "Edit Profile", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerEditProfileScreen()));
          }),
          _buildTile(Icons.lock_outline, "Change Password", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
          }),

          const Divider(),

          _buildSectionHeader("Preferences", sectionColor),
          // Language Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TranslatedText("App Language"),
                // 🟢 FIX: Use ColorFiltered to force the icon color to be visible
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    iconColor, 
                    BlendMode.srcIn
                  ),
                  child: const LanguageButton(),
                ),
              ],
            ),
          ),
          
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const TranslatedText("Dark Theme"),
            value: _darkTheme,
            onChanged: (val) {
              setState(() => _darkTheme = val);
              toggleTheme(val); 
            },
          ),

          const Divider(),

          _buildSectionHeader("Support", sectionColor),
          _buildTile(Icons.bug_report_outlined, "Report Bug", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportBugScreen()));
          }),
          _buildTile(Icons.description_outlined, "Terms and Conditions", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(title: "Terms and Conditions", contentType: "terms")));
          }),
          _buildTile(Icons.privacy_tip_outlined, "Privacy Policy", onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalContentScreen(title: "Privacy Policy", contentType: "privacy")));
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: TranslatedText(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
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