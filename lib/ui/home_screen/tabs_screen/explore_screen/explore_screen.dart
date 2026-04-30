import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadWorldData();
  }

  // تحميل البيانات المخزنة من Hive أولاً لسرعة الفتح
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
    
    // إذا لم يكن هناك كاش، نظهر الـ loading
    if (_places.isEmpty) {
      setState(() => _isLoading = true);
    }

    final data = await _fetchPlaces();
    
    if (mounted && data.isNotEmpty) {
      // حفظ البيانات الجديدة في Hive
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
    final city = _globalCities[random.nextInt(_globalCities.length)];
    List<Map<String, dynamic>> results = [];

    try {
      final String listUrl =
          "https://api.opentripmap.com/0.1/en/places/radius"
          "?radius=20000"
          "&lon=${city['lon']}"
          "&lat=${city['lat']}"
          "&kinds=interesting_places"
          "&rate=3"
          "&format=json"
          "&limit=40"
          "&apikey=$_otmApiKey";

      final listRes = await http.get(Uri.parse(listUrl));
      if (listRes.statusCode != 200) return results;

      final List<dynamic> list = jsonDecode(listRes.body);

      final namedPlaces = list
          .where((p) =>
              p['name'] != null &&
              p['name'].toString().trim().isNotEmpty)
          .take(25)
          .toList();

      for (var place in namedPlaces) {
        if (!mounted) break;

        final String name = place['name'].toString().trim();
        final String categoryRaw = (place['kinds'] ?? '').toString().split(',').first;
        final String category = categoryRaw.replaceAll('_', ' ').trim();

        final String? imageUrl = await _fetchWikipediaImage(name);

        if (imageUrl != null) {
          results.add({
            'name': name,
            'city': city['city'],
            'image': imageUrl,
            'category': category.isNotEmpty ? category : 'Landmark',
          });

          if (results.length >= 15) break;
        }
      }
    } catch (e) {
      debugPrint("fetchPlaces error: $e");
    }

    return results;
  }

  Future<String?> _fetchWikipediaImage(String placeName) async {
    try {
      final String encoded = Uri.encodeComponent(placeName);
      final String url =
          "https://en.wikipedia.org/w/api.php"
          "?action=query"
          "&titles=$encoded"
          "&prop=pageimages"
          "&format=json"
          "&pithumbsize=600"
          "&origin=*";

      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final pages = data['query']?['pages'] as Map<String, dynamic>?;
      if (pages == null) return null;

      for (var page in pages.values) {
        final thumb = page['thumbnail']?['source'];
        if (thumb != null && thumb.toString().isNotEmpty) {
          return thumb.toString();
        }
      }
    } catch (_) {}
    return null;
  }

  final List<Map<String, dynamic>> _globalCities = [
    {'lon': 2.3522,   'lat': 48.8566,  'city': 'Paris'},
    {'lon': 12.4964,  'lat': 41.9028,  'city': 'Rome'},
    {'lon': 139.6917, 'lat': 35.6895,  'city': 'Tokyo'},
    {'lon': -74.0060, 'lat': 40.7128,  'city': 'New York'},
    {'lon': -0.1278,  'lat': 51.5074,  'city': 'London'},
    {'lon': 31.2357,  'lat': 30.0444,  'city': 'Cairo'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "World Explore",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B2612)),
                  ),
                  IconButton(
                    onPressed: _loadWorldData,
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6D8B6D)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading && _places.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6D8B6D)))
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _places.length,
                      itemBuilder: (context, index) => _buildVibeCard(_places[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibeCard(Map<String, dynamic> place) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // تكييش الصور باستخدام CachedNetworkImage
            CachedNetworkImage(
              imageUrl: place['image'],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6D8B6D))),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.78)],
                ),
              ),
            ),
            Positioned(
              bottom: 12, left: 12, right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${place['city']} • ${place['category']}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
