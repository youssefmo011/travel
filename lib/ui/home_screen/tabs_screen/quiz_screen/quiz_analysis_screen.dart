import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'quiz_results_screen.dart';

class QuizAnalysisScreen extends StatefulWidget {
  static const String routeName = 'quiz-analysis';

  const QuizAnalysisScreen({super.key});

  @override
  State<QuizAnalysisScreen> createState() => _QuizAnalysisScreenState();
}

class _QuizAnalysisScreenState extends State<QuizAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  Map<String, dynamic>? quizData;
  bool _analysisStarted = false;

  int _messageIndex = 0;
  final List<String> _loadingMessages = [
    "Consulting travel AI...",
    "Analyzing your unique vibe...",
    "Decoding your Travel DNA...",
    "Scouring the globe for matches...",
    "Crafting your travel persona...",
    "Finding your perfect destinations...",
  ];
  late Timer _messageTimer;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _messageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(
            () => _messageIndex = (_messageIndex + 1) % _loadingMessages.length);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && !_analysisStarted) {
      quizData = args;
      _analysisStarted = true;
      _performAIAnalysis();
    }
  }

  /// Build a rich, structured prompt from whatever quiz data was passed in.
  String _buildPrompt(Map<String, dynamic> data) {
    final String personality = data['personality'] ?? 'Traveler';
    final Map traits = data['traits'] ?? {};
    final Map scoreDetail = data['score_detail'] ?? {};
    final List answeredQuestions = data['answered_questions'] ?? [];
    final List vibes = data['vibes'] ?? [];

    // ── Traits block ────────────────────────────────────────────────────────
    final StringBuffer traitsBlock = StringBuffer();
    if (traits.isNotEmpty) {
      traits.forEach((k, v) => traitsBlock.writeln('  - $k: $v%'));
    }

    // ── Detailed scores (25-question quiz) ──────────────────────────────────
    final StringBuffer scoresBlock = StringBuffer();
    if (scoreDetail.isNotEmpty) {
      scoreDetail.forEach((k, v) => scoresBlock.writeln('  - $k: $v'));
    }

    // ── Visual quiz answers (5-question quiz) ───────────────────────────────
    final StringBuffer answersBlock = StringBuffer();
    if (answeredQuestions.isNotEmpty) {
      for (final q in answeredQuestions) {
        answersBlock.writeln(
            '  Q: ${q['question']}  →  A: ${q['answer']} (vibe: ${q['vibe']})');
      }
    } else if (vibes.isNotEmpty) {
      answersBlock.writeln('  Selected vibes in order: ${vibes.join(', ')}');
    }

    // ── Dominant trait for destination weighting ────────────────────────────
    String dominantTrait = 'Balanced';
    if (traits.isNotEmpty) {
      final sorted = traits.entries.toList()
        ..sort((a, b) => (b.value as num).compareTo(a.value as num));
      dominantTrait = sorted.first.key.toString();
    } else if (vibes.isNotEmpty) {
      final Map<String, int> counts = {};
      for (var v in vibes) {
        counts[v.toString()] = (counts[v.toString()] ?? 0) + 1;
      }
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      dominantTrait = sorted.first.key;
    }

    return """
You are an expert travel personality AI. Your job is to recommend real-world destinations that are a GENUINE match for this specific traveler's quiz results.

══ TRAVELER PROFILE ══
Personality Type: $personality
Dominant Trait: $dominantTrait

══ TRAIT SCORES (0–100%) ══
${traitsBlock.isNotEmpty ? traitsBlock.toString() : '  (Not available)'}

══ DETAILED SCORE BREAKDOWN ══
${scoresBlock.isNotEmpty ? scoresBlock.toString() : '  (Not available)'}

══ QUIZ ANSWERS ══
${answersBlock.isNotEmpty ? answersBlock.toString() : '  (Not available)'}

══ YOUR TASKS ══

1. Write a vivid 1–2 sentence personality bio that reflects exactly what their quiz answers reveal about their travel style. Reference specific traits.

2. Recommend exactly 5 real travel destinations. The recommendations MUST:
   - Be directly driven by the trait scores and quiz answers above.
   - Prioritize destinations that match the DOMINANT trait ($dominantTrait).
   - Include a MIX of destination types (at least one each from the top 2 traits).
   - Each matchReason MUST reference specific answers or trait scores from above (e.g., "Your 80% Adventure score and choice of 'Extreme Sports' afternoon point directly to Patagonia's raw wilderness").
   - matchPercentage must vary realistically (highest for dominant trait match, lower for secondary matches). Range: 78–97.
   - bestFor must be a specific 2–4 word activity tag matching what the traveler chose.

══ STRICT OUTPUT FORMAT ══
Return ONLY valid JSON. No markdown, no code fences, no explanation. Start with {{ and end with }}.

{
  "personalityBio": "...",
  "destinations": [
    {
      "name": "City, Country",
      "category": "Nature | Adventure | Culture | City | Luxury",
      "description": "2–3 sentences. Vivid. Specific.",
      "matchReason": "Direct reference to their trait scores or quiz answers.",
      "matchPercentage": 95,
      "bestFor": "Hiking & Wildlife"
    }
  ]
}
""";
  }

  Future<void> _performAIAnalysis() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyCbvejXRoxKldEgpu5V3loc7e42Qt7Mm1k',
      );

      final String prompt = _buildPrompt(quizData!);
      final response = await model.generateContent([Content.text(prompt)]);
      final String rawResponse = response.text ?? '{}';

      // Minimum loading feel
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Clean and parse
      final String clean = rawResponse
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      Map<String, dynamic> decoded = {};
      try {
        decoded = jsonDecode(clean) as Map<String, dynamic>;
      } catch (_) {
        // Try to extract JSON substring if there's surrounding text
        final match = RegExp(r'\{[\s\S]*\}').firstMatch(clean);
        if (match != null) {
          decoded = jsonDecode(match.group(0)!) as Map<String, dynamic>;
        }
      }

      final List destinations = decoded['destinations'] ?? [];
      final String bio = decoded['personalityBio'] ?? '';

      Navigator.pushReplacementNamed(
        context,
        QuizResultsScreen.routeName,
        arguments: {
          ...quizData!,
          'ai_results': jsonEncode(destinations.isNotEmpty
              ? destinations
              : _getFallbackDestinations(quizData!['personality'] ?? 'Explorer')),
          'personality_bio': bio.isNotEmpty
              ? bio
              : 'Your travel DNA is uniquely crafted based on your preferences.',
          'confidence': 98,
        },
      );
    } catch (e) {
      if (!mounted) return;
      // Fall back gracefully — still show results with personality-aware fallbacks
      Navigator.pushReplacementNamed(
        context,
        QuizResultsScreen.routeName,
        arguments: {
          ...quizData!,
          'ai_results': jsonEncode(
              _getFallbackDestinations(quizData!['personality'] ?? 'Explorer')),
          'personality_bio':
              'Your travel DNA reveals a unique explorer ready to discover the world.',
          'confidence': 92,
        },
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _messageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D3E2D), Color(0xFF769676)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              ScaleTransition(
                scale: Tween(begin: 0.95, end: 1.05).animate(
                  CurvedAnimation(
                      parent: _pulseController, curve: Curves.easeInOut),
                ),
                child: RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        size: 48, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'ANALYZING YOUR TRAVEL DNA',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  _loadingMessages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 3,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Powered by Gemini AI  ✦  ${quizData?['personality'] ?? ''}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Personality-aware fallbacks so the screen is never empty
  List<Map<String, dynamic>> _getFallbackDestinations(String personality) {
    final Map<String, List<Map<String, dynamic>>> fallbacks = {
      'Thrill Chaser': [
        {
          'name': 'Queenstown, New Zealand',
          'category': 'Adventure',
          'description':
              'The adventure capital of the world, packed with bungee jumping, skydiving, and white-water rafting against a stunning alpine backdrop.',
          'matchReason':
              'Your high Adventure score and preference for extreme activities make Queenstown your natural habitat.',
          'matchPercentage': 96,
          'bestFor': 'Extreme Sports',
        },
        {
          'name': 'Patagonia, Argentina',
          'category': 'Adventure',
          'description':
              'Dramatic glaciers, jagged peaks, and raw Andean wilderness at the southernmost tip of the world.',
          'matchReason':
              'Thrill Chasers thrive in Patagonia\'s unforgiving terrain and endless hiking trails.',
          'matchPercentage': 91,
          'bestFor': 'Trekking & Glaciers',
        },
        {
          'name': 'Moab, Utah, USA',
          'category': 'Adventure',
          'description':
              'Red rock canyons and world-class mountain biking, climbing, and off-road trails baked in desert sun.',
          'matchReason':
              'Your active travel style aligns perfectly with Moab\'s non-stop outdoor action.',
          'matchPercentage': 87,
          'bestFor': 'Mountain Biking & Climbing',
        },
        {
          'name': 'Iceland',
          'category': 'Nature',
          'description':
              'Volcanoes, waterfalls, geysers, and the Northern Lights — Iceland is raw nature at its most dramatic.',
          'matchReason':
              'Your love of pushing limits extends naturally to Iceland\'s extreme landscapes.',
          'matchPercentage': 84,
          'bestFor': 'Volcano & Aurora Hiking',
        },
        {
          'name': 'Medellin, Colombia',
          'category': 'City',
          'description':
              'A city reborn, with vibrant nightlife, paragliding over green valleys, and a pulsing local energy.',
          'matchReason':
              'Medellin\'s mix of urban buzz and outdoor thrills suits your spontaneous, high-energy nature.',
          'matchPercentage': 80,
          'bestFor': 'Paragliding & Nightlife',
        },
      ],
      'Explorer': [
        {
          'name': 'Kyoto, Japan',
          'category': 'Culture',
          'description':
              'Ancient temples, zen gardens, and centuries of tradition layered into every street and shrine.',
          'matchReason':
              'Your Nature affinity and love of quiet, meaningful places make Kyoto an ideal match.',
          'matchPercentage': 94,
          'bestFor': 'Temple Trails & Gardens',
        },
        {
          'name': 'Norwegian Fjords, Norway',
          'category': 'Nature',
          'description':
              'Towering cliffs, mirror-still water, and villages perched impossibly above the sea.',
          'matchReason':
              'Explorers with high Nature scores find their deepest peace in the Norwegian wilderness.',
          'matchPercentage': 90,
          'bestFor': 'Kayaking & Scenic Hiking',
        },
        {
          'name': 'Patagonia, Chile',
          'category': 'Nature',
          'description':
              'Torres del Paine\'s glaciers and guanacos roaming open steppe — one of earth\'s last wild places.',
          'matchReason':
              'Your independent explorer spirit thrives in Patagonia\'s off-the-grid solitude.',
          'matchPercentage': 88,
          'bestFor': 'Wilderness Trekking',
        },
        {
          'name': 'Luang Prabang, Laos',
          'category': 'Culture',
          'description':
              'A UNESCO-listed town where golden temples, monks at dawn, and the Mekong create a timeless calm.',
          'matchReason':
              'Hidden gems like Luang Prabang are exactly what curious Explorers seek.',
          'matchPercentage': 85,
          'bestFor': 'Cultural Immersion',
        },
        {
          'name': 'Azores, Portugal',
          'category': 'Nature',
          'description':
              'Volcanic islands in the mid-Atlantic with crater lakes, whale watching, and almost no crowds.',
          'matchReason':
              'Your preference for quiet, less-traveled places is perfectly answered by the Azores.',
          'matchPercentage': 82,
          'bestFor': 'Island Exploration',
        },
      ],
      'Social Butterfly': [
        {
          'name': 'Barcelona, Spain',
          'category': 'City',
          'description':
              'Beachfront boulevards, world-class tapas bars, and a nightlife that doesn\'t start until midnight.',
          'matchReason':
              'Your high Social score and love of meeting new people are tailor-made for Barcelona\'s open culture.',
          'matchPercentage': 95,
          'bestFor': 'Tapas & Beach Parties',
        },
        {
          'name': 'Rio de Janeiro, Brazil',
          'category': 'City',
          'description':
              'Carnival energy year-round, iconic beaches, samba in the streets, and a warmth that is contagious.',
          'matchReason':
              'Social Butterflies thrive in Rio\'s infectious, communal celebration of life.',
          'matchPercentage': 91,
          'bestFor': 'Samba & Beach Festivals',
        },
        {
          'name': 'Amsterdam, Netherlands',
          'category': 'City',
          'description':
              'Canal-side cafés, world-class museums, vibrant markets, and one of Europe\'s most welcoming cities.',
          'matchReason':
              'Your spontaneous city nature finds endless social opportunities in Amsterdam\'s open culture.',
          'matchPercentage': 87,
          'bestFor': 'Canal Cycling & Nightlife',
        },
        {
          'name': 'Bali, Indonesia',
          'category': 'Nature',
          'description':
              'A global gathering place for travelers — yoga retreats, beach clubs, and co-working cafés all in one.',
          'matchReason':
              'Bali\'s traveler community is perfect for Social Butterflies who want connection with scenery.',
          'matchPercentage': 83,
          'bestFor': 'Retreats & Beach Clubs',
        },
        {
          'name': 'Tokyo, Japan',
          'category': 'City',
          'description':
              'A city of infinite neighborhoods, each with its own culture, food scene, and social energy.',
          'matchReason':
              'Tokyo\'s urban density and cultural variety feed a Social Butterfly\'s hunger for new experiences.',
          'matchPercentage': 79,
          'bestFor': 'Street Food & Nightlife',
        },
      ],
      'Luxury Seeker': [
        {
          'name': 'Maldives',
          'category': 'Luxury',
          'description':
              'Overwater bungalows above turquoise lagoons, private butlers, and sunsets that redefine beauty.',
          'matchReason':
              'Your Luxury score and preference for Tropical Beach mornings point directly to the Maldives.',
          'matchPercentage': 97,
          'bestFor': 'Overwater Villa & Spa',
        },
        {
          'name': 'Amalfi Coast, Italy',
          'category': 'Luxury',
          'description':
              'Dramatic cliffside towns, Michelin-starred restaurants, and private yacht cruises on crystal water.',
          'matchReason':
              'Planned luxury travelers find the Amalfi Coast\'s curated elegance irresistible.',
          'matchPercentage': 93,
          'bestFor': 'Fine Dining & Yacht Days',
        },
        {
          'name': 'Dubai, UAE',
          'category': 'Luxury',
          'description':
              'Skyscrapers, private beaches, 7-star hotels, and a shopping scene that defies imagination.',
          'matchReason':
              'Your Luxury Seeker personality gravitates toward Dubai\'s world-class opulence.',
          'matchPercentage': 89,
          'bestFor': 'Ultra-Luxury Stays',
        },
        {
          'name': 'Santorini, Greece',
          'category': 'Luxury',
          'description':
              'Whitewashed infinity pools, volcanic sunsets, and cave suites carved into the caldera.',
          'matchReason':
              'Luxury Seekers love Santorini for its intimate, photogenic perfection.',
          'matchPercentage': 85,
          'bestFor': 'Sunset Views & Wine',
        },
        {
          'name': 'Kyoto, Japan',
          'category': 'Culture',
          'description':
              'Exclusive ryokan experiences, private tea ceremonies, and serene temple mornings.',
          'matchReason':
              'Luxury in Kyoto is quiet, refined, and deeply meaningful — perfectly matching your style.',
          'matchPercentage': 81,
          'bestFor': 'Ryokan & Private Gardens',
        },
      ],
    };

    return fallbacks[personality] ??
        fallbacks['Explorer']!;
  }
}
