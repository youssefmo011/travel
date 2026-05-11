import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/assets/app_assets.dart';

class ShuffleResultScreen extends StatelessWidget {
  static const String routeName = '/shuffle-result';

  const ShuffleResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildContentCard(context),
                    const SizedBox(height: 20),
                    _buildStatusBar(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3E2D)),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                child: const Icon(Icons.flash_on, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text("Travel Me", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFEAB308))),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF2D3E2D)),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ADVENTURE GENERATOR",
            style: TextStyle(color: Color(0xFF769676), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          const Text(
            "Shuffle Result",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D)),
          ),
          const SizedBox(height: 25),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Surprise\nAdventure is\nReady!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2, color: Color(0xFF2D3E2D)),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "TODAY'S VIBE: SOCIAL\nCATALYST",
                    style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(10)),
                    child: const Text("+1 Streak!", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 24),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 25),
          
          // Image with Destination Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  AppAssets.tokyo,
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
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.black.withOpacity(0.3),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DESTINATION", style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Omoide Yokocho,", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text("1.2 km away", style: TextStyle(color: Color(0xFF8BA68B), fontWeight: FontWeight.bold, fontSize: 10)),
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
              const Text("Why this challenge?", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Based on your Quiz, you usually prefer quiet spots. This social street-food hunt will boost your \"Social Energy\" by 30%.",
            style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.5),
          ),
          
          const SizedBox(height: 30),
          
          // Main Button
          ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8BA68B),
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
          
          const Center(
            child: Text(
              "Not feeling it? Shuffle again! (1/3 left)",
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, decoration: TextDecoration.underline),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CURRENT PROGRESS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5)),
              SizedBox(height: 4),
              Text("Explorer Level 14", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3E2D))),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            height: 35,
            child: Stack(
              children: [
                Positioned(left: 0, child: _buildAvatar(Colors.grey.shade300)),
                Positioned(left: 20, child: _buildAvatar(Colors.grey.shade400)),
                Positioned(left: 40, child: Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: Color(0xFF769676), shape: BoxShape.circle),
                  child: const Center(child: Text("+42", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAvatar(Color color) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: const Icon(Icons.person, size: 18, color: Colors.white),
    );
  }
}
