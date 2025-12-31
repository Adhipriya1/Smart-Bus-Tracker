import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import

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
              Image.network(url, height: 400, width: double.infinity, fit: BoxFit.contain)
            else 
              const Padding(padding: EdgeInsets.all(20), child: TranslatedText("No URL provided")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Verify Documents")),
      body: StreamBuilder(
        stream: supabase.from('conductor_documents').stream(primaryKey: ['id']).order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data as List;
          if (docs.isEmpty) return const Center(child: TranslatedText("No documents to verify."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final isVerified = doc['is_verified'] ?? false;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        title: TranslatedText(doc['document_name'] ?? "Unknown Doc", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Conductor: ${doc['conductor_email']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () => _showPreview(doc['document_url'] ?? "", doc['document_name'] ?? "Doc"),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          isVerified 
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green)
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                                    SizedBox(width: 6),
                                    TranslatedText("Verified", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.verified_user, size: 18),
                                label: const TranslatedText("Verify"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  await supabase.from('conductor_documents').update({'is_verified': true}).eq('id', doc['id']);
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