import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/ui/onboarding/onboarding_screen.dart';
import 'package:untitled1/ui/home_screen/home_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/chat_screen/chat_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/explore_screen/explore_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/profile_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/quiz_screen/quiz_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/trip_screen/trip_screen.dart';
import 'package:untitled1/ui/login_screen/login_screen.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
        ExploreScreen.routeName: (context) => const ExploreScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        QuizScreen.routeName: (context) => const QuizScreen(),
        TripScreen.routeName: (context) => const TripScreen(),
      },
    );
  }
}