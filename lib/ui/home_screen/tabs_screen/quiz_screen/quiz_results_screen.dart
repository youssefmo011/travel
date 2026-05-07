import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class QuizResultsScreen extends StatelessWidget {
  static const String routeName = 'quiz-results';

  const QuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استلام الشخصية من الشاشة السابقة
    final String personality = ModalRoute.of(context)?.settings.arguments as String? ?? "Dreamer";
    final data = _getPersonalityData(personality);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3E2D), size: 20),
        ),
        title: const Text(
          'Your Results',
          style: TextStyle(
            color: Color(0xFF2D3E2D),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF2D3E2D)),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String? profileImageUrl;
          
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            profileImageUrl = userData['profileImage'];
          }
          
          // إذا لم توجد صورة في Firestore نستخدم صورة الحساب
          profileImageUrl ??= user?.photoURL;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // صورة اليوزر الحقيقية
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF769676).withOpacity(0.2), width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: const Color(0xFFE8F0E8),
                      backgroundImage: (profileImageUrl != null && profileImageUrl.startsWith('http'))
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'You are a ${data['title']}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3E2D),
                  ),
                ),
                const SizedBox(height: 10),
                // الشعار المطلوب
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    '“${data['quote']}”',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      _buildStatItem('NATURE AFFINITY', data['affinity'] ?? 'Very High'),
                      const SizedBox(width: 12),
                      _buildStatItem('MATCH CONFIDENCE', '${data['confidence'] ?? 88}%'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Curated For You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3E2D),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF769676).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '3 NEW MATCHES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF769676),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ... (data['recommendations'] as List).map((rec) => _buildResultCard(
                  rec['name'],
                  rec['desc'],
                  rec['match'],
                  rec['image'],
                )),
                const SizedBox(height: 20),
                // زر SHUFFLE الملون
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE2E9D1), Color(0xFF90C0A0)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFF2D3E2D), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'SHUFFLE',
                            style: TextStyle(
                              color: Color(0xFF2D3E2D),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TRY SOMETHING NEW',
                            style: TextStyle(
                              color: const Color(0xFF2D3E2D).withOpacity(0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _getPersonalityData(String type) {
    switch (type) {
      case "Explorer":
        return {
          "title": "Explorer",
          "quote": "the world is too big to stay the same",
          "affinity": "Extreme",
          "confidence": 96,
          "recommendations": [
            {"name": "Dahab Blue Hole", "desc": "Wild coast and deep dives.", "match": "98%", "image": AppAssets.photoTravel},
            {"name": "Siwa Oasis", "desc": "Ancient hidden desert gems.", "match": "94%", "image": AppAssets.storyPhoto},
          ]
        };
      case "Social Butterfly":
        return {
          "title": "Social Butterfly",
          "quote": "every place feels better when it’s shared",
          "affinity": "Medium",
          "confidence": 95,
          "recommendations": [
            {"name": "El Gouna Marina", "desc": "Vibrant nights and events.", "match": "95%", "image": AppAssets.onboarding},
            {"name": "Zamalek Rooftops", "desc": "Meet urban travelers.", "match": "91%", "image": AppAssets.profilePhoto},
          ]
        };
      case "Cultural Seeker":
        return {
          "title": "Cultural Seeker",
          "quote": "i want to feel the soul of a place",
          "affinity": "High",
          "confidence": 94,
          "recommendations": [
            {"name": "Luxor Temple", "desc": "A journey through ancient time.", "match": "97%", "image": AppAssets.photoTravel},
            {"name": "Old Cairo", "desc": "Heart of hidden traditions.", "match": "94%", "image": AppAssets.storyPhoto},
          ]
        };
      case "Thrill Chaser":
        return {
          "title": "Thrill Chaser",
          "quote": "if it doesn't scare me a little , i want it more",
          "affinity": "Ultra",
          "confidence": 99,
          "recommendations": [
            {"name": "Marsa Alam Diving", "desc": "Underwater adrenaline rush.", "match": "99%", "image": AppAssets.onboarding},
            {"name": "Safari Quad Biking", "desc": "Speed through wild dunes.", "match": "96%", "image": AppAssets.photoTravel},
          ]
        };
      default: // Dreamer / The dreamer
        return {
          "title": "The dreamer",
          "quote": "i travel for the moments that feel like a movie",
          "affinity": "Very High",
          "confidence": 88,
          "recommendations": [
            {"name": "The Hidden Glade", "desc": "Peace in the ancient forest.", "match": "95%", "image": AppAssets.photoTravel},
            {"name": "Botanical Tea House", "desc": "Infusions in a glass garden.", "match": "91%", "image": AppAssets.storyPhoto},
            {"name": "Zen Rock Sanctuary", "desc": "Tranquility by flowing water.", "match": "85%", "image": AppAssets.onboarding},
          ]
        };
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280), fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String subtitle, String match, String image) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Image.asset(
                  image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF769676).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      match,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subtitle,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
