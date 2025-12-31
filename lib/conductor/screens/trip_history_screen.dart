import 'package:flutter/material.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    // START SIMULATION 
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        history = [
          {"date": "2023-12-16", "route": "101 - Central to Market", "tickets": 45, "earnings": 1125},
          {"date": "2023-12-15", "route": "102 - City Loop", "tickets": 32, "earnings": 800},
          {"date": "2023-12-14", "route": "101 - Central to Market", "tickets": 50, "earnings": 1250},
        ];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Trip History")),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final trip = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                              child: Text(trip['date'], style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.confirmation_number_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("${trip['tickets']} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                const TranslatedText("Tickets", style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const TranslatedText("ROUTE", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(trip['route'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                        
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.green.withOpacity(0.1) : Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.green.withOpacity(0.3) : Colors.green.shade100,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TranslatedText(
                                "TOTAL EARNINGS",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.green[100] : Colors.green[800],
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                "₹${trip['earnings']}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.green[300] : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}