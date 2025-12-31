import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_bus_tracker/common/widgets/language_selector.dart'; 

import 'cash_tally_screen.dart';      
import 'lost_found_screen.dart';      
import 'trip_history_screen.dart';    
import 'settings_screen.dart';        
import 'report_issue_screen.dart';    
import 'help_screen.dart';            
import 'trip_selection_screen.dart';  

class ConductorHomeScreen extends StatefulWidget {
  const ConductorHomeScreen({super.key});

  @override
  State<ConductorHomeScreen> createState() => _ConductorHomeScreenState();
}

class _ConductorHomeScreenState extends State<ConductorHomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // 🟢 MOVED USER GETTER HERE so we can refresh it easily
  User? get user => Supabase.instance.client.auth.currentUser;
  
  bool _isSyncing = false;
  bool _isSendingSOS = false;

  // --- ACTIONS ---
  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2)); 
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), TranslatedText("Data Synced Successfully!")]),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _triggerSOS() async {
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning, color: Colors.red), 
          SizedBox(width: 10), 
          TranslatedText("CONFIRM EMERGENCY") 
        ]),
        content: const TranslatedText("Are you sure you want to send an SOS Alert to the Admin? This will share your live location."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: const TranslatedText("CANCEL") 
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const TranslatedText("SEND SOS"), 
          ),
        ],
      ),
    );

    if (shouldSend != true) return;

    setState(() => _isSendingSOS = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      Position? position;
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }

      await supabase.from('sos_alerts').insert({
        'bus_id': 'MH-01-AB-1234',
        'conductor_id': user?.id,
        'location_lat': position?.latitude,
        'location_long': position?.longitude,
        'status': 'OPEN',
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.red[50],
            title: const Row(children: [Icon(Icons.check_circle, color: Colors.red), SizedBox(width: 10), TranslatedText("ALERT SENT")]),
            content: const TranslatedText("Admin has been notified with your location."), 
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const TranslatedText("CLOSE", style: TextStyle(color: Colors.red)) 
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSendingSOS = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 FIX: Read 'full_name' from metadata. Fallback to Email if empty.
    final String email = user?.email ?? "Conductor";
    final String name = user?.userMetadata?['full_name'] ?? email.split('@')[0].toUpperCase();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isTamil = Localizations.localeOf(context).languageCode == 'ta';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        SystemNavigator.pop(); 
      },
      child: Scaffold(
        appBar: AppBar(
          title: TranslatedText("Smart Bus Tracker", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTamil ? 18 : 22)), 
          elevation: 0,
          actions: [
            const LanguageButton(),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onLongPress: _isSendingSOS ? null : _triggerSOS,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isSendingSOS ? Colors.grey : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      if (_isSendingSOS)
                        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      else
                        const Icon(Icons.sos, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      const Text("SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
                    ],
                  ),
                ),
              ),
            )
          ],
        ),

        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                // 🟢 Display the correct Name and Email
                accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                accountEmail: Text(email),
                currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.blue)),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const TranslatedText("My Rides History"), 
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TripHistoryScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const TranslatedText("Settings"), 
                onTap: () async {
                  Navigator.pop(context);
                  // 🟢 FIX: Wait for user to return, then refresh (setState)
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  setState(() {}); 
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const TranslatedText("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), 
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TranslatedText("Hello", style: TextStyle(fontSize: isTamil ? 20 : 24, fontWeight: FontWeight.w800)),
                  // 🟢 Name will now update correctly
                  Text(", $name", style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: isTamil ? 20 : 24 
                  )),
                ],
              ),
              const TranslatedText("Ready for your shift?", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              _buildHeroCard(
                title: "Start New Trip", 
                subtitle: "Select a Bus", 
                icon: Icons.directions_bus_filled,
                color: Theme.of(context).primaryColor, 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TripSelectionScreen())),
                isTamil: isTamil, 
              ),

              const SizedBox(height: 30),
              
              TranslatedText("Shift Tools", style: TextStyle(fontSize: isTamil ? 18 : 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildToolCard(
                        "Collections", 
                        Icons.calculate, 
                        Colors.green, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CashTallyScreen(busId: 'BUS-123'))),
                        isTamil 
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildToolCard(
                        "Log Lost Item", 
                        Icons.backpack, 
                        Colors.orange, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LostFoundScreen(busId: 'BUS-123'))),
                        isTamil 
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              
              TranslatedText("Support", style: TextStyle(fontSize: isTamil ? 18 : 20, fontWeight: FontWeight.bold)), 
              const SizedBox(height: 15),
              
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : Colors.grey.shade200, 
                      blurRadius: 10, offset: const Offset(0, 4)
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        _isSyncing ? Icons.hourglass_top : Icons.sync, 
                        "Sync Data", 
                        Colors.blue, 
                        _isSyncing ? () {} : _handleSync,
                        isTamil
                      ),
                    ),
                    _buildVerticalDivider(isDark),
                    Expanded(
                      child: _buildQuickAction(
                        Icons.report_problem_rounded, 
                        "Report Bug", 
                        Colors.redAccent, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIssueScreen())),
                        isTamil
                      ),
                    ),
                    _buildVerticalDivider(isDark),
                    Expanded(
                      child: _buildQuickAction(
                        Icons.help_outline, 
                        "Help", 
                        Colors.purple, 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                        isTamil
                      ),
                    ),
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

  Widget _buildHeroCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap, required bool isTamil}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color, 
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4), 
              blurRadius: 12, 
              offset: const Offset(0, 6)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(title, style: TextStyle(color: Colors.white, fontSize: isTamil ? 17 : 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TranslatedText(subtitle, style: TextStyle(color: Colors.white70, fontSize: isTamil ? 12 : 14)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(String title, IconData icon, Color color, VoidCallback onTap, bool isTamil) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : Colors.grey.shade200, 
              blurRadius: 8, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            TranslatedText(
              title, 
              textAlign: TextAlign.center, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: isTamil ? 11 : 13, 
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap, bool isTamil) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          TranslatedText(
            label, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTamil ? 10 : 12, 
              fontWeight: FontWeight.w600, 
              color: Colors.grey
            )
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 30, 
      width: 1, 
      color: isDark ? Colors.grey[800] : Colors.grey[300]
    );
  }
}