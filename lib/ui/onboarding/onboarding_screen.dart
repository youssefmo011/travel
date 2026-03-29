import 'package:flutter/material.dart';
import 'package:untitled1/ui/login_screen/login_screen.dart';

class OnboardingItem {
  final String title;
  final String subTitle;
  final String image;

  OnboardingItem({
    required this.title,
    required this.subTitle,
    required this.image,
  });
}

class OnboardingScreen extends StatefulWidget {
  static const String routeName = 'onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'we PLAN ,\nyou MOVE..\nShare your\njourney.',
      subTitle: 'Explore, Connect, and Create Memories\nwith your fellow travelers.',
      image: 'assets/images/onboarding.png',
    ),
    OnboardingItem(
      title: 'Discover\nNew Places\nEvery Day.',
      subTitle: 'Find the best destinations and hidden gems\nrecommended by experts.',
      image: 'assets/images/photo_travel.webp',
    ),
    OnboardingItem(
      title: 'Your Travel\nCompanion\nEverywhere.',
      subTitle: 'Stay organized and make the most\nof every trip you take.',
      image: 'assets/images/onboarding.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F4),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, top: 40.0, right: 30.0),
                        child: Text(
                          _items[index].title,
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3E4E35),
                            height: 1.1,
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
                              image: DecorationImage(
                                image: AssetImage(_items[index].image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
                  Text(
                    _currentIndex == 0 ? 'Welcome to Travel Me' : 'Travel with Ease',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B2612)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _items[_currentIndex].subTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF5A6650), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentIndex == index ? 25 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? const Color(0xFF3E4E35) : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
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
                        if (_currentIndex == _items.length - 1) {
                          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentIndex == _items.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
