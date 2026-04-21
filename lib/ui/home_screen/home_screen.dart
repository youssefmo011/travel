import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untitled1/core/assets/app_assets.dart';
import 'tabs_screen/chat_screen/chat_screen.dart';
import 'tabs_screen/explore_screen/explore_screen.dart';
import 'tabs_screen/home_tab/home_tab.dart';
import 'tabs_screen/profile_screen/profile_screen.dart';
import 'tabs_screen/quiz_screen/quiz_screen.dart';
import 'tabs_screen/trip_screen/trip_screen.dart';

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
       ExploreScreen(),
      const TripScreen(),
      const QuizScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          tabs[selectedIndex >= tabs.length ? 0 : selectedIndex],
          _buildFloatingBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNavBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30, left: 30, right: 30),
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    Color color = isSelected ? const Color(0xFF6D8B6D) : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => _onTabChanged(index),
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
