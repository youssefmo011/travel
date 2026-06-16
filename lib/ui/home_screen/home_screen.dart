import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untitled1/core/assets/app_assets.dart';
import 'tabs_screen/explore_screen/explore_screen.dart';
import 'tabs_screen/home_tab/home_tab.dart';
import 'tabs_screen/quiz_screen/quiz_screen.dart';
import 'tabs_screen/trip_screen/trip_screen.dart';
import 'tabs_screen/profile_screen/gamified_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      HomeTab(onTabChanged: _onTabChanged),
      const ExploreScreen(),
      const TripScreen(),
      const QuizScreen(),
      const GamifiedProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: selectedIndex,
            children: tabs,
          ),
          _buildFloatingBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNavBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(AppAssets.homeIcon, 'Home', 0),
            _buildNavItem(AppAssets.exploreIcon, 'Explore', 1),
            _buildNavItem(AppAssets.tripIcon, 'Trip', 2),
            _buildNavItem(AppAssets.quizIcon, 'Quiz', 3),
            _buildNavItem(AppAssets.profileIcon, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    Color color = isSelected ? const Color(0xFF6D8B6D) : const Color(0xFF9E9E9E);

    return GestureDetector(
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              height: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
