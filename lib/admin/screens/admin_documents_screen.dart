import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AdminDocumentsScreen extends StatefulWidget {
  const AdminDocumentsScreen({super.key});
  @override
  State<AdminDocumentsScreen> createState() => _AdminDocumentsScreenState();
}

class _AdminDocumentsScreenState extends State<AdminDocumentsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  void _showPreview(String url, String name) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(title: Text(name), leading: const CloseButton(), elevation: 0),
            if (url.isNotEmpty)
              Image.network(
                url, 
                height: 400, 
                width: double.infinity,
                fit: BoxFit.contain, 
                errorBuilder: (c,e,s) => const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                )
              )
            else 
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("No URL provided"),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Documents")),
      body: StreamBuilder(
        stream: supabase.from('conductor_documents').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error: ${snapshot.error}", 
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!;
          
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No documents pending."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];
              final isVerified = doc['is_verified'] ?? false;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isDark ? Colors.grey[800] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // --- TOP SECTION: Document Info ---
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: const Icon(Icons.description, color: Colors.blue, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc['document_name'] ?? "Unnamed Document", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doc['conductor_email'] ?? "Unknown Conductor", 
                                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(),
                      ),
                      
                      // --- BOTTOM SECTION: Actions ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // View Button
                          TextButton.icon(
                            onPressed: () => _showPreview(doc['document_url'] ?? '', doc['document_name'] ?? 'Doc'),
                            icon: const Icon(Icons.visibility, size: 18),
                            label: const Text("View"),
                            style: TextButton.styleFrom(foregroundColor: Colors.blue),
                          ),
                          
                          // Verify Button or Status Badge
                          isVerified
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.withOpacity(0.5))
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                                    SizedBox(width: 6),
                                    Text("Verified", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.verified_user, size: 18),
                                label: const Text("Verify"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  try {
                                    await supabase.from('conductor_documents').update({'is_verified': true}).eq('id', doc['id']);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                  }
                                },
                              ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}