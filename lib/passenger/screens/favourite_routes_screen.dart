import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteRoutesScreen extends StatefulWidget {
  const FavouriteRoutesScreen({super.key});

  @override
  State<FavouriteRoutesScreen> createState() => _FavouriteRoutesScreenState();
}

class _FavouriteRoutesScreenState extends State<FavouriteRoutesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // Cache for static data
  List<Map<String, dynamic>> _allRoutes = [];
  Set<String> _manualFavorites = {}; 
  bool _isLoadingRoutes = true;

  @override
  void initState() {
    super.initState();
    _loadStaticData();
  }

  // 1. Load Routes & Manual Favorites (These don't need extreme realtime updates usually)
  Future<void> _loadStaticData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Fetch Route Definitions (ID, Name, Number)
      final routesData = await supabase
          .from('routes')
          .select('id, route_number, name')
          .eq('is_active', true)
          .order('route_number');
      
      // Fetch Manual Favorites (Hearts)
      final favData = await supabase
          .from('passenger_favourites')
          .select('route_number')
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _allRoutes = List<Map<String, dynamic>>.from(routesData);
          _manualFavorites = (favData as List).map((e) => e['route_number'] as String).toSet();
          _isLoadingRoutes = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRoutes = false);
    }
  }

  // 2. Toggle Manual Favorite (Heart Icon)
  Future<void> _toggleFavorite(String routeNum, String routeName) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      if (_manualFavorites.contains(routeNum)) {
        _manualFavorites.remove(routeNum);
      } else {
        _manualFavorites.add(routeNum);
      }
    });

    try {
      if (_manualFavorites.contains(routeNum)) {
        await supabase.from('passenger_favourites').insert({
          'user_id': user.id,
          'route_number': routeNum,
          'route_name': routeName,
        });
      } else {
        await supabase.from('passenger_favourites').delete().match({
          'user_id': user.id,
          'route_number': routeNum,
        });
      }
    } catch (e) {
      _loadStaticData(); // Revert on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) return const Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Frequent Routes"),
        elevation: 1,
      ),
      body: _isLoadingRoutes
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Map<String, dynamic>>>(
              // 3. REALTIME STREAM: Listen to user's completed trips
              stream: supabase
                  .from('passenger_trips')
                  .stream(primaryKey: ['id'])
                  .eq('passenger_id', user.id)
                  .order('created_at', ascending: false), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 4. Calculate Frequency
                final trips = snapshot.data ?? [];
                Map<String, int> routeCounts = {};
                
                for (var trip in trips) {
                  final routeId = trip['route_id']; // Ensure your passenger_trips has 'route_id'
                  if (routeId != null) {
                    routeCounts[routeId] = (routeCounts[routeId] ?? 0) + 1;
                  }
                }

                // 5. Sort Routes: Most Traveled First
                List<Map<String, dynamic>> sortedRoutes = List.from(_allRoutes);
                sortedRoutes.sort((a, b) {
                  int countA = routeCounts[a['id']] ?? 0;
                  int countB = routeCounts[b['id']] ?? 0;
                  return countB.compareTo(countA); // Descending order
                });

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedRoutes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final route = sortedRoutes[index];
                    final routeId = route['id'];
                    final routeNum = route['route_number'] ?? "000";
                    final routeName = route['name'] ?? "Unknown";
                    
                    final tripCount = routeCounts[routeId] ?? 0;
                    final isFav = _manualFavorites.contains(routeNum);

                    // Highlight "Most Traveled" routes visually
                    final isFrequent = tripCount > 2; 

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isFrequent 
                            ? Border.all(color: Colors.green.withOpacity(0.5), width: 1.5) 
                            : null, // Green border for frequent routes
                        boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isFrequent ? Colors.green[100] : Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                routeNum,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  color: isFrequent ? Colors.green[800] : Colors.blue[900], 
                                  fontSize: 14
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(routeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Row(
                          children: [
                            if (tripCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[700] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: Text(
                                  "$tripCount Trips", 
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey[800], fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (tripCount == 0)
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0),
                                child: Text("No travel history", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              )
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey[400],
                            size: 28,
                          ),
                          onPressed: () => _toggleFavorite(routeNum, routeName),
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