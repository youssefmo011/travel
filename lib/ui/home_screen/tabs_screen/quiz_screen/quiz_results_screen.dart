import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import 'quiz_shuffle_screen.dart';

class QuizResultsScreen extends StatelessWidget {
  static const String routeName = 'quiz-results';

  const QuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استلام البيانات الديناميكية من الكويز (النسب الحقيقية)
    final Map<String, dynamic> quizData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {
      "personality": "Social Butterfly",
      "confidence": 0,
      "nature": 0,
    };

    final String personality = quizData['personality'];
    final int confidence = quizData['confidence'];
    final int nature = quizData['nature'];

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
          profileImageUrl ??= user?.photoURL;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
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
                  'You are a $personality!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3E2D),
                  ),
                ),
                const SizedBox(height: 10),
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
                      // Nature Affinity ديناميكي (يعتمد على إجاباتك)
                      _buildStatItem('NATURE AFFINITY', _getNatureLabel(nature)),
                      const SizedBox(width: 12),
                      // Match Confidence ديناميكي (ممكن يوصل لـ 0% لو الإجابات سلبية)
                      _buildStatItem('MATCH CONFIDENCE', '$confidence%'),
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
                
                // الأماكن المطلوبة مع صورها المحدثة
                _buildResultCard(
                  'El Gouna Marina',
                  'Vibrant nights and events by the sea.',
                  '$confidence% Match',
                  AppAssets.photoTravel,
                ),
                _buildResultCard(
                  'Dahab Blue Hole',
                  'A paradise for divers and mountain lovers.',
                  '${confidence > 10 ? confidence - 4 : confidence}% Match',
                  AppAssets.dahabBlueHole,
                ),
                
                const SizedBox(height: 20),
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
                      onPressed: () {
                        Navigator.pushNamed(
                          context, 
                          QuizShuffleScreen.routeName,
                          arguments: personality,
                        );
                      },
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

  String _getNatureLabel(int percent) {
    if (percent <= 20) return "Very Low";
    if (percent <= 45) return "Low";
    if (percent <= 70) return "Medium";
    if (percent <= 90) return "High";
    return "Very High";
  }

  Map<String, dynamic> _getPersonalityData(String type) {
    switch (type) {
      case "Explorer":
        return {"title": "Explorer", "quote": "the world is too big to stay the same"};
      case "Social Butterfly":
        return {"title": "Social Butterfly", "quote": "every place feels better when it’s shared"};
      case "Cultural Seeker":
        return {"title": "Cultural Seeker", "quote": "i want to feel the soul of a place"};
      case "Thrill Chaser":
        return {"title": "Thrill Chaser", "quote": "if it doesn't scare me a little , i want it more"};
      default:
        return {"title": "The dreamer", "quote": "i travel for the moments that feel like a movie"};
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
