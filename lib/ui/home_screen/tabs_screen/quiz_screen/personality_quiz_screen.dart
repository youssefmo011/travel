import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import 'quiz_analysis_screen.dart';

class PersonalityQuizScreen extends StatefulWidget {
  static const String routeName = 'personality-quiz';

  const PersonalityQuizScreen({super.key});

  @override
  State<PersonalityQuizScreen> createState() => _PersonalityQuizScreenState();
}

class _PersonalityQuizScreenState extends State<PersonalityQuizScreen> {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;

  int explorerScore = 0;
  int dreamerScore = 0;
  int socialScore = 0;
  int culturalScore = 0;
  int thrillScore = 0;
  int natureScore = 0;

  final List<String> _questions = [
    "I enjoy visiting places that are completely different from my usual environment.", 
    "I prefer making travel decisions that keep everyone in the group happy.", 
    "I feel excited when trying new activities during travel.", 
    "I like traveling with a group rather than alone.", 
    "I feel comfortable exploring unfamiliar places without guidance.", 
    "I prefer relaxing vacations over adventurous ones.", 
    "I enjoy meeting new people while traveling.", 
    "I tend to overthink travel plans before making decisions.", 
    "I like discovering hidden, less popular destinations.", 
    "I feel stressed when plans change suddenly during a trip.", 
    "I enjoy cultural experiences like museums and local traditions.", 
    "I prefer luxury and comfort over budget travel.", 
    "I like taking risks when choosing travel destinations.", 
    "I enjoy quiet places more than crowded tourist spots.", 
    "I rely on reviews and ratings before choosing a destination.", 
    "I enjoy physical activities like hiking, diving, or sports during trips.", 
    "I prefer short trips over long journeys.", 
    "I like documenting my trips (photos, videos, journaling).", 
    "I enjoy trying new foods from different cultures.", 
    "I consider my travel companions’ preferences when making travel plans.", 
    "I feel energized after traveling rather than exhausted.", 
    "I like visiting places that challenge my comfort zone.", 
    "I prefer traveling with people who share my personality.", 
    "I enjoy nightlife and social activities while traveling.", 
    "I feel confident making travel decisions on my own." 
  ];

  final List<String> _options = [
    "Totally agree",
    "Agree",
    "Neutral",
    "Disagree",
    "Totally disagree"
  ];


  final List<Map<String, int>> _answerHistory = [];
  bool _isProcessingAnswer = false;

  void _handleAnswer(int index) async {
    if (_isProcessingAnswer) return;
    _isProcessingAnswer = true;

    setState(() => _selectedOptionIndex = index);
    await Future.delayed(const Duration(milliseconds: 450));

    final int value = 5 - index;
    final int qIndex = _currentQuestionIndex + 1;

    final Map<String, int> deltas = {};

    void add(String key, int v) {
      switch (key) {
        case 'explorer':  explorerScore  += v; break;
        case 'dreamer':   dreamerScore   += v; break;
        case 'social':    socialScore    += v; break;
        case 'cultural':  culturalScore  += v; break;
        case 'thrill':    thrillScore    += v; break;
        case 'nature':    natureScore    += v; break;
      }
      deltas[key] = (deltas[key] ?? 0) + v;
    }

    if ([1, 5, 9, 22, 25].contains(qIndex)) add('explorer',  value);
    if ([6, 12, 14, 18].contains(qIndex))   add('dreamer',   value);
    if ([4, 7, 20, 23, 24].contains(qIndex)) add('social',   value);
    if ([8, 11, 15, 19].contains(qIndex))   add('cultural',  value);
    if ([3, 13, 16, 21].contains(qIndex))   add('thrill',    value);

    _answerHistory.add(deltas);

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _selectedOptionIndex = null;
        _isProcessingAnswer = false; 
      });
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    final Map<String, int> scores = {
      "Explorer":       explorerScore,
      "Dreamer":        dreamerScore,
      "Social Butterfly": socialScore,
      "Culture":        culturalScore,
      "Thrill Chaser":  thrillScore,
    };
    debugPrint('🧠 Quiz Scores: $scores');

    final String finalPersonality =
        scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final double natureP    = (natureScore   / 15).clamp(0.0, 1.0) * 100;
    final double thrillP    = (thrillScore   / 20).clamp(0.0, 1.0) * 100;
    final double culturalP  = (culturalScore / 20).clamp(0.0, 1.0) * 100;
    final double socialP    = (socialScore   / 25).clamp(0.0, 1.0) * 100;
    final double relaxP     = (dreamerScore  / 20).clamp(0.0, 1.0) * 100;
    var box = await Hive.openBox('user_prefs');
    await box.put('personality', finalPersonality);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'personality': finalPersonality,
          'badges': FieldValue.arrayUnion(['DNA Discovered']),
          'quizXp': FieldValue.increment(1000),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Error saving quiz results: $e");
      }
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context, 
      QuizAnalysisScreen.routeName, 
      arguments: {
        "personality": finalPersonality,
        "traits": {
          "Nature":    natureP.toInt(),
          "Adventure": thrillP.toInt(),
          "Culture":   culturalP.toInt(),
          "Social":    socialP.toInt(),
          "Dreamy":    relaxP.toInt(),
        },
        "raw_scores": scores,
        "score_detail": {
          "explorerScore":  explorerScore,
          "dreamerScore":   dreamerScore,
          "socialScore":    socialScore,
          "culturalScore":  culturalScore,
          "thrillScore":    thrillScore,
          "natureScore":    natureScore,
          "dominantStyle":  finalPersonality,
          "quizType":       "personality_25q",
        },
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF769676)),
              minHeight: 6,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_currentQuestionIndex > 0) {
                        if (_answerHistory.isNotEmpty) {
                          final Map<String, int> last = _answerHistory.removeLast();
                          last.forEach((key, v) {
                            switch (key) {
                              case 'explorer':  explorerScore  -= v; break;
                              case 'dreamer':   dreamerScore   -= v; break;
                              case 'social':    socialScore    -= v; break;
                              case 'cultural':  culturalScore  -= v; break;
                              case 'thrill':    thrillScore    -= v; break;
                              case 'nature':    natureScore    -= v; break;
                            }
                          });
                        }
                        setState(() {
                          _selectedOptionIndex = null;
                          _isProcessingAnswer = false;
                        });
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF2D3E2D)),
                  ),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300)
                    ),
                    child: Center(
                      child: Text(
                        '${_currentQuestionIndex + 1}/${_questions.length}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D))
                      )
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentQuestionIndex = index),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                const Center(child: Text('TRAVEL DNA QUIZ', style: TextStyle(fontSize: 9, letterSpacing: 2, color: Color(0xFF6B7280)))),
                                const SizedBox(height: 12),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _questions[index],
                                    key: ValueKey<int>(index),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D), height: 1.2)
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ...List.generate(_options.length, (i) => _buildOption(i)),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(height: 60, width: double.infinity, child: CustomPaint(painter: QuizBackgroundPainter())),
                const Padding(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: Text('Your preferences help us craft the perfect trip...', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Color(0xFF6B7280)))
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index) {
    bool isSelected = _selectedOptionIndex == index;
    String text = _options[index];

    List<Color> optionColors = [
      const Color(0xFF769676),
      const Color(0xFFA8C6A8),
      const Color(0xFFD1DCD1),
      const Color(0xFFE8EDE8),
      const Color(0xFFF2F5F2),
    ];

    return GestureDetector(
      onTap: () => _handleAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D3E2D) : optionColors[index], 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.white : const Color(0xFF2D3E2D),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
          )
        ),
      ),
    );
  }
}

class QuizBackgroundPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE8EDE8)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.8), 25, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.95), 15, paint..color = const Color(0xFFD1DCD1).withOpacity(0.5));
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
