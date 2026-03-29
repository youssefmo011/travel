import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  static const String routeName = 'help-support';

  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1B2612)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Color(0xFF1B2612), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B2612)),
            ),
            const SizedBox(height: 20),
            _buildContactCard(Icons.email_outlined, 'Email Us', 'support@travelme.com'),
            _buildContactCard(Icons.phone_outlined, 'Call Us', '+1 234 567 890'),
            const SizedBox(height: 30),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2612)),
            ),
            const SizedBox(height: 15),
            _buildFAQItem('How to book a trip?', 'You can book a trip by selecting a destination in the Explore tab and clicking "Book Now".'),
            _buildFAQItem('How to change profile photo?', 'Go to Profile tab, click the camera icon on your photo, and select a new image.'),
            _buildFAQItem('Is my data secure?', 'Yes, we use industry-standard encryption to protect your personal information.'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, String detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6D8B6D)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(detail, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(answer, style: TextStyle(color: Colors.grey.shade600, height: 1.4)),
        ),
      ],
    );
  }
}
