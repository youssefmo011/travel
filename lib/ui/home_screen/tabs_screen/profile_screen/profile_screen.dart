import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/core/assets/app_assets.dart';
import 'package:untitled1/ui/login_screen/login_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/personal_info_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/notifications_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/travel_history_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/favorites_screen.dart';
import 'package:untitled1/ui/home_screen/tabs_screen/profile_screen/help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = 'profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  final String _cloudName = "drz07cb7a"; 
  final String _uploadPreset = "travel";

  Future<void> _uploadToCloudinary(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      setState(() => _isUploading = true);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
      );
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedData = jsonDecode(responseData);
        String imageUrl = decodedData['secure_url'];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImage': imageUrl});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated via Cloudinary!')),
          );
        }
      } else {
        throw Exception('Failed to upload');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) await _uploadToCloudinary(File(image.path));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Color(0xFF1B2612), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String userName = user?.displayName ?? "Traveler";
          String? profileImageUrl;
          String travelVibe = "Serene Seeker"; 

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['name'] ?? userName;
            profileImageUrl = data['profileImage'];
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(userName, user?.email, profileImageUrl, travelVibe),
                const SizedBox(height: 30),

                const SizedBox(height: 30),
                _buildProfileMenu(context),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String? email, String? imageUrl, String vibe) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6D8B6D), width: 2),
              ),
              child: CircleAvatar(
                radius: 65,
                backgroundColor: const Color(0xFFE8F0E8),
                backgroundImage: (imageUrl != null && imageUrl.startsWith('http'))
                    ? NetworkImage(imageUrl)
                    : const AssetImage(AppAssets.profilePhoto) as ImageProvider,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Color(0xFF6D8B6D))
                    : null,
              ),
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6D8B6D),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B2612)),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6D8B6D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            vibe,
            style: const TextStyle(color: Color(0xFF6D8B6D), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          email ?? 'traveler@explore.com',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }



  Widget _buildProfileMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          _buildMenuItem(context, Icons.person_outline_rounded, 'Personal Information', 'Name, Email, Phone', () {
             Navigator.pushNamed(context, PersonalInfoScreen.routeName);
          }),
          _buildMenuItem(context, Icons.history_rounded, 'Travel History', 'Past journeys & Stories', () {
             Navigator.pushNamed(context, TravelHistoryScreen.routeName);
          }),
          _buildMenuItem(context, Icons.favorite_border_rounded, 'My Favorites', 'Saved locations & Hotels', () {
             Navigator.pushNamed(context, FavoritesScreen.routeName);
          }),
          _buildMenuItem(context, Icons.notifications_none_rounded, 'Notifications', 'Trip updates & Alerts', () {
             Navigator.pushNamed(context, NotificationsScreen.routeName);
          }),
          _buildMenuItem(context, Icons.help_outline_rounded, 'Help & Support', 'FAQ & Contact us', () {
             Navigator.pushNamed(context, HelpSupportScreen.routeName);
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6D8B6D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF6D8B6D)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B2612))),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Wait, Stay', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginScreen.routeName,
                  (route) => false,
                );
              }
            },
            child: const Text('Yes, Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B2612))),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();
  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2));
  }
}
