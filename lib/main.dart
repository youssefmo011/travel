import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/ui/home_screen/home_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/chat_screen/chat_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/chat_screen/chat_details_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/explore_screen/explore_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/profile_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/personal_info_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/notifications_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/travel_history_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/favorites_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/help_support_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_question_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_analysis_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_results_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/trip_screen/trip_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/trip_screen/treasure_walk_screen.dart';
import 'package:untitled1/ui/login_screen/login_screen.dart';
import 'package:untitled1/ui/onboarding/onboarding_screen.dart';
import 'package:untitled1/ui/register_screen/register_screen.dart';
import 'package:untitled1/ui/splash_screen/splash_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B8E6B)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),

      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        ChatScreen.routeName: (context) => const ChatScreen(),
        ChatDetailsScreen.routeName: (context) => const ChatDetailsScreen(),
        ExploreScreen.routeName: (context) => const ExploreScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        PersonalInfoScreen.routeName: (context) => const PersonalInfoScreen(),
        NotificationsScreen.routeName: (context) => const NotificationsScreen(),
        TravelHistoryScreen.routeName: (context) => const TravelHistoryScreen(),
        FavoritesScreen.routeName: (context) => const FavoritesScreen(),
        HelpSupportScreen.routeName: (context) => const HelpSupportScreen(),
        QuizScreen.routeName: (context) => const QuizScreen(),
        QuizQuestionScreen.routeName: (context) => const QuizQuestionScreen(),
        QuizAnalysisScreen.routeName: (context) => const QuizAnalysisScreen(),
        QuizResultsScreen.routeName: (context) => const QuizResultsScreen(),

        // تعديل TripScreen لضمان عدم حدوث خطأ Null
        TripScreen.routeName: (context) => const TripScreen(),

        // تعديل TreasureWalkScreen ليكون أكثر أماناً
        TreasureWalkScreen.routeName: (context) {
          final Object? args = ModalRoute.of(context)?.settings.arguments;
          // تمرير الـ args مهما كانت قيمتها، والمعالجة تتم داخل الصفحة
          return TreasureWalkScreen(vibe: args);
        },
      },
    );
  }
}