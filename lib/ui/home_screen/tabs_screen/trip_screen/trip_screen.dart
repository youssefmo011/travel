import 'package:flutter/material.dart';
import 'treasure_walk_screen.dart'; // تأكد من صحة المسار
import 'trip_details_page.dart';    // تأكد من صحة المسار

// 1. تعريف موديل البيانات (Model) لتمثيل الرحلة
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
  // قائمة الرحلات المحفوظة (تبدأ فارغة)
  List<TripDetails> savedTrips = [];
  bool isPastSelected = true;

  // 2. دالة استقبال البيانات الجديدة وإضافتها للقائمة
  void _addNewTrip(Map<String, dynamic> data) {
    setState(() {
      savedTrips.insert(
        0, // إضافة الرحلة الجديدة في أعلى القائمة
        TripDetails(
          title: data['title'] ?? "New Trip",
          description: data['desc'] ?? "",
          date: data['date'] ?? "",
          time: data['time'] ?? "",
          imagePath: data['image'] ?? "assets/images/walk of cairo.jpg",
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
          "Travel Me",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        // AlwaysScrollableScrollPhysics تضمن أن الشاشة قابلة للسحب دائماً حتى لو كانت فارغة
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // الجزء العلوي: التبويبات (Tabs)
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildTabs(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // عرض المحتوى بناءً على اختيار (Past / Upcoming)
          if (isPastSelected)
            _buildSliverPastContent()
          else
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text("Coming Soon", style: TextStyle(color: Colors.grey))),
            ),

          // الزر مضاف كـ Sliver ليتحرك ويرتفع مع السكرول (حل مشكلة عدم الوصول للزر)
          if (isPastSelected)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
              sliver: SliverToBoxAdapter(
                child: _buildTreasureButton(),
              ),
            ),
        ],
      ),
    );
  }

  // بناء التبويبات (Past Journeys / Upcoming)
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

  // بناء محتوى الرحلات السابقة (Timeline)
  Widget _buildSliverPastContent() {
    if (savedTrips.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const Text(
            "No memories saved yet.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return _buildTimelineItem(
              savedTrips[index],
              index == savedTrips.length - 1,
            );
          },
          childCount: savedTrips.length,
        ),
      ),
    );
  }

  // بناء زر Treasure Walk (الذي يفتح دورة الرحلة)
  Widget _buildTreasureButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF769372).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF769372),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
          elevation: 0,
        ),
        onPressed: () async {
          // فتح صفحة التحدي وانتظار انتهاء الدورة كاملة (Walk -> Summary -> Save)
          final result = await Navigator.pushNamed(context, TreasureWalkScreen.routeName);

          // إذا تمت عملية الحفظ بنجاح، استلم البيانات وأضفها
          if (result != null && result is Map<String, dynamic>) {
            _addNewTrip(result);
          }
        },
        child: const Text(
          "TREASURE WALK",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // تصميم عنصر الرحلة في التايم لاين
  Widget _buildTimelineItem(TripDetails trip, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // الخط الجانبي والنقطة
          Column(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF769372), size: 24),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: Colors.grey[200]),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // كارد الرحلة
          Expanded(
            child: GestureDetector(
              onTap: () {
                // الانتقال لصفحة التفاصيل
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripDetailsPage(trip: trip),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 25),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // صورة المكان
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        trip.imagePath,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // نصوص الرحلة
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.date,
                            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            trip.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trip.location,
                            style: const TextStyle(color: Color(0xFF769372), fontSize: 12, fontWeight: FontWeight.bold),
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

  // بناء زر التبديل داخل التبويبات
  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}