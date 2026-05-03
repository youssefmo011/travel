import 'dart:ui';
import 'package:flutter/material.dart';
import 'map_plan_screen.dart';

class PlaceDetailsScreen extends StatelessWidget {
  static const String routeName = '/place-details';

  const PlaceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استقبال البيانات المرسلة من الصفحة السابقة
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    final Map<String, dynamic> place = args is Map<String, dynamic> ? args : {
      'name': "The Emerald Valley Sanctuary",
      'city': "Kyoto, Japan",
      'image': "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?q=80&w=1000",
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. الصورة العلوية الكبيرة
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.network(
              place['image'],
              fit: BoxFit.cover,
            ),
          ),

          // 2. أزرار الرجوع والمفضلة (بتأثير زجاجي)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBlurButton(
                    onTap: () => Navigator.pop(context),
                    icon: Icons.arrow_back_ios_new,
                    isSmall: true,
                  ),
                  _buildBlurButton(
                    onTap: () {},
                    icon: Icons.favorite_border,
                    isSmall: false,
                  ),
                ],
              ),
            ),
          ),

          // 3. كارت التفاصيل (Sheet)
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 120),
                  children: [
                    // العنوان والتقييم
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            place['name'],
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2612),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Text("4.9", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(width: 4),
                              Icon(Icons.star_border, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // الموقع
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          "${place['city']} • 12km away",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // الكلمات الدلالية (Tags)
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        _buildTag("Quiet"),
                        _buildTag("Nature-focused"),
                        _buildTag("Hidden Gem"),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // الوصف
                    const Text(
                      "A serene retreat nestled deep within the bamboo groves of Arashiyama. Designed for those seeking a moment of absolute stillness, the sanctuary's minimalist architecture harmonizes with the rhythmic sway of the trees. It perfectly matches your preference for tranquil, low-density locations.",
                      style: TextStyle(color: Colors.black87, fontSize: 15, height: 1.7),
                    ),
                    const SizedBox(height: 30),
                    // معلومات سريعة
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        const Text("Best at 7 AM", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 30),
                        Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        const Text("42 Reviews", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 45),
                    const Text("What people are saying", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 25),
                    // المراجعات
                    _buildReviewCard("ELENA S.", "I've never felt more at peace. The way the light hits the moss gardens at sunrise is just transformative."),
                    const SizedBox(height: 25),
                    _buildReviewCard("MARCUS T.", "Actually a hidden gem. Zero tourists when I went on a Tuesday morning. Perfect for reflection."),
                  ],
                ),
              );
            },
          ),

          // 4. الزر السفلي (plan it) لفتح الخريطة
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.9), Colors.white],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, MapPlanScreen.routeName);
                },
                icon: const Icon(Icons.near_me_outlined, color: Colors.white, size: 22),
                label: const Text("plan it", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D8B6D),
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                  shadowColor: const Color(0xFF6D8B6D).withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurButton({required VoidCallback onTap, required IconData icon, required bool isSmall}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, size: isSmall ? 18 : 22, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF6D8B6D).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(15)),
      child: Text(label, style: const TextStyle(color: Color(0xFF6D8B6D), fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReviewCard(String name, String comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 22, backgroundColor: Colors.grey),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(22)),
                child: Text("\"$comment\"", style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.6, fontStyle: FontStyle.italic)),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 60, top: 10),
          child: Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey)),
        ),
      ],
    );
  }
}
