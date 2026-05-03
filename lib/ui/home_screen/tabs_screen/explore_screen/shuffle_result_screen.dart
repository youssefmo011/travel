import 'dart:ui';
import 'package:flutter/material.dart';

class ShuffleResultScreen extends StatelessWidget {
  static const String routeName = '/shuffle-result';

  const ShuffleResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 10),
              _buildContentCard(context),
              const SizedBox(height: 20),
              _buildStatusBar(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                child: const Icon(Icons.flash_on, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text("Travel Me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ADVENTURE GENERATOR",
            style: TextStyle(
              color: Color(0xFF6B8E6B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Shuffle Result",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B2612)),
          ),
          const SizedBox(height: 30),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Surprise\nAdventure is\nReady!",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "TODAY'S VIBE: SOCIAL\nCATALYST",
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildBadge("+1 Streak!", const Color(0xFFFF7043)),
                  const SizedBox(height: 8),
                  const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 24),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 25),
          
          // Image Card
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  "https://images.unsplash.com/photo-1540959733332-e94e270b2d42?q=80&w=1000",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DESTINATION", style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Omoide Yokocho,", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("1.2 km away", style: TextStyle(color: Color(0xFF6B8E6B), fontWeight: FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                          Text("Tokyo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          
          const SizedBox(height: 25),
          
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              const Text("Why this challenge?", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Based on your Quiz, you usually prefer quiet spots. This social street-food hunt will boost your \"Social Energy\" by 30%.",
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          
          const SizedBox(height: 35),
          
          // Main Button: "I'm In! Add to My Journey"
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Adventure Saved to Memory Lane!"),
                  backgroundColor: Color(0xFF6B8E6B),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB4B48E), // اللون الزيتوني الفاتح
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "I'm In! Add to My Journey",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
          
          const SizedBox(height: 15),
          
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
              label: const Text(
                "Not feeling it? Shuffle again! (1/3 left)",
                style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.underline),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CURRENT PROGRESS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              SizedBox(height: 4),
              Text("Explorer Level 14", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B2612))),
            ],
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFF6B8E6B), shape: BoxShape.circle),
                  child: const Text("+42", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
