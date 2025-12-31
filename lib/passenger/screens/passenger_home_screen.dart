import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:smart_bus_tracker/passenger/screens/passenger_review_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Feature Screens
import 'favourite_routes_screen.dart';
import 'notifications_screen.dart';
import 'chat_screen.dart';
import 'passenger_settings_screen.dart';
import 'ride_history_screen.dart';
import 'bus_timetable_screen.dart';
import 'trip_fare_screen.dart';
import 'bus_list_screen.dart'; 
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; 
import 'package:smart_bus_tracker/common/widgets/language_selector.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkForUnratedTrips();
  }

  Future<void> _checkForUnratedTrips() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final unratedTrips = await supabase
          .from('tickets') 
          .select()
          .eq('passenger_id', user.id)
          .eq('is_rated', false) 
          .limit(1);

      if (unratedTrips.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const TranslatedText("You have a pending trip review!"),
            action: SnackBarAction(
              label: 'REVIEW',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerReviewScreen())),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error checking unrated trips: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final displayName = user?.userMetadata?['full_name'] ?? 'Passenger';
    final email = user?.email ?? '';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const TranslatedText("Smart Bus"),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none), 
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))
            ),
            const LanguageButton(),
            const SizedBox(width: 8),
          ],
        ),
        drawer: _buildDrawer(displayName, email),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(displayName),
              const SizedBox(height: 30),
              
              const TranslatedText("Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1, // 🟢 Adjusted to give more vertical space for long Tamil text
                children: [
                  _buildServiceCard(Icons.directions_bus, "Live Tracking", Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusListScreen()))),
                  _buildServiceCard(Icons.schedule, "Timetable", Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusTimetableScreen()))),
                  _buildServiceCard(Icons.confirmation_number, "Ticket Fares", Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripFareScreen()))),
                  _buildServiceCard(Icons.favorite, "Frequent Routes", Colors.pink, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavouriteRoutesScreen()))),
                  _buildServiceCard(Icons.history, "My Rides", Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RideHistoryScreen()))),
                  _buildServiceCard(Icons.support_agent, "Help & Chat", Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      children: [
        // 🟢 FIX: Wrapped in Expanded to prevent Right Overflow in Tamil
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TranslatedText("Hello,", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text(name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300, color: Theme.of(context).primaryColor)),
              const SizedBox(height: 5),
              const TranslatedText(
                "Where do you want to go?", 
                style: TextStyle(color: Colors.grey),
                overflow: TextOverflow.visible, // Ensure it wraps
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(String name, String email) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
            accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(email),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40)),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const TranslatedText("Settings"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PassengerSettingsScreen())),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const TranslatedText("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await supabase.auth.signOut();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildServiceCard(IconData icon, String title, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8), // 🟢 Added Padding
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: isDark ? Colors.transparent : Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 15),
            // 🟢 FIX: Added Center Align for long text
            TranslatedText(
              title, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center, 
            ),
          ],
        ),
      ),
    );
  }
}