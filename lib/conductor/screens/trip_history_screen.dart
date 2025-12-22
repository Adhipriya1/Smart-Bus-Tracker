import 'package:flutter/material.dart';


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
    // Theme variables for Dark/Light mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final cardColor = Theme.of(context).cardTheme.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip History"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final trip = history[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // 1. TOP SECTION: Trip Details
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.history, color: isDark ? Colors.blue[200] : Colors.blue),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip['route'],
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: subTextColor),
                                      const SizedBox(width: 6),
                                      Text("${trip['date']} • ", style: TextStyle(color: subTextColor)),
                                      Text("${trip['tickets']} ", style: TextStyle(color: subTextColor)),
                                      Text("Passengers", style: TextStyle(color: subTextColor)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 2. BOTTOM SECTION: Earnings Display (Full Width Container)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.green.withOpacity(0.3) : Colors.green.shade100,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
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