import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; 

class LostFoundScreen extends StatefulWidget {
  final String busId;
  const LostFoundScreen({super.key, required this.busId});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  final _itemCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _seatCtrl = TextEditingController();
  
  // Image State
  File? _imageFile;
  final _picker = ImagePicker();
  bool _isSubmitting = false;

  // 1. Pick Image Function
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera, 
        maxWidth: 600, 
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  // 2. Submit Logic 
  Future<void> _submitReport() async {
    if (_itemCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter Item Type")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;

      // A. Upload Image if selected
      if (_imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg'; 
        final path = 'items/$fileName';

        await Supabase.instance.client.storage
            .from('lost_found')
            .upload(path, _imageFile!);

        imageUrl = Supabase.instance.client.storage
            .from('lost_found')
            .getPublicUrl(path);
      }

      // B. Save to Database
      await Supabase.instance.client.from('lost_found').insert({
        'bus_id': widget.busId,
        'item_type': _itemCtrl.text,
        'description': _descCtrl.text,
        'seat_number': _seatCtrl.text,
        'image_url': imageUrl, 
        'status': 'found',
        'found_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item Logged Successfully!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log Lost Item"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE PICKER UI
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageFile == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Tap to add photo", style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text("Item Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            TextField(
              controller: _itemCtrl,
              decoration: const InputDecoration(label: Text("Item Type (e.g., Wallet)"), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _seatCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(label: Text("Found near Seat #"), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(label: Text("Description (Color, Brand, etc.)"), border: OutlineInputBorder()),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
                icon: const Icon(Icons.save),
                label: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("LOG ITEM", style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _isSubmitting ? null : _submitReport,
              ),
            )
          ],
        ),
      ),
    );
  }
}