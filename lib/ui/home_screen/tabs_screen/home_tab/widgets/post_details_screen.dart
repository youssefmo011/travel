import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/core/assets/app_assets.dart';

class PostDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;

  const PostDetailsScreen({super.key, required this.postData, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool isLiked = false;
  String? currentUserProfileImg;
  String? currentUserName;

  @override
  void initState() {
    super.initState();
    _checkLikeStatus();
    _fetchCurrentUserInfo();
  }

  void _checkLikeStatus() {
    if (user == null) return;
    final dynamic likesData = widget.postData['likes'];
    if (likesData is List) {
      setState(() => isLiked = likesData.contains(user!.uid));
    }
  }

  void _fetchCurrentUserInfo() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists && mounted) {
      setState(() {
        currentUserProfileImg = doc.data()?['profileImage'];
        currentUserName = doc.data()?['name'];
      });
    }
  }

  void _toggleLike() async {
    if (user == null) return;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    
    if (isLiked) {
      await postRef.update({'likes': FieldValue.arrayRemove([user!.uid])});
      setState(() => isLiked = false);
    } else {
      await postRef.update({'likes': FieldValue.arrayUnion([user!.uid])});
      setState(() => isLiked = true);
      
      if (user!.uid != widget.postData['userId']) {
        _sendNotification(
          body: "liked your experience.", 
          type: "like"
        );
      }
    }
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty || user == null) return;
    final String commentText = _commentController.text.trim();
    
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final userData = userDoc.data();
    final String uName = userData?['name'] ?? currentUserName ?? "Explorer";
    final String? uImage = userData?['profileImage'] ?? currentUserProfileImg;

    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
      'userId': user!.uid,
      'userName': uName,
      'userImage': uImage,
      'text': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (user!.uid != widget.postData['userId']) {
      _sendNotification(
        body: "commented: $commentText", 
        type: "comment",
        sName: uName,
        sImage: uImage
      );
    }
    
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _sendNotification({required String body, required String type, String? sName, String? sImage}) async {
    final String? receiverId = widget.postData['userId'];
    if (receiverId == null || user == null) return;

    final String finalName = sName ?? currentUserName ?? user!.displayName ?? "Explorer";
    final String? finalImage = sImage ?? currentUserProfileImg ?? user!.photoURL;

    await FirebaseFirestore.instance.collection('notifications').add({
      'receiverId': receiverId,
      'senderId': user!.uid,
      'senderName': finalName,
      'senderImage': finalImage,
      'title': finalName, 
      'body': body,
      'type': type,
      'postId': widget.postId,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                  child: Image.network(
                    widget.postData['imageUrl'] ?? '',
                    height: 450, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 450, color: Colors.grey.shade200),
                  ),
                ),
                Positioned(
                  top: 50, left: 20,
                  child: IconButton(
                    icon: CircleAvatar(backgroundColor: Colors.black.withValues(alpha: 0.3), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 50, right: 20,
                  child: IconButton(
                    icon: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      child: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white, size: 22),
                    ),
                    onPressed: _toggleLike,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.postData['userName'] ?? "Experience", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("${widget.postData['location'] ?? 'Global'} • 12km away", style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 30),
                  const Text("What people are saying", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildCommentList(),
                  const SizedBox(height: 20),
                  _buildCommentInput(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final comments = snapshot.data!.docs;
        if (comments.isEmpty) {
          return const Center(
              child: Text("No comments yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 12)));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment =
                comments[index].data() as Map<String, dynamic>;
            final String? cUserImg = comment['userImage'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFE8F0E8),
                    backgroundImage: (cUserImg != null &&
                            cUserImg.startsWith('http'))
                        ? NetworkImage(cUserImg)
                        : const AssetImage(AppAssets.profilePhoto)
                            as ImageProvider,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(comment['text'] ?? "",
                              style: const TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment['userName'] ?? "EXPLORER",
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommentInput() {
    return Row(children: [
      CircleAvatar(radius: 18, backgroundColor: const Color(0xFFE8F0E8), backgroundImage: (currentUserProfileImg != null && currentUserProfileImg!.startsWith('http')) ? NetworkImage(currentUserProfileImg!) : const AssetImage(AppAssets.profilePhoto) as ImageProvider),
      const SizedBox(width: 12),
      Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(30)), child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: "Add a comment...", border: InputBorder.none)))),
      const SizedBox(width: 8),
      IconButton(icon: const Icon(Icons.send_rounded, color: Color(0xFF6D8B6D)), onPressed: _addComment),
    ]);
  }
}
