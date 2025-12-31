import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart'; // Updated Import

class AdminRoutesScreen extends StatefulWidget {
  const AdminRoutesScreen({super.key});
  @override
  State<AdminRoutesScreen> createState() => _AdminRoutesScreenState();
}

class _AdminRoutesScreenState extends State<AdminRoutesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _numCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  void _addRoute() async {
    if (_numCtrl.text.isEmpty) return;
    await supabase.from('routes').insert({
      'route_number': _numCtrl.text,
      'name': _nameCtrl.text,
      'is_active': true
    });
    _numCtrl.clear(); _nameCtrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Manage Routes")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(child: TextField(controller: _numCtrl, decoration: const InputDecoration(label: TranslatedText("Route No")))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(label: TranslatedText("Route Name")))),
                    ]),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _addRoute, child: const TranslatedText("Add Route"))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: supabase.from('routes').stream(primaryKey: ['id']).order('created_at'),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final routes = snapshot.data as List;
                return ListView.builder(
                  itemCount: routes.length,
                  itemBuilder: (ctx, i) => ListTile(
                    leading: const Icon(Icons.directions_bus),
                    title: Text(routes[i]['route_number']),
                    subtitle: Text(routes[i]['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => supabase.from('routes').delete().eq('id', routes[i]['id']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}