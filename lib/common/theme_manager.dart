import 'package:flutter/material.dart';

// Global notifier for Theme Mode (Light/Dark)
// By default, it is set to Light
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void toggleTheme(bool isDark) {
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}