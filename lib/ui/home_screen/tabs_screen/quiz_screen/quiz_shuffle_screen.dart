import 'package:flutter/material.dart';
import '../../../../core/assets/app_assets.dart';
import '../explore_screen/shuffle_result_screen.dart';

class QuizShuffleScreen extends StatelessWidget {
  static const String routeName = 'quiz-shuffle';

  const QuizShuffleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استلام الشخصية لتقديم تحدي عكس ميولها
    final String personality = ModalRoute.of(context)?.settings.arguments as String? ?? "Dreamer";
    final challenge = _getChallengeData(personality);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9), // لون الخلفية الكريمي
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3E2D), size: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF2D3E2D)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              children: [
                _buildChallengeCard(context, challenge),
                const SizedBox(height: 32),
                const Text(
                  "New challenges refresh every 24 hours\nbased on your seeker profile.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, Map<String, dynamic> challenge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // SHUFFLE RESULT Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shuffle, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(
                "SHUFFLE RESULT".toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Title
          const Text(
            "Step Outside Your\nComfort Zone!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3E2D),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 28),
          
          // Image with Vibe Label
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  challenge['image'], 
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Vibe: ${challenge['vibe']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Descriptions
          Text(
            challenge['main_text'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3E2D),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            challenge['sub_text'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Stat boost - Social Energy
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up, size: 18, color: Color(0xFF2D3E2D)),
                      const SizedBox(width: 8),
                      Text(
                        challenge['stat_name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3E2D),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    challenge['stat_boost'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3E2D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.7,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFF2F4F2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE2E9D1)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Accept Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, ShuffleResultScreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BA68B), 
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Accept Challenge",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Reject button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)),
                SizedBox(width: 4),
                Text(
                  "Not today",
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getChallengeData(String personality) {
    // تخصيص التحدي بناءً على الشخصية لكسر منطقة الراحة
    if (personality == "The dreamer" || personality == "Cultural seeker") {
      return {
        "vibe": "Midnight Jazz",
        "main_text": "Try a Jazz Club tonight instead of your usual quiet cafe.",
        "sub_text": "Discover a soulful atmosphere that challenges your typical evening routine.",
        "stat_name": "Social Energy",
        "stat_boost": "+20%",
        "image": AppAssets.storyPhoto,
      };
    } else {
      return {
        "vibe": "Zen Morning",
        "main_text": "Try a Silent Meditation instead of your usual loud party.",
        "sub_text": "Find inner peace and balance by stepping away from the crowd.",
        "stat_name": "Mindfulness",
        "stat_boost": "+15%",
        "image": AppAssets.photoTravel,
      };
    }
  }
}
