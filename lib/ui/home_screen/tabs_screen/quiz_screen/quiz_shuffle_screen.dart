import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/assets/app_assets.dart';
import '../explore_screen/shuffle_result_screen.dart';

class QuizShuffleScreen extends StatefulWidget {
  static const String routeName = 'quiz-shuffle';

  const QuizShuffleScreen({super.key});

  @override
  State<QuizShuffleScreen> createState() => _QuizShuffleScreenState();
}

class _QuizShuffleScreenState extends State<QuizShuffleScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSuccessOverlay = false;
  Map<String, dynamic>? _challenge;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _badgeController;

  int _loadingMsgIndex = 0;
  final List<String> _loadingMessages = [
    "Analyzing your boundaries...",
    "Searching for hidden Egyptian gems...",
    "AI is crafting a unique challenge in Egypt...",
    "Finding the perfect local vibe for you...",
    "Preparing your next Egyptian adventure..."
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _badgeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _startLoadingMessages();
  }

  void _startLoadingMessages() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isLoading) return false;
      setState(() {
        _loadingMsgIndex = (_loadingMsgIndex + 1) % _loadingMessages.length;
      });
      return true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && _challenge == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _generateAIChallenge(args);
    }
  }

  Future<void> _generateAIChallenge(Map<String, dynamic>? args) async {
    final String personality = args?['personality'] ?? "Explorer";
    final Map traits = args?['traits'] ?? {};

    final String dominantTrait = _getDominantTrait(traits, personality);
    final Map<String, List<String>> oppositeCategories = {
      'Nature':    ['Social Interaction', 'Urban Exploration', 'Street Food Hunt', 'Local Market Discovery'],
      'Adventure': ['Mindful Stillness', 'Cultural Immersion', 'Local Tradition', 'Art & Museums'],
      'Culture':   ['Active Adventure', 'Spontaneous Exploration', 'Red Sea Discovery', 'Modern City Life'],
      'Social':    ['Nature Solitude', 'Desert Reflection', 'Historical Silence', 'Quiet Oasis Visit'],
      'Luxury':    ['Budget Local Experience', 'Street Food Challenge', 'Authentic Souq Hunt', 'Local Transport Experience'],
    };

    final List<String> pool =
        oppositeCategories[dominantTrait] ?? ['Gastronomy', 'Social', 'Local Tradition', 'Mindfulness', 'Active Exploration'];

    final rng = Random();
    final String focusCategory = pool[rng.nextInt(pool.length)];
    final int seed = DateTime.now().millisecondsSinceEpoch + rng.nextInt(99999);

    final String traitSummary = traits.isNotEmpty
        ? traits.entries.map((e) => '${e.key}: ${e.value}%').join(', ')
        : 'General traveler';

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyCbvejXRoxKldEgpu5V3loc7e42Qt7Mm1k',
      );

      final prompt = """
You are a travel challenge AI specializing in Egypt Tourism. Generate a UNIQUE, ACTIONABLE travel challenge in Egypt for this specific traveler.

TRAVELER PROFILE:
- Personality: $personality
- Trait Scores: $traitSummary
- Dominant Trait: $dominantTrait
- Challenge Focus: $focusCategory (outside their comfort zone)
- Context: Egypt (Cairo, Nile, Red Sea, Oases)

RULES:
- The challenge MUST be set in Egypt and fit the "$focusCategory" category.
- It must DIRECTLY contradict the "$dominantTrait" trait to push them out of their comfort zone.
- Use specific Egyptian elements (e.g., "Ask a spice vendor in Khan el-Khalili...", "Try Kushari at a local spot...", "Watch a Felucca at sunset without taking photos").
- Return ONLY valid JSON:
{
  "vibe": "catchy Egyptian challenge name",
  "main_text": "Single punchy action sentence starting with a verb.",
  "sub_text": "How to do it and why it helps a $personality grow.",
  "stat_name": "Skill name (e.g. Cultural Empathy, Spontaneity)",
  "stat_boost": "+X%",
  "image_keyword": "egypt_specific_keyword",
  "badge_name": "Unique badge title",
  "badge_icon": "one of the standard icon names"
}
""";

      final response = await model.generateContent([Content.text(prompt)]);
      final String rawResponse = response.text ?? '{}';

      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      Map<String, dynamic> parsed = {};
      try {
        final String clean = rawResponse.replaceAll('```json', '').replaceAll('```', '').trim();
        parsed = jsonDecode(clean) as Map<String, dynamic>;
      } catch (_) {
        final match = RegExp(r'\{[\s\S]*\}').firstMatch(rawResponse);
        parsed = match != null ? jsonDecode(match.group(0)!) : _getFallbackChallenge(personality, dominantTrait);
      }

      setState(() {
        _challenge = parsed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _challenge = _getFallbackChallenge(personality, dominantTrait);
        _isLoading = false;
      });
    }
  }

  String _getDominantTrait(Map traits, String personality) {
    if (traits.isNotEmpty) {
      final sorted = traits.entries.toList()
        ..sort((a, b) => (b.value as num).compareTo(a.value as num));
      return sorted.first.key.toString();
    }
    return personality.contains('Thrill') ? 'Adventure' : 'Nature';
  }

  Future<void> _handleAccept() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String badgeName = _challenge?['badge_name'] ?? 'Egypt Explorer';
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'challengeXp': FieldValue.increment(500),
        'badges': FieldValue.arrayUnion([badgeName]),
      }, SetOptions(merge: true));

      setState(() => _isSuccessOverlay = true);
      _badgeController.forward();
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.pushReplacementNamed(context, ShuffleResultScreen.routeName, arguments: _challenge);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: Stack(
        children: [_isLoading ? _buildLoading() : _buildContent(), if (_isSuccessOverlay) _buildSuccessOverlay()],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(turns: _rotationController, child: const Icon(Icons.auto_awesome, size: 80, color: Color(0xFF769676))),
          const SizedBox(height: 30),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(_loadingMessages[_loadingMsgIndex], key: ValueKey<int>(_loadingMsgIndex), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D3E2D))),
          ),
          const SizedBox(height: 10),
          const Text("Consulting Travel AI Engine...", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, size: 20))),
          _buildChallengeCard(),
        ]),
      ),
    );
  }

  Widget _buildChallengeCard() {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.02).animate(_pulseController),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.shuffle, size: 14, color: Colors.grey),
            const SizedBox(width: 8),
            Text("AI DNA CHALLENGE", style: TextStyle(letterSpacing: 1.5, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
          ]),
          const SizedBox(height: 16),
          const Text("Experience Egypt\nDifferently!", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D))),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CachedNetworkImage(
              imageUrl: "https://picsum.photos/seed/${_challenge?['vibe']}_egypt/600/400",
              height: 220, width: double.infinity, fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator())),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF769676).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(_challenge?['vibe'] ?? "Vibe", style: const TextStyle(color: Color(0xFF769676), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(height: 16),
          Text(_challenge?['main_text'] ?? "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D))),
          const SizedBox(height: 12),
          Text(_challenge?['sub_text'] ?? "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4)),
          const SizedBox(height: 32),
          _buildStatBoost(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _handleAccept,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF769676), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bolt, color: Colors.white), SizedBox(width: 10), Text("Accept & Earn +500 XP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Maybe later", style: TextStyle(color: Colors.grey))),
        ]),
      ),
    );
  }

  Widget _buildStatBoost() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_challenge?['stat_name'] ?? "Skill", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3E2D))),
        Text(_challenge?['stat_boost'] ?? "0%", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF769676))),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: 0.7, minHeight: 8, backgroundColor: const Color(0xFFF1F4EE), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE2E9D1)))),
    ]);
  }

  Widget _buildSuccessOverlay() {
    final IconData badgeIcon = _resolveIcon(_challenge?['badge_icon'] ?? 'psychology');
    return Container(
      color: Colors.black.withOpacity(0.9), width: double.infinity, height: double.infinity,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ScaleTransition(
          scale: CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
          child: Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFEAB308), Color(0xFFF97316)]), boxShadow: [BoxShadow(color: const Color(0xFFEAB308).withOpacity(0.5), blurRadius: 40, spreadRadius: 10)]), child: Icon(badgeIcon, color: Colors.white, size: 80)),
        ),
        const SizedBox(height: 40),
        const Text("DNA UPGRADED!", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3)),
        const SizedBox(height: 10),
        Text(_challenge?['badge_name'] ?? 'Challenge Master', style: const TextStyle(color: Color(0xFFEAB308), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("+500 XP Added to Profile", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 50),
        const CircularProgressIndicator(color: Colors.white),
      ]),
    );
  }

  IconData _resolveIcon(String name) {
    const Map<String, IconData> map = {'psychology': Icons.psychology, 'emoji_events': Icons.emoji_events, 'local_fire_department': Icons.local_fire_department, 'explore': Icons.explore, 'self_improvement': Icons.self_improvement, 'directions_walk': Icons.directions_walk, 'restaurant': Icons.restaurant, 'nightlife': Icons.nightlife, 'forest': Icons.forest, 'museum': Icons.museum, 'camera_alt': Icons.camera_alt, 'hiking': Icons.hiking, 'wb_sunny': Icons.wb_sunny, 'people': Icons.people, 'bolt': Icons.bolt};
    return map[name] ?? Icons.emoji_events;
  }

  Map<String, dynamic> _getFallbackChallenge([String personality = 'Explorer', String dominantTrait = 'Nature']) {
    final Map<String, Map<String, dynamic>> fallbacks = {
      'Nature': {'vibe': 'Cairo Souq Explorer', 'main_text': 'Visit a local market in Cairo and find an item that tells a story.', 'sub_text': 'Leaving the quiet oases for the vibrant souqs builds your cultural adaptability.', 'stat_name': 'Spontaneity', 'stat_boost': '+18%', 'image_keyword': 'khan_el_khalili', 'badge_name': 'Souq Pioneer', 'badge_icon': 'explore'},
      'Adventure': {'vibe': 'Nile Reflection', 'main_text': 'Take a 30-minute Felucca ride in absolute silence.', 'sub_text': 'Thrill seekers often miss the subtle beauty. This builds the mindfulness needed for better exploring.', 'stat_name': 'Mindfulness', 'stat_boost': '+15%', 'image_keyword': 'nile_sunset', 'badge_name': 'River Observer', 'badge_icon': 'self_improvement'},
      'Social': {'vibe': 'Desert Solitude', 'main_text': 'Walk into the desert dunes alone for 20 minutes to meditate.', 'sub_text': 'Connecting with yourself in the vast silence of Egypt’s deserts builds inner strength.', 'stat_name': 'Self-Awareness', 'stat_boost': '+20%', 'image_keyword': 'desert_dunes', 'badge_name': 'Desert Mystic', 'badge_icon': 'directions_walk'},
      'Culture': {'vibe': 'Red Sea Thrill', 'main_text': 'Try a new water sport in Dahab or Hurghada today.', 'sub_text': 'Stepping from history into physical action helps you appreciate the energy of modern Egypt.', 'stat_name': 'Courage', 'stat_boost': '+22%', 'image_keyword': 'dahab_diving', 'badge_name': 'Coral Hero', 'badge_icon': 'local_fire_department'},
      'Luxury': {'vibe': 'Local Flavor Hunt', 'main_text': 'Find the best local Kushari spot and eat where the locals eat.', 'sub_text': 'True luxury is in authentic experience. Stepping out of resorts connects you to the real heart of Egypt.', 'stat_name': 'Cultural Empathy', 'stat_boost': '+17%', 'image_keyword': 'kushari_street', 'badge_name': 'Street Flavor Master', 'badge_icon': 'restaurant'},
    };
    return fallbacks[dominantTrait] ?? fallbacks['Nature']!;
  }
}
