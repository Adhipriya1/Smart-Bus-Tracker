import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../conductor/screens/conductor_home_screen.dart'; 

class ConductorLoginScreen extends StatefulWidget {
  const ConductorLoginScreen({super.key});

  @override
  State<ConductorLoginScreen> createState() => _ConductorLoginScreenState();
}

class _ConductorLoginScreenState extends State<ConductorLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(); 
  
  bool _isLoading = false;
  bool _isSignup = false; 

  Future<void> _handleAuth() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignup) {
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          data: {'full_name': _nameCtrl.text.trim()}, 
        );

        if (response.user != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account Created! You can now log in."), backgroundColor: Colors.green),
            );
            setState(() => _isSignup = false); 
          }
        }
      } else {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
        );

        if (response.user != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const ConductorHomeScreen())
            );
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme variables
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDark ? Colors.white : Colors.blue[900];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignup ? "Create Account" : "Conductor Login"),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.directions_bus_filled, size: 80, color: primaryColor),
              const SizedBox(height: 10),
              Text(
                _isSignup ? "Join Smart Bus" : "Welcome Back",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 30),

              if (_isSignup) ...[
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    label: const Text("Full Name"),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  label: const Text("Email ID"),
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  label: const Text("Password"),
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Uses Blue[900] from theme
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isSignup ? "SIGN UP" : "LOGIN", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignup = !_isSignup;
                    _emailCtrl.clear();
                    _passwordCtrl.clear();
                    _nameCtrl.clear();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text(_isSignup ? "Already have an account? " : "Don't have an account? ", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 16)),
                     Text(_isSignup ? "Login" : "Sign Up", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}