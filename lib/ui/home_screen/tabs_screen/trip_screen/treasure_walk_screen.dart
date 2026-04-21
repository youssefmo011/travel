import 'package:flutter/material.dart';

class TreasureWalkScreen extends StatefulWidget {
  static const String routeName = '/treasure-walk';

  // استقبال البيانات (Vibe) من الصفحة السابقة
  final dynamic vibe;

  const TreasureWalkScreen({super.key, this.vibe});

  @override
  State<TreasureWalkScreen> createState() => _TreasureWalkScreenState();
}

class _TreasureWalkScreenState extends State<TreasureWalkScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخراج البيانات مع تأمين القيم الافتراضية
    final String title = widget.vibe?.title ?? "Unknown Destination";
    final String location = widget.vibe?.location ?? "Point B";
    final String distance = widget.vibe?.distance ?? "Calculating...";
    final String imageUrl = widget.vibe?.imageUrl ?? "https://images.unsplash.com/photo-1524661135-423995f22d0b";

    // حساب وقت تقديري بناءً على المسافة (مثال منطقي)
    final String travelTime = "Approx. 25 mins";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8), // لون خلفية هادئ ومريح
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Expedition Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),

          // 1. عرض المسار بشكل نصي ومنطقي (من أين إلى أين)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                children: [
                  _buildRouteStep(Icons.my_location, "Your Current Location", "Point A", isLast: false),
                  _buildRouteStep(Icons.location_on, title, location, isLast: true),
                ],
              ),
            ),
          ),

          const Spacer(),

          // 2. بطاقة معلومات الرحلة (الوقت والمسافة)
          _buildInfoStats(distance, travelTime),

          // 3. اللوحة السفلية النهائية
          _buildBottomCard(title, location, distance, imageUrl),
        ],
      ),
    );
  }

  // ودجت لعرض خطوات الطريق (بدل الخطوط المرسومة)
  Widget _buildRouteStep(IconData icon, String mainText, String subText, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLast ? const Color(0xFF6B8E6B) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isLast ? Colors.white : Colors.grey[600], size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mainText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isLast ? Colors.black : Colors.grey[600])),
              Text(subText, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            ],
          ),
        ),
      ],
    );
  }

  // ودجت لعرض إحصائيات الرحلة بشكل جمالي
  Widget _buildInfoStats(String dist, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(child: _infoItem(Icons.directions_walk, dist, "Distance")),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          Expanded(child: _infoItem(Icons.access_time, time, "Duration")),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6B8E6B), size: 24),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomCard(String title, String loc, String dist, String img) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(radius: 28, backgroundImage: NetworkImage(img)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              // هنا يمكنك إضافة منطق لبدء الرحلة فعلياً
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Starting your journey to $title...")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8E6B),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text("CONFIRM & START", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}