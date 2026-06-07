import 'package:flutter/material.dart';
import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import 'personality_quiz_screen.dart';
import 'widgets/feature_item.dart';

class QuizScreen extends StatelessWidget {
  static const String routeName = 'quiz';

  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 40),
                const Text(
                  'Ready to find your vibe?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Discover your perfect travel personality in under 2 minutes. Our AI will guide your next adventure!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                _buildIllustration(),
                const SizedBox(height: 40),
                const FeatureItem(
                  icon: AppAssets.exploreIcon,
                  text: 'Instant Personalized Matches',
                ),
                const SizedBox(height: 15),
                const FeatureItem(
                  icon: AppAssets.streakIcon,
                  text: 'Unlock Exclusive Rewards',
                ),
                const SizedBox(height: 40),
                _buildStartButton(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: const DecorationImage(
          image: AssetImage(AppAssets.photoTravel),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, PersonalityQuizScreen.routeName),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Text(
          'Start Discovery Quiz',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
