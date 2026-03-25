import 'package:flutter/material.dart';
import 'package:untitled1/ui/login_screen/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  static const String routeName = 'onboarding';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F4),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 40.0, right: 30.0),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3E4E35),
                    height: 1.1,
                  ),
                  children: [
                    TextSpan(text: 'we PLAN ,\n'),
                    TextSpan(text: 'you MOVE..\n'),
                    TextSpan(text: 'Share your\njourney.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(160),
                    image: const DecorationImage(

                      image: AssetImage('assets/images/onboarding.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E9E0),
                borderRadius: BorderRadius.circular(45),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome to Travel Me',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B2612)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Explore, Connect, and Create Memories\nwith your fellow travelers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF5A6650), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 25, height: 7, decoration: BoxDecoration(color: const Color(0xFF3E4E35), borderRadius: BorderRadius.circular(10))),
                      const SizedBox(width: 5),
                      const CircleAvatar(radius: 3.5, backgroundColor: Colors.black12),
                      const SizedBox(width: 5),
                      const CircleAvatar(radius: 3.5, backgroundColor: Colors.black12),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E4E35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                      },
                      child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}