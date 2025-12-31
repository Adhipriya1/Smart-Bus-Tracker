import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';

class PassengerLoginScreen extends StatefulWidget {
  const PassengerLoginScreen({super.key});

  @override
  State<PassengerLoginScreen> createState() => _PassengerLoginScreenState();
}

class _PassengerLoginScreenState extends State<PassengerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  
  bool _isLoading = false;
  bool _isSignUp = false; 
  bool _isPasswordVisible = false;
  bool get isTamil {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ta';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();
    

    try {
      if (_isSignUp) {
        await supabase.auth.signUp(email: email, password: password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: TranslatedText("Account created! Please log in.")),
          );
          setState(() => _isSignUp = false);
        }
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
        if (mounted) Navigator.pushReplacementNamed(context, '/passenger-home');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bus_filled, size: 80, color: primaryColor),
                const SizedBox(height: 20),
                TranslatedText(
                  _isSignUp ? "Create Account" : "Passenger Login",
                  style: TextStyle(fontSize: isTamil? 15:20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TranslatedText(
                  _isSignUp ? "Sign up to track buses effortlessly" : "Welcome back! Login to continue.",
                  style:  TextStyle(color: Colors.grey,fontSize: isTamil? 12:14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    label: TranslatedText("Email Address"),
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (v) => v!.isEmpty ? 'Email required' : null, 
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    label: const TranslatedText("Password"),
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                ),
                
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : TranslatedText(
                          _isSignUp ? "SIGN UP" : "LOGIN",
                          style: TextStyle(fontSize: isTamil? 12:16, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔴 FIX: Changed from Row to Wrap to prevent Overflow errors
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TranslatedText(
                      _isSignUp ? "Already have an account? " : "Don't have an account? ", 
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: isTamil? 12:14),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _isSignUp = !_isSignUp;
                        _formKey.currentState?.reset();
                      }),
                      child: TranslatedText(
                        _isSignUp ? "Login" : "Sign Up",
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: isTamil? 12:14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}