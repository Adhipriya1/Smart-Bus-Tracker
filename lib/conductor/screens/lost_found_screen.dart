import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import
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
  
  File? _imageFile;
  final _picker = ImagePicker();
  bool _isSubmitting = false;

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

  Future<void> _submitReport() async {
    if (_itemCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText("Please enter item name")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Simulate submission to Supabase
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText("Item Logged Successfully"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Report Lost Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _imageFile != null 
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        TranslatedText("Tap to take photo", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _itemCtrl,
              decoration: const InputDecoration(label: TranslatedText("Item Type (e.g., Wallet)"), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _seatCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(label: TranslatedText("Found near Seat #"), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(label: TranslatedText("Description (Color, Brand, etc.)"), border: OutlineInputBorder()),
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
                    : const TranslatedText("LOG ITEM", style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _isSubmitting ? null : _submitReport,
              ),
            )
          ],
        ),
      ),
    );
  }
}