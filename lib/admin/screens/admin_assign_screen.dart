import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
    }
  }

  void _showAssignDialog(Map<String, dynamic> conductor) {
    String? selectedBusId;
    String? selectedRouteId;
    final conductorName = conductor['full_name'] ?? conductor['email'] ?? 'Unknown';
    // Check Dark Mode for Dialog
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Text("Assign for ", style: TextStyle(fontWeight: FontWeight.bold)),
                Flexible(child: Text(conductorName, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite, 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Select Bus & Route for today's shift.", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 20),
                  
                  // --- BUS DROPDOWN ---
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                    decoration: InputDecoration(
                      label: const Text("Select Bus"),
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                    ),
                    items: _buses.map((b) => DropdownMenuItem(
                      value: b['id'] as String,
                      child: Text(
                        b['license_plate'], 
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87)
                      ),
                    )).toList(),
                    onChanged: (v) => selectedBusId = v,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // --- ROUTE DROPDOWN ---
                  DropdownButtonFormField<String>(
                    isExpanded: true, 
                    dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                    decoration: InputDecoration(
                      label: const Text("Select Route"),
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                    ),
                    items: _routes.map((r) => DropdownMenuItem(
                      value: r['id'] as String,
                      child: Text(
                        "${r['route_number']} - ${r['name']}",
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 1,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      ),
                    )).toList(),
                    onChanged: (v) => selectedRouteId = v,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("CANCEL", style: TextStyle(color: Colors.grey))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (selectedBusId == null || selectedRouteId == null) return;
                  try {
                    await supabase.from('daily_assignments').upsert({
                      'conductor_id': conductor['id'],
                      'bus_id': selectedBusId,
                      'route_id': selectedRouteId,
                      'assigned_date': DateTime.now().toIso8601String().split('T')[0],
                    }, onConflict: 'conductor_id, assigned_date');
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Assignment Sent!")));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
                child: const Text("ASSIGN"),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Detect Dark Mode from System/Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Daily Route Assignments")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _conductors.length,
            itemBuilder: (ctx, i) {
              final c = _conductors[i];
              
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                // 2. Apply Dark Mode Color to Card
                color: isDark ? Colors.grey[800] : Colors.white, 
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- TOP SECTION: DETAILS ---
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: const Icon(Icons.person, color: Colors.blue, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name (Single Line)
                                Text(
                                  c['full_name'] ?? "Unknown Conductor",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 18,
                                    // 3. Apply Dark Mode Text Color
                                    color: isDark ? Colors.white : Colors.black87, 
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Email (Single Line)
                                Text(
                                  c['email'] ?? "",
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600], 
                                    fontSize: 14
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // --- BOTTOM SECTION: BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit_calendar),
                          label: const Text("ASSIGN ROUTE", style: TextStyle(fontWeight: FontWeight.bold)),
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