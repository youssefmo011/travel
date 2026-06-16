import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/chat_screen/chat_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/whats_new_screen.dart';

class ExploreScreen extends StatefulWidget {
  static const String routeName = '/explore';
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final String _otmApiKey = "5ae2e3f221c38a28845f05b6b4e9edfa5fde541b31eed5871b56465b";
  List<Map<String, dynamic>> _places = [];
  bool _isLoading = true;
  final String _cacheBoxName = 'explore_cache';
  String _selectedCategory = "All";

  final List<String> _categories = ["All", "Hiking", "Cafes", "Nightlife", "Museums"];

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadWorldData();
  }

  void _loadCachedData() {
    var box = Hive.box(_cacheBoxName);
    List? cachedData = box.get('places');
    if (cachedData != null) {
      setState(() {
        _places = List<Map<String, dynamic>>.from(
          cachedData.map((item) => Map<String, dynamic>.from(item)),
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWorldData() async {
    if (!mounted) return;
    if (_places.isEmpty) setState(() => _isLoading = true);
    final data = await _fetchPlaces();
    if (mounted && data.isNotEmpty) {
      var box = Hive.box(_cacheBoxName);
      await box.put('places', data);
      setState(() {
        _places = data;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPlaces() async {
    final random = Random();
    final List<Map<String, dynamic>> globalCities = [
      {'lon': 139.6917, 'lat': 35.6895, 'city': 'Tokyo'},
      {'lon': 12.4964, 'lat': 41.9028, 'city': 'Rome'},
      {'lon': 2.3522, 'lat': 48.8566, 'city': 'Paris'},
      {'lon': 9.19, 'lat': 45.4642, 'city': 'Milan'},
      {'lon': -0.1278, 'lat': 51.5074, 'city': 'London'},
    ];
    final city = globalCities[random.nextInt(globalCities.length)];
    List<Map<String, dynamic>> results = [];

    try {
      final String listUrl =
          "https://api.opentripmap.com/0.1/en/places/radius?radius=20000&lon=${city['lon']}&lat=${city['lat']}&kinds=interesting_places&rate=3&format=json&limit=40&apikey=$_otmApiKey";
      final listRes = await http.get(Uri.parse(listUrl));
      if (listRes.statusCode != 200) return results;
      final List<dynamic> list = jsonDecode(listRes.body);
      final namedPlaces = list.where((p) => p['name'] != null && p['name'].toString().trim().isNotEmpty).toList();

      for (var place in namedPlaces) {
        if (!mounted) break;
        final String name = place['name'].toString().trim();
        final String category = (place['kinds'] ?? '').toString().split(',').first.replaceAll('_', ' ');
        final String? imageUrl = await _fetchWikipediaImage(name);
        if (imageUrl != null) {
          results.add({'name': name, 'city': city['city'], 'image': imageUrl, 'category': category});
          if (results.length >= 15) break;
        }
      }
    } catch (_) {}
    return results;
  }

  Future<String?> _fetchWikipediaImage(String placeName) async {
    try {
      final String encoded = Uri.encodeComponent(placeName);
      final String url = "https://en.wikipedia.org/w/api.php?action=query&titles=$encoded&prop=pageimages&format=json&pithumbsize=600&origin=*";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      final pages = data['query']?['pages'] as Map<String, dynamic>?;
      if (pages == null) return null;
      for (var page in pages.values) {
        final thumb = page['thumbnail']?['source'];
        if (thumb != null) return thumb.toString();
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchSection(),
                    _buildCategories(),
                    _buildTrendingHeader(),
                    _buildVibeGrid(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Explore", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1B2612))),
          Row(
            children: [
              IconButton(
                icon: const Badge(child: Icon(Icons.notifications_outlined, color: Colors.black87)),
                onPressed: () => Navigator.pushNamed(context, WhatsNewScreen.routeName),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF6D8B6D).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF6D8B6D), size: 20),
                ),
                onPressed: () => Navigator.pushNamed(context, ChatScreen.routeName),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), shape: BoxShape.circle),
                  child: const Icon(Icons.grid_view_rounded, color: Color(0xFF6D8B6D), size: 18),
                ),
                onPressed: () {},
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 22),
                  SizedBox(width: 10),
                  Text("Find your next vibe...", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          Container(
            height: 55, width: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: const Icon(Icons.tune, color: Color(0xFF6D8B6D)),
          )
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6D8B6D) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFF6D8B6D), size: 20),
              SizedBox(width: 10),
              Text("Trending Vibes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1B2612))),
            ],
          ),
          Text("See all", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVibeGrid() {
    if (_isLoading && _places.isEmpty) {
      return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: Color(0xFF6D8B6D))));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _places.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.68, // Tall cards
      ),
      itemBuilder: (context, index) => _buildVibeCard(_places[index]),
    );
  }

  Widget _buildVibeCard(Map<String, dynamic> place) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(35)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: place['image'],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade100),
              errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
            ),
            // Top heart icon
            Positioned(
              top: 15, right: 15,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.favorite_border, color: Colors.white, size: 16),
              ),
            ),
            // Centered-bottom Blur info box
            Positioned(
              bottom: 12, left: 10, right: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 10),
                            const SizedBox(width: 4),
                            Expanded(child: Text(place['city'].toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(place['name'], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Text(place['category'], style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
