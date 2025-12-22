import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/admin/screens/admin_signup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_dashboard.dart'; 

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleAdminLogin() async {
    setState(() => _isLoading = true);
    try {
      // 1. Authenticate with Supabase Auth
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (res.user == null) throw "Login failed";

      // 2. CHECK ROLE: Fetch user profile to see if they are an Admin
      final data = await supabase
          .from('profiles')
          .select('role')
          .eq('id', res.user!.id)
          .single();

      final role = data['role'] as String?;

      if (role == 'admin') {
        if (mounted) {
          // 3. Success: Navigate to Admin Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        }
      } else {
        // 4. Access Denied: User exists but is NOT an admin
        await supabase.auth.signOut(); 
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("ACCESS DENIED: You do not have Admin privileges."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.admin_panel_settings,
                      size: 64, color: Colors.blueGrey),
                  const SizedBox(height: 16),
                  const Text(
                    "Admin Portal",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      label: Text("Admin Email"),
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text("Password"),
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _handleAdminLogin,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("LOGIN"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminSignupScreen()));
                    },
                    child: const Text("Create Admin"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}