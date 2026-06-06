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
    
    // Add randomness to prompt
    final List<String> categories = ["Social", "Gastronomy", "Extreme Adventure", "Local Tradition", "Mindfulness"];
    final String randomCategory = categories[Random().nextInt(categories.length)];
    final int seed = DateTime.now().millisecondsSinceEpoch;

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyCbvejXRoxKldEgpu5V3loc7e42Qt7Mm1k',
      );

      final prompt = """
        Seed: $seed. Category Focus: $randomCategory.
        User DNA: $personality, $traits.
        Task: Generate a UNIQUE 'Shuffle Challenge' that is COMPLETELY DIFFERENT from previous ones.
        The challenge must push them out of their comfort zone.
        
        Return ONLY a JSON object with:
        'vibe': short catchy name,
        'main_text': one punchy mission sentence,
        'sub_text': 2 sentences explaining why and the benefit,
        'stat_name': skill improved (Spontaneity, Courage, etc.),
        'stat_boost': '+X%',
        'image_keyword': specific keyword for an Unsplash-style photo.
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      final String aiResponse = response.text ?? "{}";

      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        setState(() {
          _challenge = jsonDecode(aiResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _challenge = _getFallbackChallenge();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAccept() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'challengeXp': FieldValue.increment(500),
        'badges': FieldValue.arrayUnion(['Comfort Zone Breaker']),
      }, SetOptions(merge: true));

      setState(() => _isSuccessOverlay = true);
      _badgeController.forward();

      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          ShuffleResultScreen.routeName,
          arguments: _challenge
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
              child: const Icon(Icons.psychology, color: Colors.white, size: 80),
            ),
          ),
          const SizedBox(height: 40),
          const Text("DNA UPGRADED!", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3)),
          const SizedBox(height: 10),
          const Text("Comfort Zone Breaker", style: TextStyle(color: Color(0xFFEAB308), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("+500 XP Added to Profile", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 50),
          const CircularProgressIndicator(color: Colors.white),
        ],
      ),
    );
  }

  Map<String, dynamic> _getFallbackChallenge() {
    return {"vibe": "Local Hero", "main_text": "Visit a local market and talk to a vendor.", "sub_text": "Break your shell.", "stat_name": "Social Energy", "stat_boost": "+15%", "image_keyword": "market"};
  }
}
