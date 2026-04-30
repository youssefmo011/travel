import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddPostScreen extends StatefulWidget {
  static const String routeName = 'add-post';
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _selectedImage;
  String _selectedVibe = 'Chill';
  bool _isPosting = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<Map<String, dynamic>> _vibes = [
    {'name': 'Chill', 'icon': Icons.coffee_outlined},
    {'name': 'Wild', 'icon': Icons.landscape_outlined},
    {'name': 'Cultural', 'icon': Icons.music_note_outlined},
  ];

  final String _cloudName = "drz07cb7a"; 
  final String _uploadPreset = "travel";

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _handlePost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image first')));
      return;
    }

    setState(() => _isPosting = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'));
      request.fields['upload_preset'] = _uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        String imageUrl = jsonDecode(responseData)['secure_url'];

        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = userDoc.data();

        await FirebaseFirestore.instance.collection('posts').add({
          'userId': user.uid,
          'userName': userData?['name'] ?? user.displayName ?? "Explorer",
          'userImage': userData?['profileImage'] ?? user.photoURL,
          'title': _descriptionController.text.trim(),
          'location': _locationController.text.trim().isEmpty ? "Global" : _locationController.text.trim(),
          'imageUrl': imageUrl,
          'vibe': _selectedVibe,
          'likes': [], // تم التغيير إلى قائمة فارغة لتخزين الـ UIDs
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Experience shared!')));
          Navigator.pop(context);
        }
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isPosting = false);
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
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Experience', style: TextStyle(color: Color(0xFF1B2612), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: _isPosting ? null : _handlePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC4D4A4),
                foregroundColor: const Color(0xFF1B2612),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isPosting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B2612))) 
                : const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('THE VIBE', required: true),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 30),
                          ),
                          const SizedBox(height: 15),
                          const Text('Tap to upload your vibe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Photos or short videos (max 15s)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionHeader('THE STORY'),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Describe your experience...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.location_on_outlined, color: Color(0xFFC4D4A4), size: 20),
                      hintText: 'Add Location',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionHeader('SELECT VIBE'),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _vibes.map((vibe) {
                  bool isSelected = _selectedVibe == vibe['name'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(vibe['name']),
                      avatar: Icon(vibe['icon'], size: 18, color: isSelected ? const Color(0xFF1B2612) : Colors.grey),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _selectedVibe = vibe['name']),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFC4D4A4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.2)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool required = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        if (required)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)),
            child: const Text('Required', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
      ],
    );
  }
}
