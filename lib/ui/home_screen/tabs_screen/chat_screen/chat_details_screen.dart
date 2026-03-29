import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatDetailsScreen extends StatefulWidget {
  static const String routeName = 'chat-details';

  const ChatDetailsScreen({super.key});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool _isTyping = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    
    // تنفيذ عملية "القراءة" بعد قليل لضمان تحميل الـ context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  // وظيفة لجعل الرسالة "مقروءة" وإخفاء البولد والنقطة الخضراء
  void _markAsRead() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String otherUserId = args['uid'];
    String chatId = _getChatId(user!.uid, otherUserId);

    // نحدث الـ lastSenderId ليكون اليوزر الحالي، لكي تعرف القائمة أن الرسالة تمت رؤيتها
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastSenderId': user!.uid,
    });
  }

  void _onTextChanged() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final otherUserId = args['uid'];
    String chatId = _getChatId(user!.uid, otherUserId);

    if (_messageController.text.isNotEmpty && !_isTyping) {
      _setTypingStatus(chatId, true);
    } else if (_messageController.text.isEmpty && _isTyping) {
      _setTypingStatus(chatId, false);
    }
  }

  void _setTypingStatus(String chatId, bool status) async {
    setState(() => _isTyping = status);
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'typing_${user!.uid}': status,
    }, SetOptions(merge: true));
  }

  void _sendMessage(String otherUserId, {String? imageUrl}) async {
    if (_messageController.text.trim().isEmpty && imageUrl == null) return;

    String chatId = _getChatId(user!.uid, otherUserId);
    String messageText = _messageController.text.trim();
    _messageController.clear();
    _setTypingStatus(chatId, false);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': user!.uid,
      'receiverId': otherUserId,
      'text': imageUrl != null ? '📷 Image' : messageText,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'users': [user!.uid, otherUserId],
      'lastMessage': imageUrl != null ? '📷 Image' : messageText,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'lastSenderId': user!.uid,
    }, SetOptions(merge: true));
  }

  Future<void> _pickImage(String otherUserId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading image...')));
      _sendMessage(otherUserId, imageUrl: 'https://via.placeholder.com/150'); 
    }
  }

  String _getChatId(String id1, String otherId) {
    return id1.hashCode <= otherId.hashCode ? '${id1}_$otherId' : '${otherId}_$id1';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String otherUserId = args['uid'];
    final String otherUserName = args['name'];
    final String? otherUserImage = args['imageUrl'];
    String chatId = _getChatId(user!.uid, otherUserId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(otherUserName, style: const TextStyle(color: Color(0xFF1B2612), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE8F0E8),
              backgroundImage: (otherUserImage != null && otherUserImage.startsWith('http')) ? NetworkImage(otherUserImage) : null,
              child: (otherUserImage == null || !otherUserImage.startsWith('http')) ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgData = messages[index].data() as Map<String, dynamic>;
                    bool isMe = msgData['senderId'] == user!.uid;
                    return _buildMessageBubble(msgData['text'], isMe, msgData['timestamp'], msgData['imageUrl']);
                  },
                );
              },
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('chats').doc(chatId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                bool isOtherTyping = data['typing_$otherUserId'] ?? false;
                if (isOtherTyping) return _buildTypingIndicator(otherUserName);
              }
              return const SizedBox.shrink();
            },
          ),
          _buildMessageInput(otherUserId),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, Timestamp? timestamp, String? imageUrl) {
    String time = timestamp != null ? DateFormat('hh:mm a').format(timestamp.toDate()) : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFA8C6A8).withOpacity(0.8) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          border: isMe ? null : Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            if (imageUrl != null) const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Color(0xFF1B2612), fontSize: 14, height: 1.4)),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 9)),
                if (isMe) ...[const SizedBox(width: 4), const Icon(Icons.done_all, size: 12, color: Colors.grey)]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 20, height: 10,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.grey)),
          ),
          const SizedBox(width: 8),
          Text('$name is typing...', style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildMessageInput(String otherUserId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickImage(otherUserId),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.grey, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied_alt_outlined, color: Colors.grey, size: 22),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use your phone keyboard for emojis!')));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(otherUserId),
            child: const Icon(Icons.send_sharp, color: Color(0xFF6D8B6D), size: 28),
          ),
        ],
      ),
    );
  }
}
