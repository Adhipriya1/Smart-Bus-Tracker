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

    final unratedTrips = await supabase
        .from('passenger_trips')
        .select()
        .eq('passenger_id', user.id)
        .eq('status', 'completed')
        .isFilter('rating', null)
        .limit(1);

    if (unratedTrips.isNotEmpty && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildRatingDialog(unratedTrips[0]['id']),
      );
    }
  }

  Widget _buildRatingDialog(String tripId) {
    return AlertDialog(
      title: const Text("Rate Your Ride"),
      content: const Text("How was your experience?"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon:
                  const Icon(Icons.star_border, size: 32, color: Colors.amber),
              onPressed: () async {
                await supabase.from('passenger_trips').update({
                  'rating': index + 1,
                  'feedback': 'Rated via App'
                }).eq('id', tripId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Thanks for rating!")));
                }
              },
            );
          }),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final email = user?.email ?? "Passenger";
    String displayName =
        user?.userMetadata?['full_name'] ?? email.split('@')[0].toUpperCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        SystemNavigator.pop(); // Exit App
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Smart Bus",
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            const SizedBox(width: 10),
          ],
        ),
        drawer: _buildDrawer(displayName, email),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello, $displayName",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87)),
              Text("Where are you going today?",
                  style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16)),
              const SizedBox(height: 24),

              _buildHeroCard(),

              const SizedBox(height: 32),

              Text("Top Routes",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 16),
              SizedBox(
                height: 140, 
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: supabase
                      .from('routes')
                      .select()
                      .order('average_rating', ascending: false)
                      .order('estimated_duration_mins', ascending: true)
                      .limit(5),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final routes = snapshot.data!;
                    if (routes.isEmpty) return const Text("No routes available.");

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: routes.length,
                      itemBuilder: (context, index) {
                        final r = routes[index];
                        return _buildTopRouteCard(
                            r['route_number'] ?? '000',
                            r['name'] ?? 'Unknown',
                            "${r['estimated_duration_mins'] ?? 60}m",
                            r['average_rating']?.toString() ?? "4.5");
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              Text("Menu",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuRow(
                        icon: Icons.favorite_rounded,
                        color: Colors.pink,
                        title: "Favorite Routes",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FavouriteRoutesScreen())),
                        showDivider: true),
                    _buildMenuRow(
                        icon: Icons.schedule_rounded,
                        color: Colors.orange,
                        title: "Bus Timetable",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BusTimetableScreen())),
                        showDivider: true),
                    _buildMenuRow(
                        icon: Icons.history_rounded,
                        color: Colors.purple,
                        title: "My Rides History",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RideHistoryScreen())),
                        showDivider: true),
                    _buildMenuRow(
                        icon: Icons.chat_bubble_rounded,
                        color: Colors.green,
                        title: "Support Chat",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChatScreen())),
                        showDivider: false 
                        ),
                    _buildMenuRow(
                        icon: Icons.star_rate_rounded,
                        color: Colors.amber,
                        title: "Rate Experience",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PassengerReviewScreen())),
                        showDivider: true),
                    _buildMenuRow(
                        icon: Icons.currency_rupee_rounded, 
                        color: Colors.teal,
                        title: "Trip Fare Calculator",
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TripFareScreen())),
                        showDivider: true),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const BusListScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.list_alt,
                  color: Colors.white, size: 28), 
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Track Live Bus",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Select a bus to view location",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)), 
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRouteCard(
      String num, String name, String time, String rating) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(num,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 12)),
              ),
              Row(children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                Text(" $rating",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12))
              ]),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(time,
                  style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMenuRow(
      {required IconData icon,
      required Color color,
      required String title,
      required VoidCallback onTap,
      bool showDivider = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87)),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.grey.shade400),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        if (showDivider)
          Divider(
              height: 1,
              thickness: 1,
              indent: 60,
              color: isDark ? Colors.white10 : Colors.grey.shade100),
      ],
    );
  }

  Widget _buildDrawer(String name, String email) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor),
            accountName:
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(email),
            currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40)),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PassengerSettingsScreen())),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}