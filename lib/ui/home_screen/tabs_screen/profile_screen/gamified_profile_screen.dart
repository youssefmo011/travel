import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:untitled1/core/assets/app_assets.dart';
import 'package:untitled1/core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, user),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          
          final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          final String userName = userData['name'] ?? "Traveler";
          final String? profileImageUrl = userData['profileImage'];
          final int streakCount = userData['streak'] ?? 12;
          final List<dynamic> badgesList = userData['badges'] ?? [];
          final int challengeXp = userData['challengeXp'] ?? 0;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('userId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, postsSnapshot) {
              final userPosts = postsSnapshot.data?.docs ?? [];
              final int placesCount = userPosts.length;
              final int totalXp = (placesCount * 1500) + challengeXp;
              final int level = (totalXp / 3000).floor() + 1;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildProfileHeader(userName, profileImageUrl, level),
                    const SizedBox(height: 30),
                    _buildStreakCard(streakCount),
                    const SizedBox(height: 25),
                    _buildStatsCard(placesCount.toString(), totalXp.toString(), badgesList.length.toString()),
                    const SizedBox(height: 35),
                    _buildBadgesSection(badgesList),
                    const SizedBox(height: 35),
                    _buildExperienceListSection(context, userPosts),
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

  PreferredSizeWidget _buildAppBar(BuildContext context, User? user) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SvgPicture.asset(
          AppAssets.streakIcon,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
      ),
      actions: [
        _buildNotificationIcon(user),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textMain, size: 24),
          onPressed: () => Navigator.pushNamed(context, ProfileScreen.routeName),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  Widget _buildNotificationIcon(User? user) {
    return StreamBuilder<QuerySnapshot>(
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
                child: Icon(Icons.notifications_outlined, color: AppColors.textMain, size: 24),
              ),
              if (hasUnread)
                Positioned(
                  right: 12, top: 12,
                  child: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                  ),
                )
            ],
          ),
        );
      }
    );
  }

  Widget _buildProfileHeader(String name, String? imageUrl, int level) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surface,
            backgroundImage: (imageUrl != null && imageUrl.startsWith('http'))
                ? NetworkImage(imageUrl)
                : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
          ),
        ),
        const SizedBox(height: 15),
        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
          child: Text("Level $level Explorer", style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 30),
              const SizedBox(width: 10),
              Text("$streak Days Streak!", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              bool isDone = day != 'S'; // مجرد مثال للتوضيح
              return Column(
                children: [
                  Text(day, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? Colors.white : Colors.white24, size: 18),
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.surface),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.location_on_outlined, places, "PLACES"),
          _statItem(Icons.bolt, xp, "TOTAL XP"),
          _statItem(Icons.emoji_events_outlined, badges, "BADGES"),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textGrey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBadgesSection(List<dynamic> badges) {
    // Badge icon mapping — matches what the AI returns in badge_icon field
    const Map<String, IconData> iconMap = {
      'psychology':            Icons.psychology,
      'emoji_events':          Icons.emoji_events,
      'local_fire_department': Icons.local_fire_department,
      'explore':               Icons.explore,
      'self_improvement':      Icons.self_improvement,
      'directions_walk':       Icons.directions_walk,
      'restaurant':            Icons.restaurant,
      'nightlife':             Icons.nightlife,
      'forest':                Icons.forest,
      'museum':                Icons.museum,
      'camera_alt':            Icons.camera_alt,
      'hiking':                Icons.hiking,
      'wb_sunny':              Icons.wb_sunny,
      'people':                Icons.people,
      'bolt':                  Icons.bolt,
      // legacy / static badges
      'DNA Discovered':        Icons.biotech,
      'Comfort Zone Breaker':  Icons.psychology,
    };

    // Build display list — each badge is just a string (the name)
    final List<String> badgeNames = badges
        .map((b) => b.toString())
        .toSet() // deduplicate
        .toList();

    // Pick an icon for a badge name: try exact key match, then fallback
    IconData _iconFor(String name) {
      if (iconMap.containsKey(name)) return iconMap[name]!;
      // keyword scan
      final lower = name.toLowerCase();
      if (lower.contains('food') || lower.contains('street')) return Icons.restaurant;
      if (lower.contains('walk') || lower.contains('wander')) return Icons.directions_walk;
      if (lower.contains('fire') || lower.contains('breaker')) return Icons.local_fire_department;
      if (lower.contains('silent') || lower.contains('mind')) return Icons.self_improvement;
      if (lower.contains('pioneer') || lower.contains('urban')) return Icons.explore;
      if (lower.contains('hero') || lower.contains('people')) return Icons.people;
      if (lower.contains('nature') || lower.contains('forest')) return Icons.forest;
      if (lower.contains('dna') || lower.contains('discover')) return Icons.biotech;
      return Icons.emoji_events;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("DNA Milestones",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain)),
              Text("${badgeNames.length} earned",
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 15),
        if (badgeNames.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text("Complete challenges to earn badges!",
                style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: badgeNames.asMap().entries.map((entry) {
                final bool isFirst = entry.key == 0;
                return _badgeItem(_iconFor(entry.value), entry.value, isFirst);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _badgeItem(IconData icon, String label, bool isSpecial) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: isSpecial
                  ? const LinearGradient(
                      colors: [Color(0xFFEAB308), Color(0xFFF97316)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSpecial ? null : AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: isSpecial
                  ? [BoxShadow(
                      color: const Color(0xFFEAB308).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )]
                  : null,
            ),
            child: Icon(icon,
                color: isSpecial ? Colors.white : AppColors.primary, size: 25),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSpecial ? AppColors.primaryDark : AppColors.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceListSection(BuildContext context, List<QueryDocumentSnapshot> posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text("Journey Highlights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
        ),
        const SizedBox(height: 15),
        if (posts.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("No memories yet.", style: TextStyle(color: AppColors.textGrey))))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;
              return _experienceItem(context, post, posts[index].id);
            },
          ),
      ],
    );
  }

  Widget _experienceItem(BuildContext context, Map<String, dynamic> post, String id) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailsScreen(postData: post, postId: id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(imageUrl: post['imageUrl'], width: 70, height: 70, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['location'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  const Text("1500 XP Earned", style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
