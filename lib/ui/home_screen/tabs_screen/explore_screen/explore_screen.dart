import 'package:flutter/material.dart';
import '../trip_screen/treasure_walk_screen.dart'; // تأكد من استيراد صفحة الكنز

class VibeLocation {
  final String title;
  final String location;
  final String imageUrl;
  final double rating;
  final String description;
  final String distance;
  bool isFavorite;

  VibeLocation({
    required this.title,
    required this.location,
    required this.imageUrl,
    this.rating = 4.9,
    required this.description,
    this.distance = "12km away",
    this.isFavorite = false,
  });
}

class ExploreScreen extends StatefulWidget {
  static const String routeName = '/explore';
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<VibeLocation> locations = <VibeLocation>[
    VibeLocation(
      title: "Ancient",
      location: "KYOTO, JAPAN",
      imageUrl: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=1000",
      description: "A serene retreat nestled deep within the bamboo groves of Arashiyama.",
      rating: 4.8,
      distance: "8.5km away",
    ),
    VibeLocation(
      title: "Alpine",
      location: "ZERMATT, SWITZERLAND",
      imageUrl: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=1000",
      description: "Experience the majestic Alpine vibes with breathtaking views.",
      rating: 5.0,
      distance: "15km away",
    ),
    VibeLocation(
      title: "Neon",
      location: "SHIBUYA, TOKYO",
      imageUrl: "https://images.unsplash.com/photo-1542051841857-5f90071e7989?q=80&w=1000",
      description: "Immerse yourself in the electric energy of Tokyo's heart.",
      rating: 4.7,
      distance: "2.1km away",
    ),
    VibeLocation(
      title: "Desert",
      location: "WADI RUM, JORDAN",
      imageUrl: "https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=1000",
      description: "A vast, silent landscape of ancient riverbeds.",
      rating: 4.9,
      distance: "42km away",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Explore", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _buildSearchBar(),
              const SizedBox(height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Trending Vibes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("See all", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: locations.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (BuildContext context, int index) => _buildVibeCard(context, locations[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Find your next vibe...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildVibeCard(BuildContext context, VibeLocation vibe) {
    return InkWell(
      onTap: () {
        // التعديل هنا: نمرر الكائن بالكامل لصفحة TreasureWalkScreen
        // عشان تظهر البيانات الحقيقية بدل "Unknown Destination"
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TreasureWalkScreen(vibe: vibe),
          ),
        );
      },
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(image: NetworkImage(vibe.imageUrl), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 12, right: 12,
            child: GestureDetector(
              onTap: () => setState(() => vibe.isFavorite = !vibe.isFavorite),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  vibe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: vibe.isFavorite ? Colors.red : Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12, left: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(vibe.location, style: const TextStyle(color: Colors.white, fontSize: 8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(child: Text(vibe.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          Text(" ${vibe.rating}", style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}