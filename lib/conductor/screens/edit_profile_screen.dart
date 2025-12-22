import 'dart:io'; // Needed for File
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Import the picker

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _picker = ImagePicker();
  final user = Supabase.instance.client.auth.currentUser;
  
  bool _isLoading = false;
  File? _imageFile; // To store the selected image locally
  String? _avatarUrl; // To store the URL from Supabase

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = user?.userMetadata?['full_name'] ?? "";
    _avatarUrl = user?.userMetadata?['avatar_url']; // Load existing image if any
  }

  // 1. Pick Image Function
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, // Or ImageSource.camera
        maxWidth: 600, // Compress image size
      );

      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
        // Optional: Upload immediately upon selection
        await _uploadImage(File(pickedFile.path)); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  // 2. Upload Image Function
  Future<void> _uploadImage(File file) async {
    setState(() => _isLoading = true);
    try {
      final userId = user!.id;
      final fileExt = file.path.split('.').last;
      final fileName = '$userId/avatar.$fileExt'; // Unique path per user

      // Upload to Supabase 'avatars' bucket
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true), // Overwrite old image
          );

      // Get Public URL
      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update User Metadata with new URL
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': imageUrl}),
      );

      setState(() {
        _avatarUrl = imageUrl;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image Uploaded!"), backgroundColor: Colors.green));

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Failed: $e")));
      }
    }
  }

  // 3. Update Name Function (Existing)
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': _nameCtrl.text}),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView( // Added scroll for small screens
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // IMAGE DISPLAY LOGIC
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) // Show local file if just picked
                        : (_avatarUrl != null 
                            ? NetworkImage(_avatarUrl!) as ImageProvider // Show cloud URL if exists
                            : null), 
                    child: (_imageFile == null && _avatarUrl == null)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  
                  // Camera Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              enabled: false,
              decoration: InputDecoration(labelText: "Email", border: const OutlineInputBorder(), hintText: user?.email),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading ? const CircularProgressIndicator() : const Text("SAVE CHANGES"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}