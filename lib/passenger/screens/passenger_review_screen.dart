import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';

class PassengerReviewScreen extends StatefulWidget {
  const PassengerReviewScreen({super.key});

  @override
  State<PassengerReviewScreen> createState() => _PassengerReviewScreenState();
}

class _PassengerReviewScreenState extends State<PassengerReviewScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _commentCtrl = TextEditingController();
  
  String? _selectedBusId;
  int _rating = 0;
  List<Map<String, dynamic>> _buses = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchBuses();
  }

  Future<void> _fetchBuses() async {
    try {
      final data = await supabase.from('buses').select('id, license_plate').eq('is_active', true).order('license_plate');
      
      if (mounted) {
        setState(() {
          _buses = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _selectedBusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText("Please select bus and rating")));
      return;
    }

    setState(() => _isSubmitting = true);
    final user = supabase.auth.currentUser;

    try {
      await supabase.from('reviews').insert({
        'bus_id': _selectedBusId,
        'passenger_id': user?.id,
        'passenger_name': user?.userMetadata?['full_name'] ?? 'Anonymous',
        'rating': _rating,
        'comment': _commentCtrl.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText("Thank you for your feedback!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40,
          ),
          onPressed: () => setState(() => _rating = index + 1),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Rate Your Ride")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.rate_review_outlined, size: 80, color: Colors.blueGrey),
                  const SizedBox(height: 20),
                  const TranslatedText("How was your recent trip?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      label: TranslatedText("Select Bus"),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedBusId,
                    items: _buses.map((bus) => DropdownMenuItem(
                      value: bus['id'] as String,
                      child: Text(bus['license_plate']), // License plates usually don't translate
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedBusId = val),
                  ),
                  
                  const SizedBox(height: 30),
                  const Center(child: TranslatedText("Tap to Rate", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 18))),
                  const SizedBox(height: 10),
                  _buildStarRating(),
                  
                  const SizedBox(height: 30),
                  
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      label: TranslatedText("Comments (Optional)"),
                      hintText: "Driver was polite, Bus was clean...", // Standard hint
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                      onPressed: _isSubmitting ? null : _submitReview,
                      child: _isSubmitting 
                          ? const CircularProgressIndicator() 
                          : const TranslatedText("SUBMIT REVIEW", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}