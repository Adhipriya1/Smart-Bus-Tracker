import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PassengerEditProfileScreen extends StatefulWidget {
  const PassengerEditProfileScreen({super.key});

  @override
  State<PassengerEditProfileScreen> createState() => _PassengerEditProfileScreenState();
}

class _PassengerEditProfileScreenState extends State<PassengerEditProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
        await _uploadImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    setState(() => _isLoading = true);
    
    try {
      final user = supabase.auth.currentUser;
      final fileExt = _imageFile!.path.split('.').last;
      final fileName = '${user!.id}/avatar.$fileExt';

      await supabase.storage.from('avatars').upload(
        fileName, 
        _imageFile!,
        fileOptions: const FileOptions(upsert: true),
      );

      final imageUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      
      await supabase.auth.updateUser(UserAttributes(data: {'avatar_url': imageUrl}));
      
      setState(() {
        _avatarUrl = imageUrl;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(data: {
          'full_name': _nameCtrl.text,
          'phone': _phoneCtrl.text,
        }),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText('Profile Updated!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageFile != null 
                        ? FileImage(_imageFile!) 
                        : (_avatarUrl != null ? NetworkImage(_avatarUrl!) as ImageProvider : null),
                    child: (_imageFile == null && _avatarUrl == null) 
                        ? const Icon(Icons.person, size: 60, color: Colors.grey) 
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            _buildTextField(
              controller: _nameCtrl, 
              label: "Full Name", 
              icon: Icons.person,
              isDark: isDark
            ),
            const SizedBox(height: 20),
            
            _buildTextField(
              controller: _phoneCtrl, 
              label: "Phone Number", 
              icon: Icons.phone, 
              type: TextInputType.phone,
              isDark: isDark
            ),
            const SizedBox(height: 40),
            
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
                  : const TranslatedText('SAVE CHANGES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        label: TranslatedText(label),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.white,
      ),
    );
  }
}