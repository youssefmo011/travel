import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/gamified_profile_screen.dart';

class ShuffleResultScreen extends StatefulWidget {
  static const String routeName = '/shuffle-result';

  const ShuffleResultScreen({super.key});

  @override
  State<ShuffleResultScreen> createState() => _ShuffleResultScreenState();
}

class _ShuffleResultScreenState extends State<ShuffleResultScreen>
    with TickerProviderStateMixin {
  bool _showCelebration = true;
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut);

    _celebrationController.forward();
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showCelebration = false);
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  // ── icon name → IconData ──────────────────────────────────────────────────
  IconData _resolveIcon(String name) {
    const Map<String, IconData> map = {
      'psychology':            Icons.psychology,
      'emoji_events':          Icons.emoji_events,
      'local_fire_department': Icons.local_fire_department,
      'explore':               Icons.explore,
      'self_improvement':      Icons.self_improvement,
      'directions_walk':       Icons.directions_walk,
      'restaurant':            Icons.restaurant,
      'nightlife':             Icons.nightlife,
      'forest':                Icons.forest,
      'museum':                Icons.museum,
      'camera_alt':            Icons.camera_alt,
      'hiking':                Icons.hiking,
      'wb_sunny':              Icons.wb_sunny,
      'people':                Icons.people,
      'bolt':                  Icons.bolt,
    };
    return map[name] ?? Icons.emoji_events;
  }

  @override
  Widget build(BuildContext context) {
    final challenge =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showCelebration
            ? _buildCelebrationOverlay(challenge)
            : _buildMainContent(context, challenge),
      ),
    );
  }

  Widget _buildCelebrationOverlay(Map<String, dynamic> challenge) {
    final String badgeName  = challenge['badge_name']  ?? 'Comfort Zone Breaker';
    final String badgeIconS = challenge['badge_icon']  ?? 'emoji_events';
    final IconData badgeIcon = _resolveIcon(badgeIconS);

    return Container(
      key: const ValueKey(1),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D3E2D), Color(0xFF769676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(badgeIcon, color: Colors.white, size: 80),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "NEW BADGE UNLOCKED!",
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Text(
            badgeName,
            style: const TextStyle(
                color: Color(0xFFE2E9D1),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          const Text(
            "+500 XP Added to your Profile",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Map<String, dynamic> challenge) {
    return SafeArea(
      key: const ValueKey(2),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildContentCard(context, challenge),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3E2D)),
          ),
          const Text("Quest Briefing",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildContentCard(
      BuildContext context, Map<String, dynamic> challenge) {
    final String badgeName  = challenge['badge_name']  ?? 'Comfort Zone Breaker';
    final String badgeIconS = challenge['badge_icon']  ?? 'emoji_events';
    final IconData badgeIcon = _resolveIcon(badgeIconS);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vibe tag + verified
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                challenge['vibe']?.toUpperCase() ?? "NEW VIBE",
                style: const TextStyle(
                    color: Color(0xFF769676),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              const Icon(Icons.verified, color: Color(0xFF769676), size: 18),
            ],
          ),
          const SizedBox(height: 12),

          // Main challenge text
          Text(
            challenge['main_text'] ?? "Mystery Challenge",
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E2D)),
          ),
          const SizedBox(height: 24),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl:
                  "https://picsum.photos/seed/${challenge['image_keyword'] ?? 'travel'}/600/400",
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                  height: 200, color: const Color(0xFFF2F4F2)),
              errorWidget: (context, url, _) => Container(
                  height: 200, color: const Color(0xFFF2F4F2),
                  child: const Icon(Icons.image_not_supported, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 24),

          // Coach note
          const Text("AI COACH NOTE",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            challenge['sub_text'] ?? "",
            style: const TextStyle(
                fontSize: 13, height: 1.5, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 24),

          // Badge earned row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFEAB308), Color(0xFFF97316)]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(badgeIcon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("BADGE EARNED",
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEAB308),
                              letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text(badgeName,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3E2D))),
                    ],
                  ),
                ),
                const Text("+500 XP",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEAB308))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CTA
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, GamifiedProfileScreen.routeName,
                  (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3E2D),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("SEE MY NEW BADGE & PROGRESS",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
