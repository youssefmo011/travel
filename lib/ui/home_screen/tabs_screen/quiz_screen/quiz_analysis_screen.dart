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

class _QuizAnalysisScreenState extends State<QuizAnalysisScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  Map<String, dynamic>? quizData;
  
  int _messageIndex = 0;
  final List<String> _loadingMessages = [
    "Consulting travel AI...",
    "Analyzing your unique vibe...",
    "Decoding your Travel DNA...",
    "Scouring the globe for matches...",
    "Crafting your travel persona..."
  ];
  late Timer _messageTimer;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _messageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _messageIndex = (_messageIndex + 1) % _loadingMessages.length);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && quizData == null) {
      quizData = args;
      _performAIAnalysis();
    }
  }

  Future<void> _performAIAnalysis() async {
    final String personality = quizData?['personality'] ?? "Traveler";
    final Map traits = quizData?['traits'] ?? {};

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyCbvejXRoxKldEgpu5V3loc7e42Qt7Mm1k',
      );

      final prompt = """
        User Personality: $personality. DNA Traits: $traits.
        1. Generate a personalized 1-sentence 'Personality Bio' that explains why they have this travel style.
        2. Recommend 3 global destinations matching this DNA.
        
        Return ONLY a JSON object:
        {
          "personalityBio": "your generated bio here",
          "destinations": [
            {"name": "...", "description": "...", "matchReason": "...", "matchPercentage": 95}
          ]
        }
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      final String aiResponse = response.text ?? "{}";
      
      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        final decoded = jsonDecode(aiResponse);
        Navigator.pushReplacementNamed(
          context, 
          QuizResultsScreen.routeName,
          arguments: {
            ...quizData!,
            "ai_results": jsonEncode(decoded['destinations']),
            "personality_bio": decoded['personalityBio'],
            "confidence": 98,
          },
        );
      }
    } catch (e) {
      if (mounted) Navigator.pushReplacementNamed(context, QuizResultsScreen.routeName, arguments: quizData);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _rotationController,
              child: const Icon(Icons.auto_awesome, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 40),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _loadingMessages[_messageIndex],
                key: ValueKey(_messageIndex),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
