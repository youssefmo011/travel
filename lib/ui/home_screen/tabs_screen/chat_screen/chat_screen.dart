import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled1/core/assets/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'chat_details_screen.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = 'chat';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final user = FirebaseAuth.instance.currentUser;

  String _getChatId(String id1, String id2) {
    return id1.hashCode <= id2.hashCode ? '${id1}_$id2' : '${id2}_$id1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: _buildAppBar(context),
      extendBody: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ActiveNowSection(),
                const _SearchBar(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('MESSAGES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                _buildUnifiedChatsList(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          _buildFloatingBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildUnifiedChatsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }
        
        final allUsers = userSnapshot.data?.docs.where((doc) => doc.id != user?.uid).toList() ?? [];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('users', arrayContains: user?.uid)
              .snapshots(),
          builder: (context, chatSnapshot) {
            List<Map<String, dynamic>> combinedList = [];

            for (var userDoc in allUsers) {
              final userData = userDoc.data() as Map<String, dynamic>;
              final userId = userDoc.id;
              String chatId = _getChatId(user?.uid ?? '', userId);

              QueryDocumentSnapshot? chatDoc;
              try {
                chatDoc = chatSnapshot.data?.docs.firstWhere(
                  (doc) => doc.id == chatId,
                );
              } catch (_) {
                chatDoc = null;
              }

              combinedList.add({
                'uid': userId,
                'name': userData['name'] ?? 'Traveler',
                'imageUrl': userData['profileImage'],
                'lastMessage': chatDoc != null ? (chatDoc.data() as Map<String, dynamic>)['lastMessage'] : 'Tap to chat',
                'lastTimestamp': chatDoc != null ? (chatDoc.data() as Map<String, dynamic>)['lastTimestamp'] : null,
                'lastSenderId': chatDoc != null ? (chatDoc.data() as Map<String, dynamic>)['lastSenderId'] : null,
              });
            }

            combinedList.sort((a, b) {
              if (a['lastTimestamp'] == null && b['lastTimestamp'] == null) return 0;
              if (a['lastTimestamp'] == null) return 1;
              if (b['lastTimestamp'] == null) return -1;
              return (b['lastTimestamp'] as Timestamp).compareTo(a['lastTimestamp'] as Timestamp);
            });

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: combinedList.length,
              itemBuilder: (context, index) {
                final item = combinedList[index];
                String time = '';
                if (item['lastTimestamp'] != null) {
                  time = DateFormat('hh:mm a').format((item['lastTimestamp'] as Timestamp).toDate());
                }

                return _MessageItem(
                  uid: item['uid'],
                  name: item['name'],
                  imageUrl: item['imageUrl'],
                  lastMsg: item['lastMessage'],
                  time: time,
                  isUnread: item['lastSenderId'] != user?.uid && item['lastTimestamp'] != null,
                );
              },
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text('Community', style: TextStyle(color: Color(0xFF1B2612), fontSize: 22, fontWeight: FontWeight.w900)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
            builder: (context, snapshot) {
              String? img;
              if (snapshot.hasData && snapshot.data!.exists) {
                img = (snapshot.data!.data() as Map<String, dynamic>)['profileImage'];
              }
              return CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE8F0E8),
                backgroundImage: (img != null && img.toString().startsWith('http')) 
                    ? NetworkImage(img!)
                    : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBottomNavBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30, left: 30, right: 30),
        height: 65,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
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
    return GestureDetector(
      onTap: () => Navigator.pop(context, index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [SvgPicture.asset(icon, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn), height: 22), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10))]),
    );
  }
}

class _ActiveNowSection extends StatelessWidget {
  const _ActiveNowSection();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('ACTIVE NOW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        SizedBox(
          height: 100,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final users = snapshot.data!.docs.where((doc) => doc.id != FirebaseAuth.instance.currentUser?.uid).toList();
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final userData = users[index].data() as Map<String, dynamic>;
                  return Column(children: [
                    CircleAvatar(
                      radius: 30, 
                      backgroundColor: const Color(0xFFE8F0E8), 
                      backgroundImage: (userData['profileImage'] != null && userData['profileImage'].toString().startsWith('http')) 
                          ? NetworkImage(userData['profileImage']) 
                          : const AssetImage(AppAssets.storyPhoto) as ImageProvider
                    ),
                    const SizedBox(height: 5),
                    Text(userData['name']?.split(' ')[0] ?? 'User', style: const TextStyle(fontSize: 12))
                  ]);
                },
              );
            }
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(20.0), child: Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.1))), child: const TextField(decoration: InputDecoration(icon: Icon(Icons.search, color: Colors.grey), hintText: 'Search travelers...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none))));
  }
}

class _MessageItem extends StatelessWidget {
  final String uid;
  final String name;
  final String? imageUrl;
  final String lastMsg;
  final String time;
  final bool isUnread;

  const _MessageItem({required this.uid, required this.name, this.imageUrl, required this.lastMsg, required this.time, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFE8F0E8),
            backgroundImage: (imageUrl != null && imageUrl!.startsWith('http')) 
                ? NetworkImage(imageUrl!) 
                : const AssetImage(AppAssets.storyPhoto) as ImageProvider,
          ),
          if (isUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(color: const Color(0xFF6D8B6D), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              ),
            ),
        ],
      ),
      title: Text(name, style: TextStyle(fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold, color: const Color(0xFF1B2612))),
      subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isUnread ? Colors.black87 : Colors.grey, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
      trailing: Text(time, style: TextStyle(fontSize: 10, color: isUnread ? const Color(0xFF6D8B6D) : Colors.grey)),
      onTap: () {
        Navigator.pushNamed(context, ChatDetailsScreen.routeName, arguments: {'uid': uid, 'name': name, 'imageUrl': imageUrl});
      },
    );
  }
}
