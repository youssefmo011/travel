import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/assets/app_assets.dart';
import 'quiz_shuffle_screen.dart';

class QuizResultsScreen extends StatelessWidget {
  static const String routeName = 'quiz-results';

  const QuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    final String personality = args['personality'] ?? "Traveler";
    final Map<dynamic, dynamic> traits = args['traits'] ?? {};
    final String personalityBio = args['personality_bio'] ?? "Your travel DNA is uniquely crafted based on your preferences.";
    
    final int nature = (traits['Nature'] as num?)?.toInt() ?? 50;
    final int globalConfidence = args['confidence'] ?? 98;
    final String? aiRawData = args['ai_results'];

    // Process AI Response
    List<dynamic> recommendations = [];
    try {
      if (aiRawData != null && aiRawData.isNotEmpty && aiRawData != "[]") {
        recommendations = jsonDecode(aiRawData);
      } else {
        recommendations = _getFallbackRecs(personality);
      }
    } catch (e) {
      recommendations = _getFallbackRecs(personality);
    }

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.more_vert, color: Color(0xFF1B2612)),
        ),
        title: const Text('Quiz Results', style: TextStyle(color: Color(0xFF1B2612), fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.close, color: Color(0xFF1B2612)),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          String? profileImageUrl;
          if (snapshot.hasData && snapshot.data!.exists) {
            profileImageUrl = (snapshot.data!.data() as Map<String, dynamic>)['profileImage'];
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildUserHeader(profileImageUrl, personality, personalityBio),
                const SizedBox(height: 24),
                
                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    children: [
                      _buildStatItem('NATURE AFFINITY', _getNatureLabel(nature)),
                      Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2)),
                      _buildStatItem('MATCH CONFIDENCE', '$globalConfidence%'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader('Curated For You', recommendations.length),
                const SizedBox(height: 16),

                ...recommendations.map((place) => _buildResultCard(
                  place['name'] ?? "Hidden Gem",
                  place['description'] ?? "A place that matches your spirit.",
                  place['matchReason'] ?? "Matches your $personality vibe.",
                  place['matchPercentage'] ?? (85 + (place.hashCode % 10)),
                )),

                const SizedBox(height: 24),
                _buildShuffleButton(context, personality, traits),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(String? imageUrl, String personality, String bio) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF769676).withOpacity(0.3), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFF0F4F0),
            backgroundImage: (imageUrl != null && imageUrl.startsWith('http'))
                ? NetworkImage(imageUrl)
                : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 22, color: Color(0xFF1B2612)),
            children: [
              const TextSpan(text: 'You are a '),
              TextSpan(
                text: personality,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF769676)),
              ),
              const TextSpan(text: '!'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            bio,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFFC4CDC4), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF769676))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2612))),
          Text('$count MATCHES', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFC4CDC4))),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String desc, String reason, dynamic confidence) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: "https://picsum.photos/seed/${title.hashCode}/600/350",
                    height: 160, width: double.infinity, fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey.shade100),
                  ),
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                      child: Text('$confidence% Match', style: const TextStyle(color: Color(0xFF769676), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2612))),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 6),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.3)),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF769676)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(reason, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF769676)))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShuffleButton(BuildContext context, String personality, Map traits) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFFE2E9A3), Color(0xFFA6EBC9)]),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, QuizShuffleScreen.routeName, arguments: {"personality": personality, "traits": traits});
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF4A614A), size: 18),
              SizedBox(width: 8),
              Text('SHUFFLE', style: TextStyle(color: Color(0xFF4A614A), fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(width: 8),
              Text('TRY SOMETHING NEW', style: TextStyle(color: Color(0xFF769676), fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  String _getNatureLabel(int percent) {
    if (percent >= 80) return "Wilderness";
    if (percent >= 50) return "Balanced";
    return "Urban Soul";
  }

  List<Map<String, dynamic>> _getFallbackRecs(String personality) {
    return [
      {"name": "Kyoto, Japan", "description": "Ancient temples and serene bamboo groves.", "matchReason": "Perfect for your love of culture.", "matchPercentage": 89},
      {"name": "Bali, Indonesia", "description": "Tropical beaches and vibrant spirit.", "matchReason": "Matches your balanced travel vibe.", "matchPercentage": 92}
    ];
  }
}
