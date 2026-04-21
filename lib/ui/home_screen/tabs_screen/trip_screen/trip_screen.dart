import 'package:flutter/material.dart';
import 'treasure_walk_screen.dart';
import '../explore_screen/explore_screen.dart'; // تأكد من أن مسار ملف الـ Explore صحيح لديك

class TripScreen extends StatelessWidget {
  static const String routeName = '/trip';
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية لرحلة نشطة لربط الصفحات ببعضها
    final VibeLocation activeTrip = VibeLocation(
      title: "Alpine Escape",
      location: "ZERMATT, SWITZERLAND",
      imageUrl: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=1000",
      description: "Your scheduled retreat to the Swiss Alps.",
      distance: "15km away",
      rating: 5.0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        title: const Text("My Journeys",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B2612))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // إضافة أيقونة بسيطة في الـ AppBar لتعطي شكلاً احترافياً
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF6B8E6B)),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم الرحلة النشطة
            const Text("ACTIVE EXPEDITION",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 15),
            _buildActiveTripCard(context, activeTrip),

            const SizedBox(height: 35),

            // قسم الرحلات القادمة
            const Text("UPCOMING VIBES",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 15),

            // تم تصحيح الأيقونة هنا لتصبح self_improvement
            _buildUpcomingItem("Tokyo Street Hunt", "24 May 2026", Icons.map_outlined),
            _buildUpcomingItem("Kyoto Zen Walk", "12 June 2026", Icons.self_improvement),
            _buildUpcomingItem("Desert Safari", "05 July 2026", Icons.wb_sunny_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripCard(BuildContext context, VibeLocation vibe) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: Image.network(vibe.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B8E6B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("ONGOING",
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vibe.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 14),
                    const SizedBox(width: 5),
                    Text(vibe.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TreasureWalkScreen(vibe: vibe)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E6B),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("RESUME JOURNEY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingItem(String title, String date, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6B8E6B), size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}