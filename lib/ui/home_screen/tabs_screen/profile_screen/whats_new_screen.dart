import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:untitled1/core/assets/app_assets.dart';

class WhatsNewScreen extends StatefulWidget {
  static const String routeName = 'whats-new';

  const WhatsNewScreen({super.key});

  @override
  State<WhatsNewScreen> createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends State<WhatsNewScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _markAllAsRead();
  }

  void _markAllAsRead() async {
    if (user == null) return;
    try {
      final unreadDocs = await FirebaseFirestore.instance
          .collection('notifications')
          .where('receiverId', isEqualTo: user!.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadDocs.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('receiverId', isEqualTo: user?.uid)
              .where('isRead', isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            int unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return Column(
              children: [
                const Text('What\'s New', style: TextStyle(color: Color(0xFF1B2612), fontWeight: FontWeight.w900, fontSize: 20)),
                Text(
                  unreadCount > 0 ? '$unreadCount NEW NOTIFICATIONS' : 'YOU\'RE ALL CAUGHT UP',
                  style: TextStyle(
                    color: unreadCount > 0 ? Colors.redAccent : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            );
          }
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6D8B6D)));
          }

          var notifications = snapshot.data?.docs ?? [];
          
          notifications.sort((a, b) {
            Timestamp? tA = (a.data() as Map<String, dynamic>)['timestamp'];
            Timestamp? tB = (b.data() as Map<String, dynamic>)['timestamp'];
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tB.compareTo(tA);
          });

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemCount: notifications.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildSectionHeader('PRIORITY'),
                    _buildPriorityNotification(user?.uid),
                    const SizedBox(height: 30),
                    _buildSectionHeader('RECENT'),
                  ],
                );
              }

              final notification = notifications[index - 1].data() as Map<String, dynamic>;
              return _buildDynamicNotificationItem(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle, 
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: const Icon(Icons.notifications_none, color: Colors.grey, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('No updates yet', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('Check back later for likes and comments!', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildPriorityNotification(String? uid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4EE),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 20),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Streak Alert!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 5),
                Text(
                  'Your 12-day streak is looking great! Share a new experience today.',
                  style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicNotificationItem(Map<String, dynamic> data) {
    String time = '';
    if (data['timestamp'] != null) {
      time = DateFormat('hh:mm a').format((data['timestamp'] as Timestamp).toDate());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24, 
            backgroundColor: const Color(0xFFE8F0E8),
            backgroundImage: (data['senderImage'] != null && data['senderImage'].startsWith('http')) 
              ? NetworkImage(data['senderImage']) 
              : const AssetImage(AppAssets.profilePhoto) as ImageProvider
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['title'] ?? 'New Interaction', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(data['body'] ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
