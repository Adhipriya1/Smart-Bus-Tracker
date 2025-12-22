import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:timeago/timeago.dart' as timeago; // Optional: for "5 mins ago"

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        elevation: 1,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('notifications')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false), // Newest first
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final alerts = snapshot.data!;
          
          if (alerts.isEmpty) {
            return const Center(child: Text("No new notifications"));
          }

          return ListView.separated(
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.notifications, color: Colors.blue),
                ),
                title: Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(alert['body']),
                // trailing: Text(timeago.format(DateTime.parse(alert['created_at']))), // Use timeago if installed
              );
            },
          );
        },
      ),
    );
  }
}