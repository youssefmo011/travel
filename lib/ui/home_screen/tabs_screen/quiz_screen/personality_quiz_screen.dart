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

  // الحسابات
  int explorerScore = 0;
  int dreamerScore = 0;
  int socialScore = 0;
  int culturalScore = 0;
  int thrillScore = 0;

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

    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      String result = _calculateResult();
      Navigator.pushReplacementNamed(context, QuizAnalysisScreen.routeName, arguments: result);
    }
  }

  String _calculateResult() {
    Map<String, int> scores = {
      "Explorer": explorerScore,
      "Dreamer": dreamerScore,
      "Social Butterfly": socialScore,
      "Cultural Seeker": culturalScore,
      "Thrill Chaser": thrillScore,
    };
    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SafeArea(
        child: Column(
          children: [
            // الشريط العلوي زي الصورة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_currentQuestionIndex > 0) {
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF2D3E2D)),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        '${_currentQuestionIndex + 1}/25',
                        style: const TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF2D3E2D)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // الخط الأخضر
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(thickness: 4, color: Color(0xFF769676)),
            ),
            const SizedBox(height: 30),
            // الكلمة اللي فوق السؤال
            const Text(
              'TRAVEL DNA QUIZ',
              style: TextStyle(
                fontSize: 10, 
                letterSpacing: 2, 
                color: Color(0xFF6B7280), 
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentQuestionIndex = index),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // السؤال
                          Text(
                            _questions[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26, 
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF2D3E2D), 
                              height: 1.2
                            ),
                          ),
                          const SizedBox(height: 40),
                          // الاختيارات
                          ..._options.map((option) => _buildOption(option)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // الزخرفة السفلية
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: CustomPaint(painter: QuizBackgroundPainter()),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 40.0),
                  child: Text(
                    'Your preferences help us craft the perfect trip...',
                    style: TextStyle(
                      fontSize: 11, 
                      color: Color(0xFF6B7280), 
                      fontStyle: FontStyle.italic
                    ),
                  ),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFA8C6A8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15, 
            color: Color(0xFF2D3E2D), 
            fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }
}

class QuizBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8EDE8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.7), 50, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.9), 40, paint..color = const Color(0xFFD1DCD1).withOpacity(0.5));
    
    final linePaint = Paint()
      ..color = const Color(0xFFD1DCD1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.75);
    path.lineTo(size.width * 0.45, size.height * 0.88);
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.85);
    canvas.drawPath(path, linePaint);
    
    final path2 = Path();
    path2.moveTo(0, size.height * 0.95);
    path2.lineTo(size.width * 0.3, size.height * 0.85);
    path2.lineTo(size.width * 0.6, size.height * 0.95);
    path2.lineTo(size.width, size.height * 0.78);
    canvas.drawPath(path2, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
