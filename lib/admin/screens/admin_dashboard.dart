import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_bus_tracker/admin/screens/admin_assign_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import
import 'package:smart_bus_tracker/common/widgets/language_selector.dart'; // Ensure Language Button

// Feature Screens
import 'admin_documents_screen.dart';
import 'admin_complaints_screen.dart';
import 'admin_reviews_screen.dart';
import 'admin_collections_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_bus_select_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final SupabaseClient supabase = Supabase.instance.client;
  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _listenForSOS();
  }

  void _listenForSOS() {
    supabase
        .from('sos_alerts')
        .stream(primaryKey: ['id'])
        .eq('status', 'OPEN')
        .listen((data) {
          if (data.isNotEmpty) {
            _showSOSAlert(data.first);
          }
        });
  }

  void _showSOSAlert(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: const Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 10), TranslatedText("SOS ALERT", style: TextStyle(color: Colors.red))]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText("Emergency reported by Conductor!"),
            const SizedBox(height: 10),
            Text("Bus ID: ${alert['bus_id']}"),
            const SizedBox(height: 20),
            const TranslatedText("Location coordinates received."),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              // Close Alert & potentially navigate to map
              Navigator.pop(context);
              supabase.from('sos_alerts').update({'status': 'RESOLVED'}).eq('id', alert['id']);
            },
            child: const TranslatedText("ACKNOWLEDGE & RESOLVE"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const TranslatedText("Admin Dashboard"),
          actions: const [LanguageButton()],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.blue[900]),
                accountName: const TranslatedText("Administrator"),
                accountEmail: Text(user?.email ?? "admin@smartbus.com"),
                currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue)),
              ),
              _buildDrawerItem(Icons.settings, "Settings", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSettingsScreen()))),
              const Divider(),
              _buildDrawerItem(Icons.logout, "Logout", () async {
                 await supabase.auth.signOut();
                 if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
              }, isDestructive: true),
            ],
          ),
        ),
        body: GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard("Manage Routes", Icons.map, Colors.orange, const AdminBusSelectScreen()), // Changed from localized to String
            _buildDashboardCard("Assign", Icons.person_add, Colors.blue, const AdminAssignScreen()),
            _buildDashboardCard("Documents", Icons.folder_shared, Colors.purple, const AdminDocumentsScreen()),
            _buildDashboardCard("Collections", Icons.currency_rupee, Colors.green, const AdminCollectionsScreen()),
            _buildDashboardCard("Complaints", Icons.bug_report, Colors.redAccent, const AdminComplaintsScreen()),
            _buildDashboardCard("Reviews", Icons.star, Colors.amber, const AdminReviewsScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, Color color, Widget page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            TranslatedText(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : null),
      title: TranslatedText(title, style: TextStyle(color: isDestructive ? Colors.redAccent : null, fontWeight: isDestructive ? FontWeight.bold : FontWeight.w500)),
      onTap: onTap,
    );
  }
}