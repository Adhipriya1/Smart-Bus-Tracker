import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// FIXED IMPORT: Must match the path used in main.dart
import 'package:smart_bus_tracker/common/locale_provider.dart'; 

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Now this will correctly find the provider injected in main.dart
    final provider = Provider.of<LocaleProvider>(context);
    
    return PopupMenuButton<String>(
      onSelected: (code) => provider.setLocale(Locale(code)),
      icon: const Icon(Icons.language, color: Colors.white),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'en', child: Text("🇺🇸 English")),
        const PopupMenuItem(value: 'hi', child: Text("🇮🇳 हिंदी (Hindi)")),
        const PopupMenuItem(value: 'mr', child: Text("🇮🇳 मराठी (Marathi)")),
        const PopupMenuItem(value: 'ta', child: Text("🇮🇳 தமிழ் (Tamil)")),
      ],
    );
  }
}