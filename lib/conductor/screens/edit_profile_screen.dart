import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; 

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
  File? _imageFile;
  String? _avatarUrl; 

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = user?.userMetadata?['full_name'] ?? "";
    _avatarUrl = user?.userMetadata?['avatar_url']; 
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 600, 
      );

      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
        await _uploadImage(File(pickedFile.path)); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  Future<void> _uploadImage(File file) async {
    setState(() => _isLoading = true);
    try {
      final userId = user!.id;
      final fileExt = file.path.split('.').last;
      final fileName = '$userId/avatar.$fileExt'; 

      await Supabase.instance.client.storage
          .from('avatars')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true), 
          );

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_url': imageUrl}),
      );

      setState(() {
        _avatarUrl = imageUrl;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText("Image Uploaded!"), backgroundColor: Colors.green));

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Failed: $e')));
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': _nameCtrl.text}),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText('Profile Updated!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Edit Profile")),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) 
                        : (_avatarUrl != null 
                            ? NetworkImage(_avatarUrl!) as ImageProvider 
                            : null), 
                    child: (_imageFile == null && _avatarUrl == null)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  
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
              decoration: const InputDecoration(label: TranslatedText("Full Name"), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              enabled: false,
              decoration: InputDecoration(label: const TranslatedText("Email"), border: const OutlineInputBorder(), hintText: user?.email),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading ? const CircularProgressIndicator() : const TranslatedText("SAVE CHANGES"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}