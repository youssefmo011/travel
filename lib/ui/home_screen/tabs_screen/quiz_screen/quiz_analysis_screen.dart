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
    "Scouring Egypt for matches...",
    "Crafting your travel persona...",
    "Finding your perfect Egyptian destinations...",
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

  String _buildPrompt(Map<String, dynamic> data) {
    final String personality = data['personality'] ?? 'Explore';
    final Map traits = data['traits'] ?? {};
    final Map scoreDetail = data['score_detail'] ?? {};
    final List answeredQuestions = data['answered_questions'] ?? [];
    final List vibes = data['vibes'] ?? [];

    final StringBuffer traitsBlock = StringBuffer();
    if (traits.isNotEmpty) {
      traits.forEach((k, v) => traitsBlock.writeln('  - $k: $v%'));
    }

    final StringBuffer scoresBlock = StringBuffer();
    if (scoreDetail.isNotEmpty) {
      scoreDetail.forEach((k, v) => scoresBlock.writeln('  - $k: $v'));
    }

    final StringBuffer answersBlock = StringBuffer();
    if (answeredQuestions.isNotEmpty) {
      for (final q in answeredQuestions) {
        answersBlock.writeln(
            '  Q: ${q['question']}  →  A: ${q['answer']} (vibe: ${q['vibe']})');
      }
    } else if (vibes.isNotEmpty) {
      answersBlock.writeln('  Selected vibes in order: ${vibes.join(', ')}');
    }

    String dominantTrait = 'Balanced';
    if (traits.isNotEmpty) {
      final sorted = traits.entries.toList()
        ..sort((a, b) => (b.value as num).compareTo(a.value as num));
      dominantTrait = sorted.first.key.toString();
    }

    return """
You are an expert travel personality AI specializing in Egypt Tourism. Your job is to recommend real-world destinations WITHIN EGYPT that are a GENUINE match for this specific traveler's quiz results.

══ TRAVELER PROFILE ══
Personality Type: $personality (Can be: Explore, Dreamer, Social, Cultural, Thrill)
Dominant Trait: $dominantTrait

══ TRAIT SCORES (0–100%) ══
${traitsBlock.isNotEmpty ? traitsBlock.toString() : '  (Not available)'}

══ DETAILED SCORE BREAKDOWN ══
${scoresBlock.isNotEmpty ? scoresBlock.toString() : '  (Not available)'}

══ QUIZ ANSWERS ══
${answersBlock.isNotEmpty ? answersBlock.toString() : '  (Not available)'}

══ YOUR TASKS ══

1. Write a vivid 1–2 sentence personality bio that reflects exactly what their quiz answers reveal about their travel style. Reference specific traits and mention why Egypt is perfect for them.

2. Recommend exactly 5 real travel destinations IN EGYPT. The recommendations MUST:
   - Be directly driven by the trait scores and quiz answers above.
   - Prioritize destinations that match the personality type ($personality).
   - Include a MIX of Egyptian destination types (Oases, Red Sea, Nile Cities, Historic Cairo).
   - Each matchReason MUST reference specific answers or trait scores from above.
   - matchPercentage must vary realistically. Range: 78–97.
   - bestFor must be a specific 2–4 word activity tag matching what the traveler chose.

══ STRICT OUTPUT FORMAT ══
Return ONLY valid JSON. No markdown, no code fences, no extra explanation. The response must start with { and end with }.

Example structure:
{
  "personalityBio": "...",
  "destinations": [
    {
      "name": "City, Egypt",
      "category": "Nature | Adventure | Culture | City | Luxury",
      "description": "2-3 sentences. Vivid. Specific.",
      "matchReason": "Direct reference to their trait scores or quiz answers.",
      "matchPercentage": 95,
      "bestFor": "Diving & Canyons"
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

      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      final String clean = rawResponse
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      Map<String, dynamic> decoded = {};
      try {
        decoded = jsonDecode(clean) as Map<String, dynamic>;
      } catch (e) {
        final match = RegExp(r'\{[\s\S]*\}').firstMatch(clean);
        if (match != null) {
          decoded = jsonDecode(match.group(0)!) as Map<String, dynamic>;
        }
      }

      final List destinations = decoded['destinations'] ?? [];
      final String bio = decoded['personalityBio'] ?? '';

      final String personality = quizData!['personality'] ?? 'Explorer';
      Navigator.pushReplacementNamed(
        context,
        QuizResultsScreen.routeName,
        arguments: {
          ...quizData!,
          'ai_results': jsonEncode(destinations.isNotEmpty
              ? destinations
              : _getFallbackDestinations(personality)),
          'personality_bio': bio.isNotEmpty
              ? bio
              : 'Your travel DNA is uniquely crafted based on your preferences.',
          'confidence': 98,
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        QuizResultsScreen.routeName,
        arguments: {
          ...quizData!,
          'ai_results': jsonEncode(
              _getFallbackDestinations(quizData!['personality'] ?? 'Explorer')),
          'personality_bio':
              'Your travel DNA reveals a unique explorer ready to discover the beauty of Egypt.',
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

  List<Map<String, dynamic>> _getFallbackDestinations(String personality) {
    debugPrint('🗺️ Using Egyptian fallback for personality: "$personality"');
    final Map<String, List<Map<String, dynamic>>> fallbacks = {
      'Thrill Chaser': [
        {
          'name': 'Dahab, Egypt',
          'category': 'Adventure',
          'description': 'The ultimate hub for diving, windsurfing, and mountain trekking. Home to the world-famous Blue Hole.',
          'matchReason': 'Your desire for extreme activities and high adventure energy perfectly matches Dahab\'s rugged vibe.',
          'matchPercentage': 96,
          'bestFor': 'Diving & Extreme Sports',
        },
        {
          'name': 'Ras Mohammed, Egypt',
          'category': 'Adventure',
          'description': 'A world-renowned marine national park with some of the most vibrant coral reefs and diverse marine life on the planet.',
          'matchReason': 'Thrill seekers thrive in the deep, clear waters of the Red Sea.',
          'matchPercentage': 91,
          'bestFor': 'Deep Sea Diving',
        },
        {
          'name': 'Wadi El Hitan, Fayoum',
          'category': 'Adventure',
          'description': 'Prehistoric whale fossils meet majestic desert dunes. Ideal for sandboarding and stargazing.',
          'matchReason': 'Your active travel style aligns with off-road exploration and desert thrills.',
          'matchPercentage': 87,
          'bestFor': 'Desert Safaris',
        },
      ],
      'Explorer': [
        {
          'name': 'Siwa Oasis, Egypt',
          'category': 'Nature',
          'description': 'A mystical oasis with salt lakes, Cleopatra\'s spring, and an ancient mud-brick fortress.',
          'matchReason': 'Explorers with high Nature scores find their deepest peace in Siwa\'s unique and remote landscape.',
          'matchPercentage': 94,
          'bestFor': 'Eco-tourism & Wellness',
        },
        {
          'name': 'The White Desert, Egypt',
          'category': 'Nature',
          'description': 'Surreal chalk rock formations that look like an alien world. The ultimate camping experience.',
          'matchReason': 'Your independent explorer spirit thrives in the silent solitude of the Western Desert.',
          'matchPercentage': 90,
          'bestFor': 'Wilderness Camping',
        },
        {
          'name': 'Nuweiba, Egypt',
          'category': 'Nature',
          'description': 'Where the mountains meet the sea. Simple camps, star-filled nights, and pure tranquility.',
          'matchReason': 'Your preference for quiet, less-traveled places is perfectly answered by Nuweiba\'s beach camps.',
          'matchPercentage': 86,
          'bestFor': 'Slow & Chill Travel',
        },
      ],
      'Social Butterfly': [
        {
          'name': 'Zamalek, Cairo',
          'category': 'City',
          'description': 'The cosmopolitan heart of Cairo. Filled with trendy cafes, art galleries, and vibrant social spots.',
          'matchReason': 'Your high Social score and love of meeting people are tailor-made for Zamalek\'s lively streets.',
          'matchPercentage': 95,
          'bestFor': 'Coffee & Socializing',
        },
        {
          'name': 'El Gouna, Egypt',
          'category': 'City',
          'description': 'A vibrant community on the Red Sea with amazing beach clubs, kitesurfing, and social events.',
          'matchReason': 'Social personalities thrive in El Gouna\'s upscale, international social scene.',
          'matchPercentage': 91,
          'bestFor': 'Beach Parties & Sports',
        },
        {
          'name': 'Alexandria, Egypt',
          'category': 'City',
          'description': 'The Pearl of the Mediterranean. Historic cafes, seafood, and a classic city energy.',
          'matchReason': 'Your spontaneous city nature finds endless social opportunities along Alexandria\'s Corniche.',
          'matchPercentage': 87,
          'bestFor': 'City Walks & Seafood',
        },
      ],
      'Culture': [
        {
          'name': 'Luxor, Egypt',
          'category': 'Culture',
          'description': 'The world\'s greatest open-air museum. Home to the Valley of the Kings and Karnak Temple.',
          'matchReason': 'Your high Culture score makes Luxor\'s epic history an essential destination.',
          'matchPercentage': 98,
          'bestFor': 'History & Archaeology',
        },
        {
          'name': 'Historic Cairo, Egypt',
          'category': 'Culture',
          'description': 'Muizz Street, the Citadel, and Khan el-Khalili. A walk through Islamic Cairo is a walk through time.',
          'matchReason': 'Culture-driven travelers find Cairo\'s ancient streets and mosques endlessly rewarding.',
          'matchPercentage': 94,
          'bestFor': 'Historic Walking Tours',
        },
        {
          'name': 'Aswan, Egypt',
          'category': 'Culture',
          'description': 'Explore Nubian culture and the magnificent temples of Abu Simbel and Philae.',
          'matchReason': 'Matches your appreciation for tradition and deep cultural immersion.',
          'matchPercentage': 90,
          'bestFor': 'Ancient Heritage',
        },
      ],
      'Dreamer': [
        {
          'name': 'Nuweiba, Egypt',
          'category': 'Nature',
          'description': 'Simple camps and breathtaking star-filled nights by the sea. A place where time stands still.',
          'matchReason': 'Dreamers connect deeply with the peaceful and ethereal atmosphere of Nuweiba\'s coastline.',
          'matchPercentage': 95,
          'bestFor': 'Sunset Views & Relaxation',
        },
        {
          'name': 'Aswan at Sunset, Egypt',
          'category': 'Culture',
          'description': 'Taking a Felucca on the Nile as the sun sets behind the tombs of the nobles.',
          'matchReason': 'Your reflective and poetic travel style matches Aswan\'s timeless beauty.',
          'matchPercentage': 91,
          'bestFor': 'Nile Reflection',
        },
        {
          'name': 'The White Desert, Egypt',
          'category': 'Nature',
          'description': 'The alien chalk formations under a full moon look like a landscape from another planet.',
          'matchReason': 'Your love for surreal and beautiful landscapes makes this a Dreamer\'s paradise.',
          'matchPercentage': 88,
          'bestFor': 'Star Gazing',
        },
      ],
    };

    return fallbacks[personality] ?? fallbacks['Explorer']!;
  }
}
