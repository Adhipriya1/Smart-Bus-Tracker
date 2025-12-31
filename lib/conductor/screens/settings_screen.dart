import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/services/translation_service.dart';
import 'package:smart_bus_tracker/common/theme_manager.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; 
import 'package:smart_bus_tracker/common/widgets/language_selector.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionColor = isDark ? Colors.blue[200] : Colors.blue[900];
    
    // Determine the icon color based on the theme
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Settings")),
      body: ListView(
        children: [
          _buildSectionHeader("Account", sectionColor),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const TranslatedText("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const TranslatedText("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const TranslatedText("My Documents"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConductorDocumentsScreen())),
          ),

          const Divider(),

          _buildSectionHeader("Preferences", sectionColor),
          // Language Selector with Color Fix
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TranslatedText("App Language"),
                // 🟢 FIX: Use ColorFiltered to ensure visibility in Light Mode
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
            title: const TranslatedText("Report Bug"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIssueScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color? color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TranslatedText(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}