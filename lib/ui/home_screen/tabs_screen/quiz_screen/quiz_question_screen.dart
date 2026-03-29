import 'package:flutter/material.dart';
import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import 'quiz_analysis_screen.dart';
import 'widgets/option_card.dart';

class QuizQuestion {
  final String question;
  final String description;
  final String highlightWord;
  final List<QuizOption> options;

  QuizQuestion({
    required this.question,
    required this.description,
    required this.highlightWord,
    required this.options,
  });
}

class QuizOption {
  final String title;
  final String image;
  final String vibe; // 'Nature', 'City', 'Luxury', 'Adventure'

  QuizOption({required this.title, required this.image, required this.vibe});
}

class QuizQuestionScreen extends StatefulWidget {
  static const String routeName = 'quiz-question';

  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int _currentStep = 0;
  int? _selectedOptionIndex;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'How do you like to ',
      highlightWord: 'move?',
      description: 'Choose the pace that fits your travel style.',
      options: [
        QuizOption(title: 'Fast & Active', image: AppAssets.fastActive, vibe: 'Adventure'),
        QuizOption(title: 'Slow & Chill', image: AppAssets.onboarding, vibe: 'Nature'),
        QuizOption(title: 'Spontaneous', image: AppAssets.storyPhoto, vibe: 'City'),
        QuizOption(title: 'Planned Luxury', image: AppAssets.profilePhoto, vibe: 'Luxury'),
      ],
    ),
    QuizQuestion(
      question: 'What is your ideal ',
      highlightWord: 'morning view?',
      description: 'Choose the landscape that makes your heart feel at peace.',
      options: [
        QuizOption(title: 'Quiet Forest', image: AppAssets.photoTravel, vibe: 'Nature'),
        QuizOption(title: 'Busy City Cafe', image: AppAssets.storyPhoto, vibe: 'City'),
        QuizOption(title: 'Mountain Peak', image: AppAssets.onboarding, vibe: 'Adventure'),
        QuizOption(title: 'Tropical Beach', image: AppAssets.profilePhoto, vibe: 'Luxury'),
      ],
    ),
    QuizQuestion(
      question: 'Your perfect ',
      highlightWord: 'afternoon?',
      description: 'What activity makes you lose track of time?',
      options: [
        QuizOption(title: 'Museums & Art', image: AppAssets.storyPhoto, vibe: 'City'),
        QuizOption(title: 'Extreme Sports', image: AppAssets.photoTravel, vibe: 'Adventure'),
        QuizOption(title: 'Sunbathing', image: AppAssets.profilePhoto, vibe: 'Luxury'),
        QuizOption(title: 'Forest Hiking', image: AppAssets.onboarding, vibe: 'Nature'),
      ],
    ),
    QuizQuestion(
      question: 'How is your ',
      highlightWord: 'Friday night?',
      description: 'The vibe you seek when the sun goes down.',
      options: [
        QuizOption(title: 'Street Market', image: AppAssets.storyPhoto, vibe: 'City'),
        QuizOption(title: 'Cozy Cafe', image: AppAssets.onboarding, vibe: 'Nature'),
        QuizOption(title: 'Vibrant Club', image: AppAssets.photoTravel, vibe: 'Luxury'),
        QuizOption(title: 'Sunset Hike', image: AppAssets.photoTravel, vibe: 'Adventure'),
      ],
    ),
    QuizQuestion(
      question: 'What is your ',
      highlightWord: 'dream stay?',
      description: 'Where you rest determines your experience.',
      options: [
        QuizOption(title: 'Boutique Hotel', image: AppAssets.storyPhoto, vibe: 'City'),
        QuizOption(title: 'Cozy Cabin', image: AppAssets.onboarding, vibe: 'Nature'),
        QuizOption(title: 'Luxury Resort', image: AppAssets.profilePhoto, vibe: 'Luxury'),
        QuizOption(title: 'Camping Tent', image: AppAssets.photoTravel, vibe: 'Adventure'),
      ],
    ),
  ];

  void _nextStep() {
    if (_selectedOptionIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option first!')),
      );
      return;
    }

    if (_currentStep < _questions.length - 1) {
      setState(() {
        _currentStep++;
        _selectedOptionIndex = null;
      });
    } else {
      Navigator.pushNamed(context, QuizAnalysisScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentStep];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_currentStep > 0) {
                          setState(() => _currentStep--);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    Text(
                      'STEP ${_currentStep + 1} / ${_questions.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                          children: [
                            TextSpan(text: currentQuestion.question),
                            TextSpan(
                              text: '${currentQuestion.highlightWord}\n',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentQuestion.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: List.generate(
                    currentQuestion.options.length,
                    (index) => OptionCard(
                      index: index,
                      title: currentQuestion.options[index].title,
                      imagePath: currentQuestion.options[index].image,
                      isSelected: _selectedOptionIndex == index,
                      onTap: () {
                        setState(() {
                          _selectedOptionIndex = index;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildDiscoveryCard(),
                const SizedBox(height: 24),
                _buildStepIndicator(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Discovery Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  'Every choice shapes your vibe.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _nextStep,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_questions.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentStep == index ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: _currentStep == index ? AppColors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
