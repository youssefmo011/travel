import 'package:flutter/material.dart';
import 'package:untitled1/core/assets/app_assets.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/trip_screen/treasure_walk_screen.dart';

class TripScreen extends StatefulWidget {
  static const String routeName = 'trip';

  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  bool isPastJourneys = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map, color: Colors.white, size: 18),
          ),
        ),
        title: const Text(
          'Travel Me',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isPastJourneys = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isPastJourneys ? Colors.white : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: isPastJourneys
                                  ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                                  : [],
                              border: isPastJourneys ? Border.all(color: Colors.grey.shade100) : null,
                            ),
                            child: Text(
                              'Past Journeys',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: isPastJourneys ? FontWeight.bold : FontWeight.normal,
                                color: isPastJourneys ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isPastJourneys = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isPastJourneys ? Colors.white : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: !isPastJourneys
                                  ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                                  : [],
                              border: !isPastJourneys ? Border.all(color: Colors.grey.shade100) : null,
                            ),
                            child: Text(
                              'Upcoming',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: !isPastJourneys ? FontWeight.bold : FontWeight.normal,
                                color: !isPastJourneys ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text('Memory Lane', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Relive your favorite moments and stories.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 30),
                  if (isPastJourneys)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            _buildTimelinePoint(true),
                            _buildTimelineLine(160),
                            _buildTimelinePoint(true),
                            _buildTimelineLine(160),
                            _buildTimelinePoint(false, isSmall: true),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              _buildTripCard(
                                image: AppAssets.photoTravel, // Ensure this asset exists
                                date: 'OCT 12',
                                title: 'Autumn in Kyoto',
                                subtitle: 'Ancient temples and',
                                mood: 'Inspired',
                                moodIcon: Icons.camera_alt,
                              ),
                              const SizedBox(height: 25),
                              _buildTripCard(
                                image: AppAssets.storyPhoto, // Ensure this asset exists
                                date: 'AUG 05',
                                title: 'Bali Retreat',
                                subtitle: 'Morning yoga and vibrant',
                                mood: 'Radiant',
                                moodIcon: Icons.wb_sunny_outlined,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Text('No upcoming journeys yet.', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                // الكود ده هو اللي بيفتح صفحة الكنز
                Navigator.pushNamed(context, TreasureWalkScreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D8B6D),
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                elevation: 0,
              ),
              child: const Text(
                'TREASURE WALK',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelinePoint(bool isActive, {bool isSmall = false}) {
    return Container(
      width: isSmall ? 10 : 28,
      height: isSmall ? 10 : 28,
      decoration: BoxDecoration(color: isActive ? const Color(0xFF6D8B6D) : Colors.grey.shade300, shape: BoxShape.circle),
      child: isActive && !isSmall ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }

  Widget _buildTimelineLine(double height) {
    return Container(width: 2, height: height, color: Colors.grey.shade100, margin: const EdgeInsets.symmetric(vertical: 4));
  }

  Widget _buildTripCard({required String image, required String date, required String title, required String subtitle, required String mood, required IconData moodIcon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.asset(image, width: 70, height: 70, fit: BoxFit.cover)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: const Text('COMPLETED', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFF6D8B6D).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(moodIcon, size: 16, color: const Color(0xFF6D8B6D)),
                    ),
                    const SizedBox(width: 10),
                    Text(mood, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}