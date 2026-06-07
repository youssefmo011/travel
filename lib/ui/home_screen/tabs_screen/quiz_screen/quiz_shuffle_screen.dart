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
    "Searching for hidden local gems...",
    "AI is crafting a unique challenge...",
    "Finding the perfect vibe for you...",
    "Preparing your next adventure..."
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _badgeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    // Rotate loading messages
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

    // Pick a random focus category OPPOSITE to the user's dominant trait
    // so every challenge pushes them outside their comfort zone
    final String dominantTrait = _getDominantTrait(traits, personality);
    final Map<String, List<String>> oppositeCategories = {
      'Nature':    ['Social Interaction', 'Urban Exploration', 'Street Food Hunt', 'Nightlife Discovery'],
      'Adventure': ['Mindful Stillness', 'Cultural Immersion', 'Local Cuisine', 'Art & Museums'],
      'Culture':   ['Extreme Sport', 'Spontaneous Road Trip', 'Outdoor Survival', 'Extreme Cooking'],
      'Social':    ['Solo Silence Retreat', 'Nature Solitude', 'Mindfulness Walk', 'Forest Bathing'],
      'Luxury':    ['Budget Local Experience', 'Street Food Challenge', 'Camping Night', 'Local Market'],
    };

    final List<String> pool =
        oppositeCategories[dominantTrait] ?? ['Gastronomy', 'Social', 'Extreme Adventure', 'Mindfulness', 'Local Tradition'];

    final rng = Random();
    final String focusCategory = pool[rng.nextInt(pool.length)];

    // Unique seed every call → guaranteed different task
    final int seed = DateTime.now().millisecondsSinceEpoch + rng.nextInt(99999);

    // Build a compact trait summary for the prompt
    final String traitSummary = traits.isNotEmpty
        ? traits.entries.map((e) => '${e.key}: ${e.value}%').join(', ')
        : 'General traveler';

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyCbvejXRoxKldEgpu5V3loc7e42Qt7Mm1k',
      );

      final prompt = """
You are a travel challenge AI. Generate a UNIQUE, ACTIONABLE travel challenge for this specific traveler.

TRAVELER PROFILE:
- Personality: $personality
- Trait Scores: $traitSummary
- Dominant Trait: $dominantTrait
- Challenge Focus: $focusCategory (this is OUTSIDE their comfort zone)
- Unique Seed: $seed (ensures this challenge is different every time)

RULES:
- The challenge MUST be in the "$focusCategory" category.
- It must DIRECTLY contradict the "$dominantTrait" trait to push them out of their comfort zone.
- The main_text must be a single punchy action sentence starting with a verb (e.g., "Find a...", "Visit...", "Talk to...").
- The sub_text must explain WHY this challenge is good for a "$personality" specifically.
- stat_name must be a skill that "$personality" travelers lack (based on their traits).
- stat_boost must be between +8% and +25%.
- image_keyword must be a single specific noun perfect for a travel photo (e.g., "street_market", "meditation", "campfire").

Return ONLY valid JSON, no markdown, no code fences:
{
  "vibe": "short 2-3 word catchy challenge name",
  "main_text": "Single punchy action sentence.",
  "sub_text": "Sentence 1 explaining the challenge. Sentence 2 explaining the benefit for a $personality.",
  "stat_name": "Skill Name",
  "stat_boost": "+X%",
  "image_keyword": "specific_keyword",
  "badge_name": "Unique 2-3 word badge title earned by completing this challenge (e.g. 'Urban Pioneer', 'Silent Wanderer', 'Street Food Hero')",
  "badge_icon": "one of: psychology, emoji_events, local_fire_department, explore, self_improvement, directions_walk, restaurant, nightlife, forest, museum, camera_alt, hiking, wb_sunny, people, bolt"
}
""";

      final response = await model.generateContent([Content.text(prompt)]);
      final String rawResponse = response.text ?? '{}';

      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Robust JSON extraction — handles markdown code fences
      Map<String, dynamic> parsed = {};
      try {
        final String clean = rawResponse
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        parsed = jsonDecode(clean) as Map<String, dynamic>;
      } catch (_) {
        final match = RegExp(r'\{[\s\S]*\}').firstMatch(rawResponse);
        if (match != null) {
          try {
            parsed = jsonDecode(match.group(0)!) as Map<String, dynamic>;
          } catch (_) {
            parsed = _getFallbackChallenge(personality, dominantTrait);
          }
        } else {
          parsed = _getFallbackChallenge(personality, dominantTrait);
        }
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

  /// Returns the key with the highest % from traits map, else infers from personality name.
  String _getDominantTrait(Map traits, String personality) {
    if (traits.isNotEmpty) {
      final sorted = traits.entries.toList()
        ..sort((a, b) => (b.value as num).compareTo(a.value as num));
      return sorted.first.key.toString();
    }
    if (personality.contains('Thrill') || personality.contains('Adventure')) return 'Adventure';
    if (personality.contains('Luxury')) return 'Luxury';
    if (personality.contains('Social') || personality.contains('Butterfly')) return 'Social';
    if (personality.contains('Culture')) return 'Culture';
    return 'Nature';
  }

  Future<void> _handleAccept() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String badgeName = _challenge?['badge_name'] ?? 'Comfort Zone Breaker';

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'challengeXp': FieldValue.increment(500),
        'badges': FieldValue.arrayUnion([badgeName]),
      }, SetOptions(merge: true));

      setState(() => _isSuccessOverlay = true);
      _badgeController.forward();

      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          ShuffleResultScreen.routeName,
          arguments: _challenge,
        );
      }
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
        children: [
          _isLoading ? _buildLoading() : _buildContent(),
          if (_isSuccessOverlay) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _rotationController,
            child: const Icon(Icons.auto_awesome, size: 80, color: Color(0xFF769676)),
          ),
          const SizedBox(height: 30),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _loadingMessages[_loadingMsgIndex],
              key: ValueKey<int>(_loadingMsgIndex),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2D3E2D)),
            ),
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
            ),
            _buildChallengeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard() {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.02).animate(_pulseController),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shuffle, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text("AI DNA CHALLENGE", style: TextStyle(letterSpacing: 1.5, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Step Outside Your\nComfort Zone!", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D))),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: "https://picsum.photos/seed/${_challenge?['vibe']}_${Random().nextInt(100)}/600/400",
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF769676),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Accept & Earn +500 XP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Maybe later", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBoost() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_challenge?['stat_name'] ?? "Skill", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3E2D))),
            Text(_challenge?['stat_boost'] ?? "0%", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF769676))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.7,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F4EE),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE2E9D1)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessOverlay() {
    final String badgeName = _challenge?['badge_name'] ?? 'Comfort Zone Breaker';
    final String badgeIconName = _challenge?['badge_icon'] ?? 'psychology';
    final IconData badgeIcon = _resolveIcon(badgeIconName);

    return Container(
      color: Colors.black.withOpacity(0.9),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFFEAB308), Color(0xFFF97316)]),
                boxShadow: [BoxShadow(color: const Color(0xFFEAB308).withOpacity(0.5), blurRadius: 40, spreadRadius: 10)],
              ),
              child: Icon(badgeIcon, color: Colors.white, size: 80),
            ),
          ),
          const SizedBox(height: 40),
          const Text("DNA UPGRADED!", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3)),
          const SizedBox(height: 10),
          Text(badgeName, style: const TextStyle(color: Color(0xFFEAB308), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("+500 XP Added to Profile", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 50),
          const CircularProgressIndicator(color: Colors.white),
        ],
      ),
    );
  }

  /// Maps AI-returned icon name string to a real IconData
  IconData _resolveIcon(String name) {
    const Map<String, IconData> map = {
      'psychology':        Icons.psychology,
      'emoji_events':      Icons.emoji_events,
      'local_fire_department': Icons.local_fire_department,
      'explore':           Icons.explore,
      'self_improvement':  Icons.self_improvement,
      'directions_walk':   Icons.directions_walk,
      'restaurant':        Icons.restaurant,
      'nightlife':         Icons.nightlife,
      'forest':            Icons.forest,
      'museum':            Icons.museum,
      'camera_alt':        Icons.camera_alt,
      'hiking':            Icons.hiking,
      'wb_sunny':          Icons.wb_sunny,
      'people':            Icons.people,
      'bolt':              Icons.bolt,
    };
    return map[name] ?? Icons.emoji_events;
  }

  Map<String, dynamic> _getFallbackChallenge(
      [String personality = 'Explorer', String dominantTrait = 'Nature']) {
    final Map<String, Map<String, dynamic>> fallbacks = {
      'Nature': {
        'vibe': 'Urban Dive',
        'main_text': 'Spend 2 hours exploring a busy street market without a map.',
        'sub_text': 'You love nature\'s calm, but city chaos builds resilience. Navigating the unexpected sharpens your spontaneity muscle.',
        'stat_name': 'Spontaneity',
        'stat_boost': '+18%',
        'image_keyword': 'street_market',
        'badge_name': 'Urban Pioneer',
        'badge_icon': 'explore',
      },
      'Adventure': {
        'vibe': 'Still Moment',
        'main_text': 'Sit in a local café for 1 hour with no phone — just observe.',
        'sub_text': 'Thrill Chasers rarely pause. This challenge builds mindful awareness that makes every future adventure richer.',
        'stat_name': 'Mindfulness',
        'stat_boost': '+15%',
        'image_keyword': 'cafe_window',
        'badge_name': 'Silent Observer',
        'badge_icon': 'self_improvement',
      },
      'Social': {
        'vibe': 'Solo Hour',
        'main_text': 'Take a solo 1-hour walk in nature without talking to anyone.',
        'sub_text': 'Social Butterflies thrive on connection, but solitude builds self-awareness. This is where your deepest ideas live.',
        'stat_name': 'Self-Awareness',
        'stat_boost': '+20%',
        'image_keyword': 'solo_forest_path',
        'badge_name': 'Lone Wanderer',
        'badge_icon': 'directions_walk',
      },
      'Culture': {
        'vibe': 'Wild Card',
        'main_text': 'Try an extreme outdoor activity you\'ve never done before.',
        'sub_text': 'Culture Seekers love learning — now learn from your own body\'s reaction to physical challenge.',
        'stat_name': 'Courage',
        'stat_boost': '+22%',
        'image_keyword': 'rock_climbing',
        'badge_name': 'Boundary Breaker',
        'badge_icon': 'local_fire_department',
      },
      'Luxury': {
        'vibe': 'Local Mode',
        'main_text': 'Spend a full day using only local transport and eating street food.',
        'sub_text': 'Luxury gives comfort, but going local gives you the real story of a place. This is how locals live.',
        'stat_name': 'Cultural Empathy',
        'stat_boost': '+17%',
        'image_keyword': 'local_bus_street',
        'badge_name': 'Street Level Hero',
        'badge_icon': 'restaurant',
      },
    };

    return fallbacks[dominantTrait] ?? {
      'vibe': 'Local Hero',
      'main_text': 'Visit a local market and start a conversation with a vendor.',
      'sub_text': 'Every great traveler connects with locals. Step beyond the tourist bubble and make a real human connection.',
      'stat_name': 'Social Energy',
      'stat_boost': '+15%',
      'image_keyword': 'local_market',
      'badge_name': 'People Connector',
      'badge_icon': 'people',
    };
  }
}
