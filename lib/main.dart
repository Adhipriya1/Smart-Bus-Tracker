import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import your screens and providers
import 'package:smart_bus_tracker/common/locale_provider.dart'; // Ensure this file exists
import 'package:smart_bus_tracker/l10n/app_localizations.dart';
import 'package:smart_bus_tracker/common/theme_manager.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'passenger/screens/passenger_login_screen.dart';
import 'passenger/screens/passenger_home_screen.dart';
import 'passenger/screens/home_map_screen.dart';
import 'conductor/screens/login_screen.dart';
import 'conductor/screens/trip_selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load the .env file
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(
    MultiProvider(
      providers: [
        // FIXED: Using LocaleProvider here to match the screens
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // FIXED: Watch LocaleProvider
    final localeProvider = Provider.of<LocaleProvider>(context);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Smart Bus Tracker',
          debugShowCheckedModeBanner: false,
          
          // --- LOCALIZATION SETUP ---
          locale: localeProvider.locale, 
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('mr'),
            Locale('ta'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // --------------------------

          themeMode: themeMode,
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blue[900],
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[900]!),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
              titleMedium: TextStyle(color: Colors.white),
            ),
          ),

          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeScreen(),
            '/passenger-login': (context) => const PassengerLoginScreen(),
            '/passenger-home': (context) => const PassengerHomeScreen(),
            '/passenger-map': (context) => const PassengerMapScreen(),
            '/conductor-login': (context) => const ConductorLoginScreen(),
            '/conductor/dashboard': (context) => const TripSelectionScreen(),
          },
        );
      },
    );
  }
}