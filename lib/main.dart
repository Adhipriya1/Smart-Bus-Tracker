import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/passenger/screens/passenger_home_screen.dart';
import 'package:smart_bus_tracker/passenger/screens/passenger_login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/welcome_screen.dart';
import 'conductor/screens/login_screen.dart';
import 'passenger/screens/home_map_screen.dart';
import 'conductor/screens/trip_selection_screen.dart';
import 'package:smart_bus_tracker/common/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // REPLACE WITH YOUR ACTUAL KEYS
  await Supabase.initialize(
    url: 'https://nwnkpxfrgrlsjytmzavd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53bmtweGZyZ3Jsc2p5dG16YXZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3NzMwNzQsImV4cCI6MjA4MTM0OTA3NH0.5GkJ_agDGRxFK2SsgA6dbbGwgWV5f2zG7lK4UcJgNiA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          themeAnimationDuration: const Duration(milliseconds: 400),
          themeAnimationCurve: Curves.easeInOut,
          title: 'Smart Bus Tracker',
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Soft Blue-Grey

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D47A1), // Deep Blue
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            // CARD THEME - NO 'const' KEYWORD HERE!
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 4,
              shadowColor:
                  Colors.black.withOpacity(0.1), // This requires NO const
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16), // This requires NO const
              ),
            ),
          ),

          // --- 2. DARK THEME ---
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212), // Pure Dark

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F), // Dark Grey Surface
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            // CARD THEME - NO 'const' KEYWORD HERE!
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E), // Lighter Dark Surface
              elevation: 4,
              shadowColor:
                  Colors.black.withOpacity(0.4), // This requires NO const
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16), // This requires NO const
              ),
            ),

            // Adjust Text Colors for Dark Mode
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
              titleMedium: TextStyle(color: Colors.white),
            ),
          ),

          // --- 3. CURRENT MODE ---
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),

            // Passenger Routes
            '/passenger-login': (context) => const PassengerLoginScreen(),
            '/passenger-home': (context) => const PassengerHomeScreen(),
            '/passenger-map': (context) =>
                const PassengerMapScreen(), // General map view
            // Conductor Routes
            '/conductor-login': (context) => const ConductorLoginScreen(),
            '/conductor/dashboard': (context) => const TripSelectionScreen(),
          },
        );
      },
    );
  }
}