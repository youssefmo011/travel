import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/core/assets/app_assets.dart';
import 'post_details_screen.dart';

class FeaturedVibeCard extends StatefulWidget {
  final String title;
  final String location;
  final String imagePath;
  final String? profileImage;
  final String? userName;
  final String? likes;
  final bool isNetworkImage;
  final String? postId;
  final Map<String, dynamic>? postData;
  final bool isLiked;

  const FeaturedVibeCard({
    super.key,
    required this.title,
    required this.location,
    required this.imagePath,
    this.profileImage,
    this.userName,
    this.likes,
    this.isNetworkImage = false,
    this.postId,
    this.postData,
    this.isLiked = false,
  });

  @override
  State<FeaturedVibeCard> createState() => _FeaturedVibeCardState();
}

class _FeaturedVibeCardState extends State<FeaturedVibeCard> {
  bool _showHeartAnimation = false;
  final Color themeGreen = const Color(0xFFE70909);

  void _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.postId == null) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    
    if (widget.isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([user.uid])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([user.uid])
      });
    }
  }

  void _handleDoubleTap() {
    if (!widget.isLiked) {
      _toggleLike();
    }
    setState(() => _showHeartAnimation = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeartAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 25),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Image with Double Tap & Click to details
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            onTap: () {
              if (widget.postId != null && widget.postData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailsScreen(
                      postData: widget.postData!,
                      postId: widget.postId!,
                    ),
                  ),
                );
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: widget.isNetworkImage 
                ? Image.network(widget.imagePath, height: 480, width: double.infinity, fit: BoxFit.cover)
                : Image.asset(widget.imagePath, height: 480, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          
          // The Vibe Heart Animation (Matching App Theme)
          if (_showHeartAnimation)
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 400),
              tween: Tween<double>(begin: 0, end: 1.2),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(Icons.favorite, color: themeGreen.withOpacity(0.9), size: 100),
                );
              },
            ),

          // More icon
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
            ),
          ),
  
          // Blur Info Box (Glassmorphism Effect)
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.white70, size: 12),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text('Wild', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: (widget.profileImage != null && widget.profileImage!.startsWith('http'))
                                ? NetworkImage(widget.profileImage!)
                                : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'shared by ${widget.userName ?? 'explorer'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _toggleLike,
                            child: Row(
                              children: [
                                Icon(
                                  widget.isLiked ? Icons.favorite : Icons.favorite_border, 
                                  color: widget.isLiked ? themeGreen : Colors.white,
                                  size: 18
                                ),
                                const SizedBox(width: 6),
                                Text(widget.likes ?? '0', style: const TextStyle(color: Colors.white, fontSize: 11)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text('View', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
