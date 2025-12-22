import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConductorDocumentsScreen extends StatefulWidget {
  const ConductorDocumentsScreen({super.key});

  @override
  State<ConductorDocumentsScreen> createState() => _ConductorDocumentsScreenState();
}

class _ConductorDocumentsScreenState extends State<ConductorDocumentsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isUploading = false;

  Future<void> _uploadDocument(String docType) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final fileExt = image.path.split('.').last;
      final fileName = '${user.id}/$docType.${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // 1. Upload to Storage
      await supabase.storage.from('documents').upload(fileName, File(image.path));
      
      // 2. Get Public URL
      final imageUrl = supabase.storage.from('documents').getPublicUrl(fileName);

      // 3. Upsert Record into DB (Update if exists, Insert if new)
      // We first check if a document of this type already exists to update it or insert new
      final existing = await supabase
          .from('conductor_documents')
          .select()
          .eq('conductor_id', user.id)
          .eq('document_name', docType)
          .maybeSingle();

      if (existing != null) {
        await supabase.from('conductor_documents').update({
          'document_url': imageUrl,
          'is_verified': false, // Reset verification on new upload
          'created_at': DateTime.now().toIso8601String(),
        }).eq('id', existing['id']);
      } else {
        await supabase.from('conductor_documents').insert({
          'conductor_id': user.id,
          'conductor_email': user.email,
          'document_name': docType,
          'document_url': imageUrl,
          'is_verified': false,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document Uploaded! Wait for verification."), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("My Documents")),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(),
          Expanded(
            child: StreamBuilder(
              stream: supabase.from('conductor_documents').stream(primaryKey: ['id']).eq('conductor_id', user?.id ?? ''),
              builder: (context, snapshot) {
                final docs = snapshot.data ?? [];
                
                // Helper to check status
                bool isUploaded(String name) => docs.any((d) => d['document_name'] == name);
                bool isVerified(String name) => docs.any((d) => d['document_name'] == name && d['is_verified'] == true);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfoCard(isDark),
                    const SizedBox(height: 20),
                    _buildDocTile("Driving License", isUploaded("Driving License"), isVerified("Driving License"), isDark),
                    const SizedBox(height: 10),
                    _buildDocTile("Aadhar Card", isUploaded("Aadhar Card"), isVerified("Aadhar Card"), isDark),
                    const SizedBox(height: 10),
                    _buildDocTile("PAN Card", isUploaded("PAN Card"), isVerified("PAN Card"), isDark),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Please upload clear photos of your original documents. Admin will verify them shortly.",
              style: TextStyle(color: isDark ? Colors.blue[100] : Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(String title, bool uploaded, bool verified, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: uploaded 
              ? (verified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1))
              : Colors.grey.withOpacity(0.1),
          child: Icon(
            uploaded ? (verified ? Icons.verified : Icons.hourglass_top) : Icons.upload_file,
            color: uploaded ? (verified ? Colors.green : Colors.orange) : Colors.grey,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          uploaded ? (verified ? "Verified" : "Pending Verification") : "Not Uploaded",
          style: TextStyle(color: uploaded ? (verified ? Colors.green : Colors.orange) : Colors.grey, fontSize: 12),
        ),
        trailing: uploaded && verified
          ? const Chip(label: Text("Done", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green)
          : ElevatedButton(
              onPressed: () => _uploadDocument(title),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(uploaded ? "Re-upload" : "Upload"),
            ),
      ),
    );
  }
}