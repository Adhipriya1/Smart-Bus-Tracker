import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import

class AdminAssignScreen extends StatefulWidget {
  const AdminAssignScreen({super.key});

  @override
  State<AdminAssignScreen> createState() => _AdminAssignScreenState();
}

class _AdminAssignScreenState extends State<AdminAssignScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _conductors = [];
  List<Map<String, dynamic>> _buses = [];
  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final conductorRes = await supabase.from('profiles').select('id, email, full_name').neq('role', 'admin');
      final busRes = await supabase.from('buses').select('id, license_plate').eq('is_active', true);
      final routeRes = await supabase.from('routes').select('id, route_number, name').eq('is_active', true);

      if (mounted) {
        setState(() {
          _conductors = List<Map<String, dynamic>>.from(conductorRes);
          _buses = List<Map<String, dynamic>>.from(busRes);
          _routes = List<Map<String, dynamic>>.from(routeRes);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAssignDialog(Map<String, dynamic> conductor) {
    String? selectedBus;
    String? selectedRoute;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const TranslatedText("Assign Route & Bus"),
        content: StatefulBuilder(
          builder: (context, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Bus'),
                items: _buses.map((b) => DropdownMenuItem(value: b['id'] as String, child: Text(b['license_plate']))).toList(),
                onChanged: (v) => setSt(() => selectedBus = v),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Route'),
                items: _routes.map((r) => DropdownMenuItem(value: r['id'] as String, child: Text("${r['route_number']} - ${r['name']}"))).toList(),
                onChanged: (v) => setSt(() => selectedRoute = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const TranslatedText("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedBus != null && selectedRoute != null) {
                 await supabase.from('assignments').insert({
                   'conductor_id': conductor['id'],
                   'bus_id': selectedBus,
                   'route_id': selectedRoute,
                   'assigned_at': DateTime.now().toIso8601String(),
                 });
                 if (mounted) Navigator.pop(ctx);
                 if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText("Assignment Created!")));
              }
            },
            child: const TranslatedText("ASSIGN"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Assign Conductors")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _conductors.length,
            itemBuilder: (context, index) {
              final c = _conductors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c['full_name'] ?? "Unknown",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(c['email'] ?? "", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit_calendar),
                          label: const TranslatedText("ASSIGN ROUTE", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900], 
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showAssignDialog(c),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}