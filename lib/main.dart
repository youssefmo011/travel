import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Imports الشاشات
import 'package:untitled1/ui/home_screen/home_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/chat_screen/chat_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/chat_screen/chat_details_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/explore_screen/explore_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/explore_screen/place_details_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/explore_screen/map_plan_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/explore_screen/shuffle_result_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/profile_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/personal_info_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/notifications_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/travel_history_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/favorites_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/help_support_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/gamified_profile_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/whats_new_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_question_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_analysis_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_results_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/personality_quiz_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_shuffle_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/trip_screen/trip_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/trip_screen/treasure_walk_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/trip_screen/adventure_summary_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/home_tab/widgets/add_post_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/home_tab/widgets/post_details_screen.dart';
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

  await Hive.initFlutter();
  await Hive.openBox('explore_cache');

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF769372)),
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
        PlaceDetailsScreen.routeName: (context) => const PlaceDetailsScreen(),
        MapPlanScreen.routeName: (context) => const MapPlanScreen(),
        ShuffleResultScreen.routeName: (context) => const ShuffleResultScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        PersonalInfoScreen.routeName: (context) => const PersonalInfoScreen(),
        NotificationsScreen.routeName: (context) => const NotificationsScreen(),
        TravelHistoryScreen.routeName: (context) => const TravelHistoryScreen(),
        FavoritesScreen.routeName: (context) => const FavoritesScreen(),
        HelpSupportScreen.routeName: (context) => const HelpSupportScreen(),
        GamifiedProfileScreen.routeName: (context) => const GamifiedProfileScreen(),
        WhatsNewScreen.routeName: (context) => const WhatsNewScreen(),
        QuizScreen.routeName: (context) => const QuizScreen(),
        QuizQuestionScreen.routeName: (context) => const QuizQuestionScreen(),
        PersonalityQuizScreen.routeName: (context) => const PersonalityQuizScreen(),
        QuizAnalysisScreen.routeName: (context) => const QuizAnalysisScreen(),
        QuizResultsScreen.routeName: (context) => const QuizResultsScreen(),
        QuizShuffleScreen.routeName: (context) => const QuizShuffleScreen(),
        TripScreen.routeName: (context) => const TripScreen(),
        TreasureWalkScreen.routeName: (context) => const TreasureWalkScreen(),
        AdventureSummaryScreen.routeName: (context) => const AdventureSummaryScreen(),
        AddPostScreen.routeName: (context) => const AddPostScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == 'post-details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PostDetailsScreen(
              postData: args['postData'],
              postId: args['postId'],
            ),
          );
        }
        return null;
      },
    );
  }
}
