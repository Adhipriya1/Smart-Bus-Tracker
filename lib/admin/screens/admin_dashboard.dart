import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_bus_tracker/admin/screens/admin_assign_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          if (data.isNotEmpty && mounted) {
            _showEmergencyDialog(data.first);
          }
        });
  }

  void _showEmergencyDialog(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
          SizedBox(width: 10),
          Text("EMERGENCY ALERT")
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SOS received from BUS: ${alert['bus_id']}."),
            const SizedBox(height: 8),
            const Text("Check Live Tracking immediately.")
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase
                  .from('sos_alerts')
                  .update({'status': 'RESOLVED'}).eq('id', alert['id']);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("MARK RESOLVED",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = user?.email ?? "Admin";
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text("Admin Portal",
              style: TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[900]!, Colors.blue[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: const Padding(
                  padding: EdgeInsets.only(top: 12.0), 
                  child: Text("Administrator",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                accountEmail: Text(email),
                currentAccountPicture: Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Icon(Icons.security, size: 40, color: Colors.blue[900]),
                ),
              ),
              _buildDrawerItem(Icons.settings, "Settings", () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminSettingsScreen()));
              }),
              const Spacer(),
              const Divider(),
              _buildDrawerItem(Icons.logout, "Logout", () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                }
              }, isDestructive: true),
              const SizedBox(height: 20),
            ],
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Overview",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.blueGrey[900])),
              const SizedBox(height: 5),
              Text("Manage Fleet",
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildModernMenuCard(
                        context,
                        "Assign Routes",
                        Icons.assignment_ind_outlined,
                        Colors.teal,
                        const AdminAssignScreen()),
                    _buildModernMenuCard(
                        context,
                        "Verify Documents",
                        Icons.verified_user_outlined,
                        Colors.orange,
                        const AdminDocumentsScreen()),
                    _buildModernMenuCard(
                        context,
                        "Live Tracking",
                        Icons.location_on_outlined,
                        Colors.red,
                        const AdminBusSelectScreen()),
                    _buildModernMenuCard(
                        context,
                        "Collections",
                        Icons.account_balance_wallet_outlined,
                        Colors.green,
                        const AdminCollectionsScreen()),
                    _buildModernMenuCard(
                        context,
                        "Complaints",
                        Icons.report_gmailerrorred_outlined,
                        Colors.purple,
                        const AdminComplaintsScreen()),
                    _buildModernMenuCard(
                        context,
                        "Ride Reviews",
                        Icons.star_outline,
                        Colors.amber,
                        const AdminReviewsScreen()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernMenuCard(BuildContext context, String title, IconData icon,
      Color color, Widget page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
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
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : null),
      title: Text(title,
          style: TextStyle(
              color: isDestructive ? Colors.redAccent : null,
              fontWeight: isDestructive ? FontWeight.bold : FontWeight.w500)),
      onTap: onTap,
    );
  }
}