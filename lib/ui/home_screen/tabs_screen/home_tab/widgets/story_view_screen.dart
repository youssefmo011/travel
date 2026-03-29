import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/core/assets/app_assets.dart';

class StoryViewScreen extends StatefulWidget {
  final List<dynamic> imageUrls;
  final String userName;
  final String userId;
  final String? userProfileImage; // أضفنا رابط صورة البروفايل

  const StoryViewScreen({
    super.key, 
    required this.imageUrls, 
    required this.userName, 
    required this.userId,
    this.userProfileImage,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _controller.forward();
  }

  void _nextStory() {
    if (mounted) {
      if (_currentIndex < widget.imageUrls.length - 1) {
        setState(() {
          _currentIndex++;
          _controller.reset();
          _controller.forward();
        });
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _previousStory() {
    if (mounted && _currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _controller.reset();
        _controller.forward();
      });
    }
  }

  void _deleteCurrentStory() async {
    try {
      List<dynamic> updatedStories = List.from(widget.imageUrls);
      updatedStories.removeAt(_currentIndex);

      if (updatedStories.isEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'userStories': FieldValue.delete(),
          'storyTimestamp': FieldValue.delete(),
          'viewedBy': FieldValue.delete(),
        });
        if (mounted) Navigator.pop(context);
      } else {
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'userStories': updatedStories,
        });
        if (mounted) {
          if (_currentIndex >= updatedStories.length) {
            Navigator.pop(context);
          } else {
            _controller.reset();
            _controller.forward();
          }
        }
      }
    } catch (e) {
      debugPrint("Error deleting story: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.network(
              widget.imageUrls[_currentIndex],
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _previousStory,
                  onLongPress: () => _controller.stop(),
                  onLongPressUp: () => _controller.forward(),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _nextStory,
                  onLongPress: () => _controller.stop(),
                  onLongPressUp: () => _controller.forward(),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: List.generate(widget.imageUrls.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: index < _currentIndex ? 1.0 : (index == _currentIndex ? _controller.value : 0.0),
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 2,
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFE8F0E8),
                        backgroundImage: (widget.userProfileImage != null && widget.userProfileImage!.startsWith('http'))
                            ? NetworkImage(widget.userProfileImage!)
                            : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.userName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      if (currentUser?.uid == widget.userId)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white70),
                          onPressed: _deleteCurrentStory,
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
