import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText("Please fill all fields")));
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TranslatedText("Report submitted successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Report Bug")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const TranslatedText(
              "Found a bug or have a suggestion? Let us know!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(
                label: TranslatedText("Subject"),
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
                label: TranslatedText("Description"),
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
                    : const TranslatedText("SUBMIT REPORT"),
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