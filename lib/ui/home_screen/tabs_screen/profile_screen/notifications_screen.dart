import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = 'notifications';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isNotificationEnabled = false;
  String messageNotification = 'Mention only';
  bool isVibrateEnabled = true;
  bool isBannerEnabled = false;
  bool isOtherActivitiesEnabled = false;
  bool isNewsUpdatesEnabled = true;
  bool isPromotionsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification vibe',
          style: TextStyle(
            color: Color(0xFF1B2612),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Alert Box - الآن يتغير لونه ونصه بناءً على حالة المفتاح
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isNotificationEnabled ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNotificationEnabled ? const Color(0xFFC8E6C9) : const Color(0xFFFFE0B2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isNotificationEnabled ? Icons.check_circle_outline : Icons.info_outline,
                    color: isNotificationEnabled ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isNotificationEnabled ? 'Notifications are on' : 'Notifications are off',
                    style: TextStyle(
                      color: isNotificationEnabled ? const Color(0xFF2E7D32) : const Color(0xFF8D6E63),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notification Main Switch
            _buildSectionHeader('Notification'),
            _buildSwitchTile(
              title: 'Notification',
              subtitle: 'Adipisicing veniam nulla minim.',
              value: isNotificationEnabled,
              onChanged: (val) => setState(() => isNotificationEnabled = val),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Message notification'),
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Notify me about...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            // Radio Options Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildRadioTile('All new messages'),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildRadioTile('Mention only'),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildRadioTile('Nothing'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('In-app notification'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Sounds', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Comm', style: TextStyle(color: Colors.grey.shade400)),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ],
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSwitchTileSimple('Vibrate', isVibrateEnabled, (val) => setState(() => isVibrateEnabled = val)),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildSwitchTileSimple('Banner', isBannerEnabled, (val) => setState(() => isBannerEnabled = val)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Other account activities'),
            _buildSwitchTile(
              title: 'Other account activities',
              subtitle: 'Est tempor qui ullamco',
              value: isOtherActivitiesEnabled,
              onChanged: (val) => setState(() => isOtherActivitiesEnabled = val),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('App updates'),
            _buildSwitchTile(
              title: 'News & feature updates',
              subtitle: 'Est tempor qui ullamco',
              value: isNewsUpdatesEnabled,
              onChanged: (val) => setState(() => isNewsUpdatesEnabled = val),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Promotions',
              subtitle: 'Est tempor qui ullamco',
              value: isPromotionsEnabled,
              onChanged: (val) => setState(() => isPromotionsEnabled = val),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B2612),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6D8B6D),
        ),
      ],
    );
  }

  Widget _buildSwitchTileSimple(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF6D8B6D),
      ),
    );
  }

  Widget _buildRadioTile(String title) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      value: title,
      groupValue: messageNotification,
      onChanged: (val) => setState(() => messageNotification = val!),
      activeColor: const Color(0xFF6D8B6D),
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
