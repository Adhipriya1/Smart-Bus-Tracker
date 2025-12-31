import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import

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

  Future<void> _cleanupOldComplaints() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
      await supabase.from('complaints').delete().eq('status', 'RESOLVED').lt('resolved_at', sevenDaysAgo); 
    } catch (e) {
      debugPrint("Auto-cleanup error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Complaints & Bugs")),
      body: StreamBuilder(
        stream: supabase.from('complaints').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final bugs = snapshot.data as List;
          if (bugs.isEmpty) return const Center(child: TranslatedText("No complaints found."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bugs.length,
            itemBuilder: (context, index) {
              final bug = bugs[index];
              final isResolved = bug['status'] == 'RESOLVED';

              return Card(
                color: isResolved ? (isDark ? Colors.grey[900] : Colors.green[50]) : null,
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Icon(
                    isResolved ? Icons.check_circle : Icons.report_problem,
                    color: isResolved ? Colors.green : Colors.red
                  ),
                  title: Text(bug['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: TranslatedText(isResolved ? "Resolved" : "Pending Action", style: TextStyle(color: isResolved ? Colors.green : Colors.orange)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TranslatedText("Description:", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(bug['description'] ?? "No description"),
                          const SizedBox(height: 15),
                          Align(
                            alignment: Alignment.centerRight,
                            child: isResolved
                              ? Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green.withOpacity(0.3))
                                  ),
                                  child: const TranslatedText(
                                    "✓  RESOLVED (Will auto-delete in 7 days)", 
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                                  ),
                                )
                              : ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const TranslatedText("MARK AS RESOLVED"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  onPressed: () async {
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