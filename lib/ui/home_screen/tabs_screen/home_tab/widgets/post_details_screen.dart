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
          title: currentUserName ?? "Someone", 
          body: "liked your experience.", 
          type: "like"
        );
      }
    }
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty || user == null) return;
    final String commentText = _commentController.text.trim();
    
    await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
      'userId': user!.uid,
      'userName': currentUserName ?? "Explorer",
      'userImage': currentUserProfileImg,
      'text': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (user!.uid != widget.postData['userId']) {
      _sendNotification(
        title: currentUserName ?? "Someone", 
        body: "commented: $commentText", 
        type: "comment"
      );
    }
    
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _sendNotification({required String title, required String body, required String type}) async {
    final String? receiverId = widget.postData['userId'];
    if (receiverId == null || user == null) return;

    // جلب أحدث بياناتك لإرسالها في الإشعار
    final senderDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final senderData = senderDoc.data();

    await FirebaseFirestore.instance.collection('notifications').add({
      'receiverId': receiverId,
      'senderId': user!.uid,
      'senderName': senderData?['name'] ?? currentUserName ?? "Explorer",
      'senderImage': senderData?['profileImage'] ?? currentUserProfileImg,
      'title': senderData?['name'] ?? currentUserName ?? "New Interaction",
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
                  child: Image.network(widget.postData['imageUrl'] ?? '', height: 450, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 450, color: Colors.grey.shade200)),
                ),
                Positioned(top: 50, left: 20, child: IconButton(icon: CircleAvatar(backgroundColor: Colors.black.withValues(alpha: 0.3), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)), onPressed: () => Navigator.pop(context))),
                Positioned(top: 50, right: 20, child: IconButton(icon: CircleAvatar(backgroundColor: Colors.black.withValues(alpha: 0.3), child: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white, size: 22)), onPressed: _toggleLike)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
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
      stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final comments = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length > 5 ? 5 : comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index].data() as Map<String, dynamic>;
            String? cUserImg = comment['userImage'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(radius: 22, backgroundColor: const Color(0xFFE8F0E8), backgroundImage: (cUserImg != null && cUserImg.startsWith('http')) ? NetworkImage(cUserImg) : const AssetImage(AppAssets.profilePhoto) as ImageProvider),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(15)), child: Text(comment['text'] ?? "", style: const TextStyle(fontSize: 14))),
                  const SizedBox(height: 4),
                  Text(comment['userName'] ?? "EXPLORER", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ])),
              ]),
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
      Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: "Add a comment...", border: InputBorder.none))),
      IconButton(icon: const Icon(Icons.send, color: Color(0xFF6D8B6D)), onPressed: _addComment),
    ]);
  }
}
