import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText("Notifications"),
        elevation: 1,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('notifications')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false), 
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final alerts = snapshot.data!;
          
          if (alerts.isEmpty) {
            return const Center(child: TranslatedText("No new notifications"));
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
                title: TranslatedText(alert['title'] ?? 'Notification', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: TranslatedText(alert['body'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}