import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitBug() async {
    if (_subjectCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = supabase.auth.currentUser;
      final email = user?.email ?? "Anonymous Passenger";

      await supabase.from('complaints').insert({
        'subject': _subjectCtrl.text,
        'description': _descCtrl.text,
        'user_email': email,
        'status': 'OPEN',
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            content: const Text("Thank you! Your report has been sent to the Admin team."),
            actions: [
              TextButton(
                onPressed: () { 
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, 
                child: const Text("OK")
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sending report: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report a Bug")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Found an issue?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Please describe the bug so we can fix it.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(
                labelText: "Subject",
                hintText: "e.g., App crashed on payment",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "Explain what happened...",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("SUBMIT REPORT"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, 
                  foregroundColor: Colors.white
                ),
                onPressed: _isSubmitting ? null : _submitBug,
              ),
            ),
          ],
        ),
      ),
    );
  }
}