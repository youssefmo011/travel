import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import 'quiz_shuffle_screen.dart';

class QuizResultsScreen extends StatelessWidget {
  static const String routeName = 'quiz-results';

  const QuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    final String personality = args['personality'] ?? "Traveler";
    final Map<dynamic, dynamic> traits = args['traits'] ?? {};
    final String personalityBio = args['personality_bio'] ??
        "Your travel DNA is uniquely crafted based on your preferences.";

    final int nature = (traits['Nature'] as num?)?.toInt() ?? 50;
    final int adventure = (traits['Adventure'] as num?)?.toInt() ?? 50;
    final int culture = (traits['Culture'] as num?)?.toInt() ?? 50;
    final int social = (traits['Social'] as num?)?.toInt() ?? 50;
    final int globalConfidence = args['confidence'] ?? 98;
    final String? aiRawData = args['ai_results'];

    List<dynamic> suggestions = [];
    try {
      if (aiRawData != null && aiRawData.isNotEmpty && aiRawData != "[]") {
        suggestions = jsonDecode(aiRawData);
      } else {
        suggestions = _getFallbackSuggestions(personality);
      }
    } catch (e) {
      suggestions = _getFallbackSuggestions(personality);
    }

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String? profileImageUrl;
          if (snapshot.hasData && snapshot.data!.exists) {
            profileImageUrl =
                (snapshot.data!.data() as Map<String, dynamic>)['profileImage'];
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, personality, personalityBio,
                  profileImageUrl, globalConfidence),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildTraitsSection(
                        nature, adventure, culture, social, context),
                    const SizedBox(height: 32),
                    _buildSuggestionsHeader(suggestions.length, personality),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSuggestionCard(
                    context,
                    suggestions[index],
                    index,
                  ),
                  childCount: suggestions.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildShuffleButton(context, personality, traits),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Sliver App Bar with profile hero ───────────────────────────────────────

  Widget _buildSliverAppBar(
    BuildContext context,
    String personality,
    String bio,
    String? imageUrl,
    int confidence,
  ) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: AppColors.primaryDark),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.close, size: 18, color: AppColors.primaryDark),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF0F4EE), AppColors.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.4),
                            AppColors.primary.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.surface,
                        backgroundImage: (imageUrl != null &&
                                imageUrl.startsWith('http'))
                            ? NetworkImage(imageUrl)
                            : const AssetImage(AppAssets.profilePhoto)
                                as ImageProvider,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$confidence%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 22,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600),
                    children: [
                      const TextSpan(text: 'You are a '),
                      TextSpan(
                        text: personality,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary),
                      ),
                      const TextSpan(text: '!'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── DNA Traits bars ────────────────────────────────────────────────────────

  Widget _buildTraitsSection(
      int nature, int adventure, int culture, int social, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.fingerprint, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'YOUR TRAVEL DNA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTraitBar('Nature', nature, const Color(0xFF4CAF50)),
            const SizedBox(height: 12),
            _buildTraitBar('Adventure', adventure, const Color(0xFFFF7043)),
            const SizedBox(height: 12),
            _buildTraitBar('Culture', culture, const Color(0xFF7986CB)),
            const SizedBox(height: 12),
            _buildTraitBar('Social', social, const Color(0xFFFFB300)),
          ],
        ),
      ),
    );
  }

  Widget _buildTraitBar(String label, int value, Color color) {
    final double percent = (value.clamp(0, 100)) / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark)),
            ),
            const SizedBox(width: 8),
            Text('$value%',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 7,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ─── Suggestions header ──────────────────────────────────────────────────────

  Widget _buildSuggestionsHeader(int count, String personality) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURATED FOR YOU',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your $personality vibe',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count places',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Suggestion card ─────────────────────────────────────────────────────────

  Widget _buildSuggestionCard(
      BuildContext context, dynamic place, int index) {
    final String name = place['name'] ?? "Hidden Gem";
    final String description =
        place['description'] ?? "A place that matches your spirit.";
    final String matchReason = place['matchReason'] ?? "Matches your vibe.";
    final int matchPct = (place['matchPercentage'] as num?)?.toInt() ??
        (85 + (index * 3));
    final String category = place['category'] ?? "Travel";
    final String bestFor = place['bestFor'] ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: _buildPlaceImage(name, index),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 11, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('$matchPct% Match', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
              Positioned(
                bottom: 14, left: 16, right: 16,
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2))]),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bestFor.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.place, size: 13, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text('Best for: $bestFor', style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                Text(description, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.5)),
                const SizedBox(height: 14),
                const Divider(color: AppColors.surface, thickness: 1.5),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(matchReason, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontStyle: FontStyle.italic, height: 1.4, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DNA Match', style: TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w600)),
                    Text('$matchPct%', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: matchPct / 100.0, minHeight: 5, backgroundColor: AppColors.surface, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shuffle button ──────────────────────────────────────────────────────────

  Widget _buildShuffleButton(
      BuildContext context, String personality, Map traits) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFFD4E8A0), Color(0xFFA8E6C4)]),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, QuizShuffleScreen.routeName, arguments: {"personality": personality, "traits": traits});
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shuffle_rounded, color: AppColors.primaryDark, size: 20),
              const SizedBox(width: 10),
              const Text('SHUFFLE', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
              const SizedBox(width: 8),
              Expanded(child: Text('– Try Something Unexpected', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Image Helper ────────────────────────────────────────────────────────────

  Widget _buildPlaceImage(String name, int index) {
    final lower = name.toLowerCase();
    
    // الأولوية للصور المحلية من الـ Assets
    if (lower.contains('dahab')) {
      return Image.asset(AppAssets.dahabBlueHole, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('siwa')) {
      return Image.asset(AppAssets.siwa, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('luxor')) {
      return Image.asset(AppAssets.luxor, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('aswan')) {
      return Image.asset(AppAssets.aswan, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('white desert')) {
      return Image.asset(AppAssets.whiteDesert, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('gouna')) {
      return Image.asset(AppAssets.gouna, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('alexandria') || lower.contains('alex')) {
      return Image.asset(AppAssets.alex, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('fayoum') || lower.contains('hitan')) {
      return Image.asset(AppAssets.fayoum, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('zamalek')) {
      return Image.asset(AppAssets.zamalek, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('maadi')) {
      return Image.asset(AppAssets.maadi, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('cairo')) {
      return Image.asset(AppAssets.walkOfCairo, height: 200, width: double.infinity, fit: BoxFit.cover);
    }
    if (lower.contains('cafe') || lower.contains('culture') || lower.contains('koffee')) {
      return Image.asset(AppAssets.koffeeCulture, height: 200, width: double.infinity, fit: BoxFit.cover);
    }

    // fallback stable network image
    final int seedId = (name.length + index + 100).abs();
    return CachedNetworkImage(
      imageUrl: "https://picsum.photos/seed/$seedId/700/400",
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 200, color: AppColors.surface,
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Image.asset(AppAssets.photoTravel, height: 200, width: double.infinity, fit: BoxFit.cover),
    );
  }

  List<Map<String, dynamic>> _getFallbackSuggestions(String personality) {
    if (personality == "Thrill Chaser") {
      return [
        {"name": "Dahab, Egypt", "category": "Adventure", "description": "The 'Blue Hole' awaits. Dahab is the ultimate hub for deep-sea diving and mountain trekking.", "matchReason": "Your adventurous spirit matches Dahab's world-class diving spots.", "matchPercentage": 96, "bestFor": "Diving & Canyons"},
        {"name": "Wadi El Hitan", "category": "Adventure", "description": "Explore prehistoric whale fossils in this UNESCO World Heritage desert site.", "matchReason": "A perfect mix of off-road exploration and unique desert activities.", "matchPercentage": 89, "bestFor": "Desert Safaris"}
      ];
    } else if (personality == "Explorer" || personality.contains("Nature")) {
      return [
        {"name": "Siwa Oasis, Egypt", "category": "Nature", "description": "Bathe in Cleopatra's Spring and witness the surreal beauty of the Salt Lakes.", "matchReason": "You seek hidden gems. Siwa is Egypt's most mystical escape.", "matchPercentage": 94, "bestFor": "Eco-tourism"},
        {"name": "The White Desert", "category": "Nature", "description": "Alien-like chalk rock formations that look like a snowy landscape in the desert.", "matchReason": "Your love for unique landscapes makes this a must-see.", "matchPercentage": 91, "bestFor": "Camping"}
      ];
    } else if (personality == "Culture" || personality.contains("Culture")) {
      return [
        {"name": "Luxor, Egypt", "category": "Culture", "description": "The world's greatest open-air museum. From the Valley of the Kings to Karnak Temple.", "matchReason": "Your fascination with history will be fully satisfied in ancient Thebes.", "matchPercentage": 98, "bestFor": "Archaeology"},
        {"name": "Aswan, Egypt", "category": "Culture", "description": "Take a felucca around Elephantine Island and visit the stunning Philae Temple.", "matchReason": "The calm Nubian culture matches your appreciation for tradition.", "matchPercentage": 93, "bestFor": "Nile Cruises"}
      ];
    } else {
      return [
        {"name": "Zamalek, Cairo", "category": "Social", "description": "The heartbeat of Cairo's art scene. Trendy cafes and vibrant nightlife.", "matchReason": "Your social personality will thrive in the cosmopolitan atmosphere of Zamalek.", "matchPercentage": 90, "bestFor": "Art & Nightlife"},
        {"name": "Maadi, Cairo", "category": "Social", "description": "Leafy streets, international dining, and a relaxed community vibe in the heart of the city.", "matchReason": "Maadi's cosmopolitan and friendly environment is perfect for your social vibe.", "matchPercentage": 88, "bestFor": "Social Dining"},
        {"name": "Alexandria, Egypt", "category": "City", "description": "The Pearl of the Mediterranean. Walk the Corniche and enjoy the best seafood.", "matchReason": "A perfect blend of city energy and relaxed coastal life.", "matchPercentage": 87, "bestFor": "Seafood & Social Walks"}
      ];
    }
  }
}
