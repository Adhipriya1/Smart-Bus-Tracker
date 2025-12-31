import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import
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
  bool get isTamil {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ta';
  }

  Future<void> _handleAuth() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText('Please fill all fields')));
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText('Signup Successful! Please Login.')));
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
              MaterialPageRoute(builder: (_) => const ConductorHomeScreen())
            );
          }
        }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_bus, size: 80, color: primaryColor),
              const SizedBox(height: 20),
              TranslatedText(
                _isSignup ? "Create Account" : "Conductor Login", 
                style: TextStyle(fontSize: isTamil? 15:24, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 40),

              if (_isSignup)
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    label: TranslatedText("Full Name"), 
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person)
                  ),
                ),
              if (_isSignup) const SizedBox(height: 20),

              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  label: TranslatedText("Email"), 
                  border: OutlineInputBorder(), 
                  prefixIcon: Icon(Icons.email)
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  label: TranslatedText("Password"), 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock)
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : TranslatedText(_isSignup ? "SIGN UP" : "LOGIN", style:TextStyle(fontSize: isTamil? 12:16, fontWeight: FontWeight.bold)),
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
                // 🔴 FIX: Changed Row to Wrap to handle overflow on small screens
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                     TranslatedText(_isSignup ? "Already have an account? " : "Don't have an account? ", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: isTamil? 12:16)),
                     TranslatedText(_isSignup ? "Login" : "Sign Up", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold,fontSize: isTamil? 12:16)),
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