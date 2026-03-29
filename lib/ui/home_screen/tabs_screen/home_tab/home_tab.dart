import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/core/assets/app_assets.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/chat_screen/chat_screen.dart';
import 'widgets/featured_vibe_card.dart';
import 'widgets/story_view_screen.dart';

class HomeTab extends StatefulWidget {
  final Function(int)? onTabChanged;
  const HomeTab({super.key, this.onTabChanged});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final String _cloudName = "drz07cb7a"; 
  final String _uploadPreset = "travel";
  bool _isUploadingStory = false;

  @override
  void initState() {
    super.initState();
    _checkAndCleanupStory(); 
  }

  Future<void> _checkAndCleanupStory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('storyTimestamp')) {
          final Timestamp? timestamp = data['storyTimestamp'];
          if (timestamp != null) {
            final DateTime storyTime = timestamp.toDate();
            final difference = DateTime.now().difference(storyTime).inHours;
            if (difference >= 12) {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'userStories': FieldValue.delete(),
                'storyTimestamp': FieldValue.delete(),
                'viewedBy': FieldValue.delete(),
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Cleanup error: $e");
    }
  }

  Future<void> _pickAndUploadStory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (image == null) return;

      setState(() => _isUploadingStory = true);

      var request = http.MultipartRequest('POST', Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'));
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        String imageUrl = jsonDecode(responseData)['secure_url'];

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userStories': FieldValue.arrayUnion([imageUrl]),
          'storyTimestamp': FieldValue.serverTimestamp(),
          'viewedBy': [],
        }, SetOptions(merge: true));

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story updated!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingStory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String userName = "Traveler";
          String? profileImageUrl;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['name'] ?? "Traveler";
            profileImageUrl = data['profileImage'];
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CustomAppBar(onTabChanged: widget.onTabChanged, profileImageUrl: profileImageUrl),
                _UserInfoHeader(userName: userName, imageUrl: profileImageUrl),
                _RecentStoriesSection(onAddStory: _pickAndUploadStory, isUploading: _isUploadingStory),
                const _FeaturedVibeSection(),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecentStoriesSection extends StatelessWidget {
  final VoidCallback onAddStory;
  final bool isUploading;
  const _RecentStoriesSection({required this.onAddStory, required this.isUploading});

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('RECENT STORIES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B2612))),
        ),
        SizedBox(
          height: 110,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text("Error"));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              // الفلترة: نعرض الحالي دائماً + الباقي اللي عندهم ستوريز فقط
              final usersDocs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final hasStory = data.containsKey('userStories') && (data['userStories'] is List) && (data['userStories'] as List).isNotEmpty;
                return doc.id == currentUserUid || hasStory;
              }).toList();
              
              // الترتيب: أنت أولاً، ثم الباقي بالأحدث
              usersDocs.sort((a, b) {
                if (a.id == currentUserUid) return -1;
                if (b.id == currentUserUid) return 1;
                final aTime = (a.data() as Map<String, dynamic>)['storyTimestamp'] as Timestamp?;
                final bTime = (b.data() as Map<String, dynamic>)['storyTimestamp'] as Timestamp?;
                if (aTime != null && bTime != null) return bTime.compareTo(aTime);
                return 0;
              });

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: usersDocs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  final userData = usersDocs[index].data() as Map<String, dynamic>;
                  final String userId = usersDocs[index].id;
                  final String? profileImg = userData['profileImage'];
                  final List<dynamic> stories = userData['userStories'] ?? [];
                  final List<dynamic> viewedBy = userData['viewedBy'] ?? [];
                  
                  final bool isMe = userId == currentUserUid;
                  final bool hasUnseenStory = stories.isNotEmpty && !viewedBy.contains(currentUserUid);

                  return Column(children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (stories.isNotEmpty) {
                              if (!isMe && !viewedBy.contains(currentUserUid)) {
                                FirebaseFirestore.instance.collection('users').doc(userId).set({
                                  'viewedBy': FieldValue.arrayUnion([currentUserUid])
                                }, SetOptions(merge: true));
                              }
                              Navigator.push(context, MaterialPageRoute(builder: (context) => StoryViewScreen(
                                imageUrls: stories, 
                                userName: userData['name'] ?? "User", 
                                userId: userId,
                                userProfileImage: profileImg,
                              )));
                            } else if (isMe) {
                              onAddStory();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: hasUnseenStory 
                                  ? [const Color(0xFFC4D4A4), const Color(0xFF6D8B6D)] 
                                  : [Colors.grey.shade300, Colors.grey.shade300],
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFFE8F0E8),
                                backgroundImage: (profileImg != null && profileImg.startsWith('http')) 
                                    ? NetworkImage(profileImg) 
                                    : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                        if (isMe)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: GestureDetector(
                              onTap: onAddStory,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Color(0xFF6D8B6D),
                                  child: Icon(Icons.add, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        if (isMe && isUploading)
                          const Positioned.fill(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(isMe ? "Your Story" : (userData['name']?.split(' ')[0] ?? "User"), 
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: hasUnseenStory ? FontWeight.bold : FontWeight.normal,
                        color: hasUnseenStory ? const Color(0xFF1B2612) : Colors.grey,
                      )
                    ),
                  ]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final Function(int)? onTabChanged;
  final String? profileImageUrl;
  const _CustomAppBar({this.onTabChanged, this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconBtn(Icons.camera_alt_outlined),
          Row(
            children: [
              _buildIconBtn(Icons.chat_bubble_outline, onTap: () => Navigator.pushNamed(context, ChatScreen.routeName)),
              const SizedBox(width: 10),
              _buildIconBtn(Icons.settings_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF6D8B6D), size: 20),
      ),
    );
  }
}

class _UserInfoHeader extends StatelessWidget {
  final String userName;
  final String? imageUrl;
  const _UserInfoHeader({required this.userName, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE8F0E8),
            backgroundImage: (imageUrl != null && imageUrl!.startsWith('http')) ? NetworkImage(imageUrl!) : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hi, $userName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B2612))),
              const SizedBox(height: 5),
              Row(children: [
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: 0.88, backgroundColor: Color(0xFFF0F0F0), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6D8B6D)), minHeight: 6))),
                const SizedBox(width: 10),
                const Text('WANDERLUST: 88%', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}

class _FeaturedVibeSection extends StatelessWidget {
  const _FeaturedVibeSection();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Featured Vibe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B2612))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(20)), child: const Text('Trending Today', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold))),
        ])),
        const SizedBox(height: 20),
        SizedBox(height: 400, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 20), scrollDirection: Axis.horizontal, itemCount: 3, separatorBuilder: (context, index) => const SizedBox(width: 20), itemBuilder: (context, index) => const FeaturedVibeCard(title: 'The Urban Explorer', location: 'Tokyo, Japan', imagePath: AppAssets.photoTravel))),
      ]),
    );
  }
}
