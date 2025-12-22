import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'inspection_screen.dart'; //

class TripSelectionScreen extends StatefulWidget {
  const TripSelectionScreen({super.key});

  @override
  State<TripSelectionScreen> createState() => _TripSelectionScreenState();
}

class _TripSelectionScreenState extends State<TripSelectionScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  Map<String, dynamic>? _assignment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenForAssignment();
  }

  void _listenForAssignment() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final userId = user.id;
    final today = DateTime.now().toIso8601String().split('T')[0];

    supabase
        .from('daily_assignments')
        .select('*, buses(license_plate), routes(route_number, name)')
        .eq('conductor_id', userId)
        .eq('assigned_date', today)
        .maybeSingle()
        .then((data) {
          if (mounted) setState(() { _assignment = data; _isLoading = false; });
    });

    supabase
        .from('daily_assignments')
        .stream(primaryKey: ['id'])
        .eq('conductor_id', userId)
        .listen((List<Map<String, dynamic>> data) async {
          if (data.isNotEmpty) {
             final fullData = await supabase
                .from('daily_assignments')
                .select('*, buses(license_plate), routes(route_number, name)')
                .eq('id', data.first['id'])
                .maybeSingle();
             
             if (mounted) setState(() => _assignment = fullData);
          }
    });
  }

  void _startTrip() {
    if (_assignment == null) return;
    
    // CHANGED: Navigate to Inspection Screen first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectionScreen(
          busId: _assignment!['bus_id'],
          routeId: _assignment!['route_id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Shift", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Assignment", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 5),
            Text(
              "Please wait for the admin to assign your route.", 
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])
            ),
            
            const SizedBox(height: 40),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_assignment == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_empty, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    const Text(
                      "No Route Assigned Yet",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const Text("Contact Admin or refresh later."),
                  ],
                ),
              )
            else
              _buildAssignmentCard(isDark),

            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: const Text("START SHIFT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _assignment != null ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                onPressed: _assignment != null ? _startTrip : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(bool isDark) {
    final busData = _assignment!['buses'];
    final routeData = _assignment!['routes'];
    
    final busPlate = busData != null ? busData['license_plate'] : "Unknown Bus";
    final routeName = routeData != null ? "${routeData['route_number']} - ${routeData['name']}" : "Unknown Route";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.blue),
              const SizedBox(width: 8),
              Text("ASSIGNED BY ADMIN", style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildInfoRow(Icons.directions_bus, "Bus Number", busPlate, isDark),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
          _buildInfoRow(Icons.map, "Route", routeName, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 28, color: Colors.black87),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                value, 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : Colors.black87
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}