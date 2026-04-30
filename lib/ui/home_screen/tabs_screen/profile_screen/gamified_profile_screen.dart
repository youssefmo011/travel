import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:untitled1/core/assets/app_assets.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/profile_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/whats_new_screen.dart';
import '../home_tab/widgets/post_details_screen.dart';

class GamifiedProfileScreen extends StatelessWidget {
  static const String routeName = 'gamified-profile';

  const GamifiedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SvgPicture.asset(
            AppAssets.streakIcon,
            colorFilter: const ColorFilter.mode(Color(0xFF6D8B6D), BlendMode.srcIn),
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('receiverId', isEqualTo: user?.uid)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              bool hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, WhatsNewScreen.routeName),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.notifications_outlined, color: Colors.black, size: 26),
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      )
                  ],
                ),
              );
            }
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 26),
            onPressed: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF6D8B6D)));
          
          final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          final String userName = userData['name'] ?? "Traveler";
          final String? profileImageUrl = userData['profileImage'];
          final int streakCount = userData['streak'] ?? 12;
          final List<dynamic> badgesList = userData['badges'] ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('userId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, postsSnapshot) {
              final userPosts = postsSnapshot.data?.docs ?? [];
              
              // ترتيب يدوي للأحدث لضمان استقرار العرض
              final sortedPosts = List.from(userPosts);
              sortedPosts.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                Timestamp? tA = aData['timestamp'];
                Timestamp? tB = bData['timestamp'];
                if (tA == null) return 1;
                if (tB == null) return -1;
                return tB.compareTo(tA);
              });

              final int placesCount = sortedPosts.length;
              final int totalXp = placesCount * 1500;
              final int level = (totalXp / 3000).floor() + 1;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildProfileHeader(userName, profileImageUrl, level),
                    const SizedBox(height: 25),
                    _buildStreakCard(streakCount),
                    const SizedBox(height: 25),
                    _buildStatsCard(placesCount.toString(), totalXp.toString(), badgesList.length.toString()),
                    const SizedBox(height: 35),
                    _buildBadgesCirclesSection(),
                    const SizedBox(height: 35),
                    _buildExperienceListSection(context, sortedPosts),
                    const SizedBox(height: 120),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String? imageUrl, int level) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15)]
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFE8F0E8),
                backgroundImage: (imageUrl != null && imageUrl.startsWith('http'))
                    ? NetworkImage(imageUrl)
                    : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF6D8B6D),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1B2612))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFF2F5ED), borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.military_tech, color: Color(0xFF6D8B6D), size: 14),
              const SizedBox(width: 4),
              Text("Level $level Explorer", style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF6D8B6D),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: const Color(0xFF6D8B6D).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 35),
          ),
          const SizedBox(height: 15),
          const Text("12 Days Streak!", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const Text("TREASURE WALKS COMPLETED", style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              bool isDone = day != 'S';
              return Column(
                children: [
                  Text(day, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isDone ? Colors.white : Colors.white24,
                    size: 22,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String places, String xp, String badges) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.location_on_outlined, places, "PLACES"),
          _buildStatItem(Icons.bolt, xp, "TOTAL XP"),
          _buildStatItem(Icons.emoji_events_outlined, badges, "BADGES"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black87, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildBadgesCirclesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Unlocked Badges", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B2612))),
              Text("View All", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBadgeCircle(Icons.search, "Hidden Gem\nFinder"),
            _buildBadgeCircle(Icons.explore_outlined, "Early Bird\nWalker"),
            _buildBadgeCircle(Icons.bolt, "Shutter\nMaster"),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeCircle(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFF2F5ED), shape: BoxShape.circle, border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
          child: Icon(icon, color: Colors.black, size: 28),
        ),
        const SizedBox(height: 10),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, height: 1.2)),
      ],
    );
  }

  Widget _buildExperienceListSection(BuildContext context, List<dynamic> posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Unlocked Badges", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B2612))),
              Text("View All", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (posts.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No posts found.")))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postDoc = posts[index];
              final post = postDoc.data() as Map<String, dynamic>;
              return _buildExperienceListItem(context, post, postDoc.id);
            },
          ),
      ],
    );
  }

  Widget _buildExperienceListItem(BuildContext context, Map<String, dynamic> post, String id) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailsScreen(postData: post, postId: id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4EE), // اللون الرمادي المخضر الفاتح من الصورة
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: post['imageUrl'],
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator(strokeWidth: 1))),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['location'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1B2612))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text("1 PLACES", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 20),
                      const Icon(Icons.bolt, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text("1500", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w900)),
                    ],
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
