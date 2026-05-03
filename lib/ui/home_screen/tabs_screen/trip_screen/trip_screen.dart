import 'package:flutter/material.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/explore_screen/place_details_screen.dart';

// 1. الشاشة الرئيسية للرحلات
class TripScreen extends StatelessWidget {
  static const String routeName = '/trip';
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFDFCF9),
      body: _TripScreenBody(),
    );
  }
}

// 2. كلاس بيانات الرحلة
class TripItem {
  final String date;
  final String title;
  final String description;
  final String vibe;
  final IconData vibeIcon;
  final String imageUrl;
  final bool isCompleted;

  TripItem({
    required this.date,
    required this.title,
    required this.description,
    required this.vibe,
    required this.vibeIcon,
    required this.imageUrl,
    this.isCompleted = true,
  });
}

// 3. جسم الشاشة الذي يحتوي على الحالة
class _TripScreenBody extends StatefulWidget {
  const _TripScreenBody();

  @override
  State<_TripScreenBody> createState() => _TripScreenBodyState();
}

class _TripScreenBodyState extends State<_TripScreenBody> {
  bool isPastSelected = true;

  final List<TripItem> pastTrips = [
    TripItem(
      date: "OCT 12",
      title: "Autumn in Kyoto",
      description: "Ancient temples and vivid colors.",
      vibe: "Inspired",
      vibeIcon: Icons.camera_alt_outlined,
      imageUrl: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=1000",
    ),
    TripItem(
      date: "AUG 05",
      title: "Bali Retreat",
      description: "Morning yoga and vibrant markets.",
      vibe: "Radiant",
      vibeIcon: Icons.wb_sunny_outlined,
      imageUrl: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=1000",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildToggle(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    isPastSelected ? "Memory Lane" : "Upcoming",
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2612),
                        letterSpacing: -0.5),
                  ),
                  Text(
                    isPastSelected
                        ? "Relive your favorite moments and stories."
                        : "Your upcoming adventures will appear here.",
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 35),
                  if (isPastSelected)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pastTrips.length,
                      itemBuilder: (context, index) {
                        return _buildTimelineItem(pastTrips[index], index == pastTrips.length - 1);
                      },
                    )
                  else
                    const SizedBox(height: 400, child: Center(child: Text("No upcoming trips yet"))),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.map, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text("Travel Me", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_outlined, color: Colors.black54)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          _toggleItem("Past Journeys", isPastSelected, () => setState(() => isPastSelected = true)),
          _toggleItem("Upcoming", !isPastSelected, () => setState(() => isPastSelected = false)),
        ],
      ),
    );
  }

  Widget _toggleItem(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))] : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.black : Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TripItem item, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Color(0xFF6B8E6B), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: CustomPaint(
                    size: const Size(2, double.infinity),
                    painter: DashedLinePainter(),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  PlaceDetailsScreen.routeName,
                  arguments: {
                    'name': item.title,
                    'city': 'Kyoto, Japan',
                    'image': item.imageUrl,
                    'category': item.vibe,
                  },
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(item.imageUrl, width: 75, height: 75, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(item.date, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFFE8F0E8), borderRadius: BorderRadius.circular(10)),
                                child: const Text("COMPLETED", style: TextStyle(fontSize: 8, color: Color(0xFF6B8E6B), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1B2612))),
                          Text(item.description, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(item.vibeIcon, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 5),
                              Text(item.vibe, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                            ],
                          ),
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

// 4. الرسام الخاص بالخط المقطع
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 8;
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2;
    while (startY < size.height - 8) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}