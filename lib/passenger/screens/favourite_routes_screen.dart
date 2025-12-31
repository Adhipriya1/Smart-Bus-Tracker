import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_bus_tracker/common/widgets/translated_text.dart';

class FavouriteRoutesScreen extends StatefulWidget {
  const FavouriteRoutesScreen({super.key});

  @override
  State<FavouriteRoutesScreen> createState() => _FavouriteRoutesScreenState();
}

class _FavouriteRoutesScreenState extends State<FavouriteRoutesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _allRoutes = [];
  Set<String> _manualFavorites = {}; 
  bool _isLoadingRoutes = true;

  @override
  void initState() {
    super.initState();
    _loadStaticData();
  }

  Future<void> _loadStaticData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final routesData = await supabase.from('routes').select('id, route_number, name').eq('is_active', true).order('route_number');
      final favData = await supabase.from('favourite_routes').select('route_id').eq('user_id', user.id);
      
      if (mounted) {
        setState(() {
          _allRoutes = List<Map<String, dynamic>>.from(routesData);
          _manualFavorites = (favData as List).map((e) => e['route_id'] as String).toSet();
          _isLoadingRoutes = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() => _isLoadingRoutes = false);
    }
  }

  Future<void> _toggleFavorite(String routeId, String routeName) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      if (_manualFavorites.contains(routeId)) {
        _manualFavorites.remove(routeId);
        supabase.from('favourite_routes').delete().match({'user_id': user.id, 'route_id': routeId}).then((_) {});
      } else {
        _manualFavorites.add(routeId);
        supabase.from('favourite_routes').insert({'user_id': user.id, 'route_id': routeId}).then((_) {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Frequent Routes")),
      body: _isLoadingRoutes
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('tickets').stream(primaryKey: ['id']).eq('user_id', supabase.auth.currentUser?.id ?? ''),
              builder: (context, snapshot) {
                final tickets = snapshot.data ?? [];
                
                final routeCounts = <String, int>{};
                for (var t in tickets) {
                  final rid = t['route_id'] as String?;
                  if (rid != null) routeCounts[rid] = (routeCounts[rid] ?? 0) + 1;
                }

                // Sort: Favorites first, then most frequent
                _allRoutes.sort((a, b) {
                  final idA = a['id'];
                  final idB = b['id'];
                  final isFavA = _manualFavorites.contains(idA);
                  final isFavB = _manualFavorites.contains(idB);
                  
                  if (isFavA && !isFavB) return -1;
                  if (!isFavA && isFavB) return 1;
                  
                  final countA = routeCounts[idA] ?? 0;
                  final countB = routeCounts[idB] ?? 0;
                  return countB.compareTo(countA);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allRoutes.length,
                  itemBuilder: (context, index) {
                    final route = _allRoutes[index];
                    final routeId = route['id'];
                    final routeNum = route['route_number'];
                    final routeName = route['name'];
                    final tripCount = routeCounts[routeId] ?? 0;
                    final isFav = _manualFavorites.contains(routeId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isFav ? Colors.red[50] : Colors.blue[50],
                          child: Icon(Icons.directions_bus, color: isFav ? Colors.red : Colors.blue),
                        ),
                        title: Text("$routeNum - $routeName", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tripCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[700] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("$tripCount ", style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey[800], fontWeight: FontWeight.bold)),
                                    const TranslatedText("Trips", style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ),
                            if (tripCount == 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: TranslatedText("No travel history", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              )
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey[400],
                            size: 28,
                          ),
                          onPressed: () => _toggleFavorite(routeId, routeName),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}