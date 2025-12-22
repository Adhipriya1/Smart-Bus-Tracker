import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PassengerReviewScreen extends StatefulWidget {
  const PassengerReviewScreen({super.key});

  @override
  State<PassengerReviewScreen> createState() => _PassengerReviewScreenState();
}

class _PassengerReviewScreenState extends State<PassengerReviewScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _commentCtrl = TextEditingController();
  
  // State variables
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

  // Fetch list of active buses so passenger can select which one they rode
  Future<void> _fetchBuses() async {
    try {
      final data = await supabase
          .from('buses')
          .select('id, license_plate')
          .eq('is_active', true)
          .order('license_plate');
      
      if (mounted) {
        setState(() {
          _buses = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview() async {
    if (_selectedBusId == null || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a bus and give a rating.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = supabase.auth.currentUser;
      final passengerName = user?.userMetadata?['full_name'] ?? user?.email ?? "Anonymous";

      // Insert into 'reviews' table
      await supabase.from('reviews').insert({
        // Find the license plate string based on the ID for easier reading in Admin
        'bus_id': _buses.firstWhere((b) => b['id'] == _selectedBusId)['license_plate'], 
        'rating': _rating,
        'comment': _commentCtrl.text,
        'passenger_name': passengerName,
        // created_at is auto-generated
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            content: const Text("Thank you for your feedback!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: const Text("CLOSE"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Helper to build Star Rating Row
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
      appBar: AppBar(title: const Text("Rate Your Ride")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Which bus were you on?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedBusId,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Select Bus Number"),
                    items: _buses.map((b) {
                      return DropdownMenuItem<String>(
                        value: b['id'],
                        child: Text(b['license_plate']),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedBusId = v),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  const Center(child: Text("How was your experience?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  const SizedBox(height: 10),
                  _buildStarRating(),
                  
                  const SizedBox(height: 30),
                  
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Comments (Optional)",
                      hintText: "Driver was polite, Bus was clean...",
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
                          : const Text("SUBMIT REVIEW", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}