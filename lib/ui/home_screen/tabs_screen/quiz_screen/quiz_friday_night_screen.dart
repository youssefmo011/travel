import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'quiz_analysis_screen.dart';

class QuizFridayNightScreen extends StatelessWidget {
  static const String routeName = 'quiz-friday-night';

  const QuizFridayNightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9), // Light cream background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Text(
                          '4/5',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Divider(thickness: 2, color: AppColors.primary),
              ),
              const SizedBox(height: 40),
              const Text(
                'TRAVEL DNA QUIZ',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'How do you usually like to spend your Friday nights?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    _buildOption(context, 'Exploring a hidden street market'),
                    _buildOption(context, 'Reading a book in a cozy cafe'),
                    _buildOption(context, 'Dancing at a vibrant club'),
                    _buildOption(context, 'Hiking to see the sunset'),
                  ],
                ),
              ),
              // Bottom decoration and text
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: BackgroundDecorationPainter(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      'Your preferences help us craft the perfect trip...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, QuizAnalysisScreen.routeName);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFA8C6A8), // Light green color for options
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class BackgroundDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8EDE8)
      ..style = PaintingStyle.fill;

    // Draw circles as seen in background
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.6), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 30, paint..color = const Color(0xFFD1DCD1));
    
    final linePaint = Paint()
      ..color = const Color(0xFFD1DCD1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw some abstract lines
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.5, size.height * 0.85);
    path.lineTo(size.width * 0.8, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.75);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
