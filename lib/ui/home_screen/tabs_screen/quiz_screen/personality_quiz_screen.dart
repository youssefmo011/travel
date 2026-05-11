import 'package:flutter/material.dart';
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

  void _handleAnswer(String option) {
    int value = 5 - _options.indexOf(option); 
    int qIndex = _currentQuestionIndex + 1;

    if ([1, 5, 9, 22, 25].contains(qIndex)) explorerScore += value;
    if ([6, 14, 18, 12].contains(qIndex)) dreamerScore += value;
    if ([4, 7, 24, 20, 23].contains(qIndex)) socialScore += value;
    if ([11, 19, 15, 8].contains(qIndex)) culturalScore += value;
    if ([3, 13, 16, 21].contains(qIndex)) thrillScore += value;
    if ([6, 14, 16].contains(qIndex)) natureScore += value;

    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    Map<String, int> scores = {
      "Explorer": explorerScore,
      "The dreamer": dreamerScore,
      "Social Butterfly": socialScore,
      "Cultural Seeker": culturalScore,
      "Thrill Chaser": thrillScore,
    };

    String finalPersonality = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    int topScore = scores[finalPersonality]!;
    
    int qCount = (finalPersonality == "Explorer" || finalPersonality == "Social Butterfly") ? 5 : 4;
    int minScore = qCount; 
    int maxScore = qCount * 5; 
    int confidencePercent = (((topScore - minScore) / (maxScore - minScore)) * 100).toInt();
    
    int naturePercent = (((natureScore - 3) / 12) * 100).toInt();

    Navigator.pushReplacementNamed(
      context, 
      QuizAnalysisScreen.routeName, 
      arguments: {
        "personality": finalPersonality,
        "confidence": confidencePercent,
        "nature": naturePercent,
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_currentQuestionIndex > 0) {
                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF2D3E2D)),
                  ),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
                    child: Center(child: Text('${_currentQuestionIndex + 1}/25', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D)))),
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24.0), child: Divider(thickness: 3, color: Color(0xFF769676))),
            
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
                                Text(
                                  _questions[index], 
                                  textAlign: TextAlign.center, 
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D), height: 1.2)
                                ),
                                const SizedBox(height: 32),
                                ..._options.map((option) => _buildOption(option)),
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
            
            // Bottom Decoration
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

  Widget _buildOption(String text) {
    return GestureDetector(
      onTap: () => _handleAnswer(text),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFA8C6A8), 
          borderRadius: BorderRadius.circular(30)
        ),
        child: Text(
          text, 
          textAlign: TextAlign.center, 
          style: const TextStyle(fontSize: 15, color: Color(0xFF2D3E2D), fontWeight: FontWeight.w500)
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
