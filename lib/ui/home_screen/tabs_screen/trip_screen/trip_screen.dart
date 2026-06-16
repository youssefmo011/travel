import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'treasure_walk_screen.dart';
import 'trip_details_page.dart';

class TripDetails {
  final String title;
  final String description;
  final String date;
  final String time;
  final String imagePath;
  final String mood;
  final String location;

  TripDetails({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.imagePath,
    required this.mood,
    required this.location,
  });
}

class TripScreen extends StatefulWidget {
  static const String routeName = 'trip-screen';
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  List<TripDetails> savedTrips = [];
  bool isPastSelected = false;

  void _addNewTrip(Map<String, dynamic> data) {
    setState(() {
      savedTrips.insert(
        0,
        TripDetails(
          title: data['title'] ?? "New Trip",
          description: data['desc'] ?? "",
          date: data['date'] ?? "",
          time: data['time'] ?? "",
          imagePath: data['image'] ?? "assets/images/walk_of_cairo.jpg",
          mood: data['mood'] ?? "Inspired",
          location: data['location'] ?? "Unknown Location",
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.grid_view_rounded, color: Colors.black),
        title: const Text(
          "Bakkar Travel",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      // استخدمنا CustomScrollView مع AlwaysScrollableScrollPhysics لضمان سلاسة التمرير
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildTabs(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          if (isPastSelected)
            _buildSliverPastContent()
          else
            _buildUpcomingAdContent(),

          // إضافة مساحة في أسفل الصفحة لضمان ظهور آخر العناصر عند السحب
          const SliverToBoxAdapter(
            child: SizedBox(height: 50),
          ),

          if (isPastSelected)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              sliver: SliverToBoxAdapter(
                child: _buildTreasureButton(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAdContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildAdHeader(),
        const SizedBox(height: 25),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("📸 Our Official Price Lists",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),

        // قسم عرض صور الأسعار (NEW.jpg & NEW2.jpg)
        _buildPricePosters(),

        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("🔥 Limited Time Offer!"),
              const Text(
                "Book a Quadruple Room at LA PERLA, 4th person pays ONLY 700 EGP!",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("🎒 What's Included?"),
              _buildInclusions(),
              const SizedBox(height: 20),
              _buildSectionTitle("🏨 Explore our Hotels"),
              _buildHotelLinks(),
            ],
          ),
        ),

        // أزرار التواصل في أسفل الإعلان
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  "WhatsApp",
                  const Color(0xFF25D366),
                  Icons.chat,
                  "https://wa.me/201035888658",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildContactButton(
                  "Instagram",
                  const Color(0xFFE1306C),
                  Icons.camera_alt,
                  "https://instagram.com/bakar_travel",
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildPricePosters() {
    final List<String> posters = [
      'assets/images/Dahab.jpg',
      'assets/images/Dahab1.jpg',
    ];

    return SizedBox(
      height: 480, // زيادة الارتفاع لضمان وضوح الجدول داخل الصور
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: posters.length,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                posters[index],
                fit: BoxFit.fill, // تم تغييرها لـ fill لملء المساحة بالكامل وجعل الكلام واضحاً
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text("Image not found:\n${posters[index]}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFF769372), Color(0xFF94B49F)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(Icons.beach_access, size: 120, color: Colors.white.withValues(alpha: 0.2)),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("🌊 DAHAB\nIS CALLING!",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Find your next adventure with us 🌴",
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInclusions() {
    final items = [
      {"icon": Icons.directions_bus_filled, "text": "Round-trip Transport"},
      {"icon": Icons.hotel, "text": "Accommodation (B.B)"},
      {"icon": Icons.sailing, "text": "FREE Lagoons Trip"},
    ];
    return Column(
      children: items.map((item) => ListTile(
        leading: Icon(item['icon'] as IconData, color: const Color(0xFF769372)),
        title: Text(item['text'] as String, style: const TextStyle(fontSize: 14)),
        dense: true,
      )).toList(),
    );
  }

  Widget _buildHotelLinks() {
    final hotels = ["LA PERLA", "DAHAB FLY", "HAPPY LAND", "DALIDAA", "SEA HORSE"];
    return Wrap(
      spacing: 8,
      children: hotels.map((h) => ActionChip(
        label: Text(h, style: const TextStyle(fontSize: 11)),
        onPressed: () => _launchURL("https://instagram.com/bakar_travel"),
      )).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildContactButton(String label, Color color, IconData icon, String url) {
    return ElevatedButton.icon(
      onPressed: () => _launchURL(url),
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _buildTabButton("Past Journeys", isPastSelected, () {
              setState(() => isPastSelected = true);
            }),
            _buildTabButton("Upcoming", !isPastSelected, () {
              setState(() => isPastSelected = false);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : [],
          ),
          child: Center(
            child: Text(title, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverPastContent() {
    if (savedTrips.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const Text("No memories saved yet.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTimelineItem(savedTrips[index], index == savedTrips.length - 1),
          childCount: savedTrips.length,
        ),
      ),
    );
  }

  Widget _buildTreasureButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: const Color(0xFF769372).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF769372),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        ),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, TreasureWalkScreen.routeName);
          if (result != null && result is Map<String, dynamic>) {
            _addNewTrip(result);
          }
        },
        child: const Text("TREASURE WALK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTimelineItem(TripDetails trip, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF769372), size: 24),
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey[200])),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TripDetailsPage(trip: trip))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 25),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF7F8F7), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(trip.imagePath, width: 70, height: 70, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(width: 70, height: 70, color: Colors.grey[300], child: const Icon(Icons.image))),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trip.date, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(trip.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1),
                          Text(trip.location, style: const TextStyle(color: Color(0xFF769372), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}