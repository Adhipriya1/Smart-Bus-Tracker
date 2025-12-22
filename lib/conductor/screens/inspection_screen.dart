import 'package:flutter/material.dart';
import 'ticketing_screen.dart'; //

class InspectionScreen extends StatefulWidget {
  // Added arguments to pass data forward
  final String busId;
  final String routeId;

  const InspectionScreen({
    super.key, 
    required this.busId, 
    required this.routeId
  });

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  bool tiresOk = false;
  bool fuelOk = false;
  bool firstAidOk = false;
  bool lightsOk = false;
  bool _isSubmitting = false;

  Future<void> _submitInspection() async {
    if (!tiresOk || !fuelOk || !firstAidOk || !lightsOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All checks must be passed to start!"), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    // Simulate DB Save (In a real app, save inspection record here)
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      // CHANGED: Navigate to Ticketing Screen
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (_) => TicketingScreen(
            busId: widget.busId, 
            routeId: widget.routeId
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pre-Trip Inspection"), 
        backgroundColor: Colors.blue[900], 
        foregroundColor: Colors.white
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Mandatory Safety Checks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Please verify the following before starting:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            _buildCheckItem("Tires Pressure & Condition", tiresOk, (v) => setState(() => tiresOk = v!)),
            _buildCheckItem("Fuel Level > 50%", fuelOk, (v) => setState(() => fuelOk = v!)),
            _buildCheckItem("First Aid Kit Available", firstAidOk, (v) => setState(() => firstAidOk = v!)),
            _buildCheckItem("Lights & Indicators Working", lightsOk, (v) => setState(() => lightsOk = v!)),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
                onPressed: _isSubmitting ? null : _submitInspection,
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("CONFIRM & PROCEED"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: TextStyle(fontWeight: value ? FontWeight.bold : FontWeight.normal)),
      value: value,
      activeColor: Colors.green,
      onChanged: onChanged,
    );
  }
}