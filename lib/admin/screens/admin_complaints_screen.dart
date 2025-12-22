import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});
  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _cleanupOldComplaints();
  }

  // --- AUTOMATIC CLEANUP FUNCTION ---
  Future<void> _cleanupOldComplaints() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

      await supabase
          .from('complaints')
          .delete()
          .eq('status', 'RESOLVED')
          .lt('resolved_at', sevenDaysAgo); 
      
    } catch (e) {
      debugPrint("Auto-cleanup error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Complaints & Bugs")),
      body: StreamBuilder(
        stream: supabase.from('complaints').stream(primaryKey: ['id']).order('created_at'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("No active complaints!", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          final items = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final bug = items[i];
              final isResolved = bug['status'] == 'RESOLVED';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: isDark ? Colors.grey[800] : Colors.white,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: isResolved ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      isResolved ? Icons.check : Icons.report_problem, 
                      color: isResolved ? Colors.green : Colors.red
                    ),
                  ),
                  title: Text(
                    bug['subject'] ?? 'No Subject',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isResolved ? TextDecoration.lineThrough : null,
                      color: isResolved ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  subtitle: Text("From: ${bug['user_email'] ?? 'Anonymous'}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 4),
                          bug['description'] != null 
                            ? Text(bug['description'])
                            : const Text('No Description provided.'),
                          const SizedBox(height: 20),
                          
                          // --- ACTION BUTTON ---
                          SizedBox(
                            width: double.infinity,
                            child: isResolved
                              ? Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green.withOpacity(0.3))
                                  ),
                                  child: const Text(
                                    "✓  RESOLVED (Will auto-delete in 7 days)",
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                                  ),
                                )
                              : ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text("MARK AS RESOLVED"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () async {
                                    // Update Status AND set the Resolution Time
                                    await supabase.from('complaints').update({
                                      'status': 'RESOLVED',
                                      'resolved_at': DateTime.now().toIso8601String(), 
                                    }).eq('id', bug['id']);
                                  },
                                ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}