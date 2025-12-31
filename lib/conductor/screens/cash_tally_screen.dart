import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import
import 'package:supabase_flutter/supabase_flutter.dart';

class CashTallyScreen extends StatefulWidget {
  final String busId;
  const CashTallyScreen({super.key, required this.busId});

  @override
  State<CashTallyScreen> createState() => _CashTallyScreenState();
}

class _CashTallyScreenState extends State<CashTallyScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  final Map<int, TextEditingController> _controllers = {
    500: TextEditingController(),
    200: TextEditingController(),
    100: TextEditingController(),
    50: TextEditingController(),
    20: TextEditingController(),
    10: TextEditingController(),
  };

  int _systemTotal = 0;
  int _physicalTotal = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchSystemTotal();
    for (var controller in _controllers.values) {
      controller.addListener(_calculatePhysical);
    }
  }

  Future<void> _fetchSystemTotal() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final response = await supabase
          .from('tickets')
          .select('amount_paid')
          .eq('bus_id', widget.busId)
          .gte('issued_at', startOfDay)
          .lte('issued_at', endOfDay);

      int total = 0;
      for (var row in response) {
        total += (row['amount_paid'] as num).toInt();
      }

      if (mounted) {
        setState(() {
          _systemTotal = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculatePhysical() {
    int total = 0;
    _controllers.forEach((denom, ctrl) {
      int count = int.tryParse(ctrl.text) ?? 0;
      total += (count * denom);
    });
    setState(() => _physicalTotal = total);
  }

  Future<void> _submitTally() async {
    if (_physicalTotal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: TranslatedText("Please enter cash amounts first.")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = supabase.auth.currentUser;
      
      await supabase.from('daily_collections').insert({
        'bus_id': widget.busId,
        'amount_collected': _physicalTotal,
        'conductor_id': user?.id,
        'date': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TranslatedText("Collection submitted successfully to Admin."),
                const SizedBox(height: 5),
                Text("Total: ₹$_physicalTotal", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to Home
                },
                child: const TranslatedText("DONE"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int diff = _physicalTotal - _systemTotal;
    Color statusColor = diff == 0 ? Colors.green : (diff < 0 ? Colors.red : Colors.orange);
    String statusText = diff == 0 ? "Perfect Match" : (diff < 0 ? "Shortage: ₹${diff.abs()}" : "Excess: ₹$diff");
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Daily Cash Tally"), backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // HEADER: SUMMARY
              Container(
                padding: const EdgeInsets.all(20),
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem("System", "₹$_systemTotal", Colors.blue),
                    _buildSummaryItem("Physical", "₹$_physicalTotal", isDark ? Colors.white : Colors.black),
                    _buildSummaryItem("Status", statusText, statusColor), // Note: statusText contains numbers, might just keep as Text or handle partially
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const TranslatedText("Enter Note Counts:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    ..._controllers.entries.map((entry) => _buildNoteInput(entry.key, entry.value, isDark)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: _isSubmitting ? null : _submitTally, 
                    child: _isSubmitting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const TranslatedText("SUBMIT TALLY", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        TranslatedText(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildNoteInput(int denom, TextEditingController ctrl, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: isDark ? Colors.green.withOpacity(0.2) : Colors.green[50], 
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Text("₹$denom", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ),
            const SizedBox(width: 16),
            Text("x", style: TextStyle(fontSize: 18, color: isDark ? Colors.grey[400] : Colors.grey)),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
                decoration: const InputDecoration(border: InputBorder.none, hintText: "0"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}