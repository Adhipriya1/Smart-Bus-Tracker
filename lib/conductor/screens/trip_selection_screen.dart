import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import
import 'package:supabase_flutter/supabase_flutter.dart';
import 'inspection_screen.dart'; 

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
    _fetchAssignment();
  }

 Future<void> _fetchAssignment() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ CHANGE: Query 'daily_assignments' instead of 'assignments'
      // We assume your table has columns 'bus_id' and 'route_id' that are Foreign Keys
      final data = await supabase
          .from('daily_assignments')
          .select('*, buses(*), routes(*)') 
          .eq('conductor_id', userId) // ⚠️ Make sure this column exists in daily_assignments
          .maybeSingle();

      if (mounted) {
        setState(() {
          _assignment = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching assignment: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Today's Shift")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _assignment == null 
          ? const Center(child: TranslatedText("No bus assigned for today."))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAssignmentCard(_assignment!, isDark),
                  const Spacer(),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
                      icon: const Icon(Icons.play_arrow),
                      label: const TranslatedText("START PRE-CHECK", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (_) => InspectionScreen(
                              busId: _assignment!['buses']['id'],
                              routeId: _assignment!['routes']['id'],
                            )
                          )
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> data, bool isDark) {
    final busPlate = data['buses']['license_plate'] ?? "Unknown";
    final routeName = "${data['routes']['route_number']} - ${data['routes']['name']}";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, color: Colors.blue),
              const SizedBox(width: 8),
              TranslatedText("Current Assignment", style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 12)),
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
              TranslatedText(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
        )
      ],
    );
  }
}