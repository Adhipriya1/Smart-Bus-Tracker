import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PassengerEditProfileScreen extends StatefulWidget {
  const PassengerEditProfileScreen({super.key});

  @override
  State<PassengerEditProfileScreen> createState() => _PassengerEditProfileScreenState();
}

class _PassengerEditProfileScreenState extends State<PassengerEditProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  // State
  bool _isLoading = false;
  File? _imageFile;
  String? _avatarUrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      _nameCtrl.text = user.userMetadata?['full_name'] ?? '';
      _phoneCtrl.text = user.userMetadata?['phone'] ?? '';
      setState(() {
        _avatarUrl = user.userMetadata?['avatar_url'];
      });
    }
  }

  // 1. Pick Image
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
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

  // 2. Upload Image & Save Profile
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      String? newAvatarUrl = _avatarUrl;

      // A. Upload Image if changed
      if (_imageFile != null) {
        final fileExt = _imageFile!.path.split('.').last;
        final fileName = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        
        await supabase.storage.from('avatars').upload(
          fileName,
          _imageFile!,
          fileOptions: const FileOptions(upsert: true),
        );

        newAvatarUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      // B. Update User Metadata
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
            'avatar_url': newAvatarUrl,
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green)
        );
        Navigator.pop(context); // Go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- AVATAR UPLOAD ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
                    child: (_imageFile == null && _avatarUrl == null)
                        ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text("Tap camera to change photo", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            
            const SizedBox(height: 30),

            // --- FORM FIELDS ---
            _buildTextField(
              controller: _nameCtrl, 
              label: "Full Name", 
              icon: Icons.person_outline,
              isDark: isDark
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _phoneCtrl, 
              label: "Phone Number", 
              icon: Icons.phone_outlined,
              type: TextInputType.phone,
              isDark: isDark
            ),
            
            const SizedBox(height: 40),

            // --- SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SAVE CHANGES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    TextInputType type = TextInputType.text,
    required bool isDark
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.white,
      ),
    );
  }
}