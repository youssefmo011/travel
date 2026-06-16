import 'package:flutter/material.dart';
import 'dart:math'; // مكتبة الاختيار العشوائي

class AdventureSummaryScreen extends StatelessWidget {
  static const String routeName = 'adventure-summary';
  const AdventureSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة البيانات للأماكن الثلاثة بتفاصيل مختلفة تماماً
    final List<Map<String, String>> locationsData = [
      {
        "title": "Walk of Cairo Adventure",
        "location": "Sheikh Zayed, Egypt",
        "desc": "A vibrant outdoor experience in the heart of Sheikh Zayed. You explored the modern walkways, captured the urban vibes, and enjoyed the lively atmosphere.",
        "image": "assets/images/walk of cairo.jpg",
        "mood": "Energized"
      },
      {
        "title": "Coffee Culture Discovery",
        "location": "New Cairo, Egypt",
        "desc": "The rich aroma of roasted beans led you to this hidden gem. You learned about different brewing techniques and took a moment to relax in an inspiring environment.",
        "image": "assets/images/koffee culture.jpg",
        "mood": "Inspired"
      },
      {
        "title": "The Lu Caffe Experience",
        "location": "Maadi, Egypt",
        "desc": "The final destination of your journey! Lu Caffe offered a cozy retreat where you celebrated the completion of your treasure walk with authentic Italian flavors.",
        "image": "assets/images/lu caffe.jpg",
        "mood": "Achiever"
      }
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/images/map plan 1.jpg", fit: BoxFit.cover)),
          SafeArea(
            child: Stack(
              children: [
                _buildMapPlace(top: 150, left: 40, title: "Walk of Cairo", img: "assets/images/walk of cairo.jpg"),
                _buildMapPlace(top: 350, right: 40, title: "Coffee Culture", img: "assets/images/koffee culture.jpg"),
                _buildMapPlace(top: 550, left: 60, title: "Lu Caffe", img: "assets/images/lu caffe.jpg", isCurrent: true),

                Positioned(
                  top: 20, left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF769372)),
                        onPressed: () => Navigator.pop(context)
                    ),
                  ),
                ),

                Positioned(
                  bottom: 40, left: 60, right: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF769372),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        elevation: 10
                    ),
                    onPressed: () {
                      // 1. جلب الوقت والتاريخ الحقيقي
                      DateTime now = DateTime.now();
                      final months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
                      String formattedDate = "${months[now.month - 1]} ${now.day}";
                      String formattedTime = "${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

                      // 2. اختيار مكان عشوائي من القائمة في كل مرة تضغط Save
                      final random = Random();
                      final selected = locationsData[random.nextInt(locationsData.length)];

                      // 3. إرجاع البيانات المختارة عشوائياً
                      Navigator.pop(context, {
                        "title": selected["title"],
                        "desc": selected["desc"],
                        "location": selected["location"],
                        "image": selected["image"],
                        "date": formattedDate,
                        "time": formattedTime,
                        "mood": selected["mood"],
                      });
                    },
                    child: const Text("SAVE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlace({required double top, double? left, double? right, required String title, required String img, bool isCurrent = false}) {
    return Positioned(
      top: top, left: left, right: right,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.white,
                border: isCurrent ? Border.all(color: const Color(0xFF769372), width: 3) : null
            ),
            child: CircleAvatar(radius: 35, backgroundImage: AssetImage(img)),
          ),
          const SizedBox(height: 5),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
              child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}
