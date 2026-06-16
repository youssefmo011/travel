import 'package:flutter/material.dart';

// استيراد صفحة النتيجة لكي يتعرف الكود على ShuffleResultScreen
// import 'shuffle_result_screen.dart'; 

class MapPlanScreen extends StatelessWidget {
  static const String routeName = '/map-plan';

  const MapPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E9E1), // لون الخلفية العام (ورقي)
      body: LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final double h = constraints.maxHeight;

            return Stack(
              children: [
                // 1. خلفية الخريطة (المنطقة الخضراء والخطوط التضاريسية)
                Positioned.fill(
                  child: CustomPaint(
                    painter: ProfessionalMapPainter(),
                  ),
                ),

                // 2. مسار الرحلة (الخط الداكن مع النقاط)
                Positioned.fill(
                  child: CustomPaint(
                    painter: TravelPathPainter(),
                  ),
                ),

                // 3. المعالم (Markers) - تم وضعها بناءً على أماكن منطقية في المسار
                _buildProfessionalMarker(h * 0.38, w * 0.28, Icons.church_outlined, "Sanctuary"),
                _buildProfessionalMarker(h * 0.52, w * 0.50, Icons.waves_outlined, "Fountain"),
                _buildProfessionalMarker(h * 0.64, w * 0.38, Icons.location_city_outlined, "Ruins"),
                _buildProfessionalMarker(h * 0.68, w * 0.62, Icons.park_outlined, "Ancient Tree"),
                _buildProfessionalMarker(h * 0.76, w * 0.44, Icons.cottage_outlined, "The Mill"),
                _buildProfessionalMarker(h * 0.78, w * 0.64, Icons.forest_outlined, "Oak Forest"),

                // 4. زر الرجوع بستايل بسيط
                Positioned(
                  top: 50,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF71886B),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ),

                // 5. زر الحفظ (Save) كما في الصورة
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        // هنا يتم الحفظ أو الانتقال للشاشة التالية
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Plan saved successfully!")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF71886B),
                        minimumSize: const Size(220, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "save",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  // ودجت لبناء الماركر بشكل احترافي يشبه الصورة
  Widget _buildProfessionalMarker(double top, double left, IconData icon, String label) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4D6C8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF71886B).withOpacity(0.5), width: 1),
            ),
            child: Icon(icon, color: const Color(0xFF4A5A44), size: 22),
          ),
          const SizedBox(height: 2),
          // خلفية خفيفة للنص ليكون واضحاً
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF4A5A44), fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// الرسام المسؤول عن خلفية الخريطة (المنطقة الخضراء والخطوط الكنتورية)
class ProfessionalMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 1. رسم المنطقة الخضراء العلوية (المدينة/المنتزه)
    paint.color = const Color(0xFFB5C9AD);
    final greenAreaPath = Path();
    greenAreaPath.moveTo(0, 0);
    greenAreaPath.lineTo(size.width, 0);
    greenAreaPath.lineTo(size.width, size.height * 0.35);
    greenAreaPath.quadraticBezierTo(size.width * 0.5, size.height * 0.45, 0, size.height * 0.35);
    greenAreaPath.close();
    canvas.drawPath(greenAreaPath, paint);

    // 2. رسم تقسيمات "البلوكات" داخل المنطقة الخضراء (City Grid)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // خطوط طولية وعرضية مائلة قليلاً لتعطي شكل احترافي
    for (int i = -5; i < 15; i++) {
      canvas.drawLine(Offset(i * 50.0, 0), Offset(i * 50.0 + 100, size.height * 0.4), gridPaint);
      canvas.drawLine(Offset(-100, i * 60.0), Offset(size.width + 100, i * 60.0 - 40), gridPaint);
    }

    // 3. رسم الخطوط الكنتورية (Topographic Lines) في المنطقة السفلية
    final topoPaint = Paint()
      ..color = const Color(0xFFD0D2C5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 20; i++) {
      final p = Path();
      double yBase = size.height * (0.4 + i * 0.04);
      p.moveTo(-50, yBase);
      p.cubicTo(
          size.width * 0.3, yBase - 40, 
          size.width * 0.7, yBase + 40, 
          size.width + 50, yBase
      );
      canvas.drawPath(p, topoPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// الرسام المسؤول عن رسم المسار (Travel Path)
class TravelPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = const Color(0xFF5A6B54)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // نقطة البداية في المنطقة الخضراء
    path.moveTo(size.width * 0.4, size.height * 0.1);
    path.lineTo(size.width * 0.25, size.height * 0.18);
    path.lineTo(size.width * 0.6, size.height * 0.22);
    path.lineTo(size.width * 0.5, size.height * 0.32);
    
    // الانتقال للمنطقة السفلية (المسار المتعرج)
    path.lineTo(size.width * 0.28, size.height * 0.38); // Sanctuary
    path.quadraticBezierTo(size.width * 0.35, size.height * 0.45, size.width * 0.5, size.height * 0.52); // Fountain
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.58, size.width * 0.38, size.height * 0.64); // Ruins
    path.lineTo(size.width * 0.62, size.height * 0.68); // Ancient Tree
    path.quadraticBezierTo(size.width * 0.55, size.height * 0.72, size.width * 0.44, size.height * 0.76); // The Mill
    path.lineTo(size.width * 0.64, size.height * 0.78); // Oak Forest

    canvas.drawPath(path, pathPaint);

    // رسم دوائر صغيرة عند نقاط الالتقاء (Nodes)
    final dotPaint = Paint()..color = const Color(0xFF5A6B54);
    final nodes = [
      Offset(size.width * 0.5, size.height * 0.32),
      Offset(size.width * 0.28, size.height * 0.38),
      Offset(size.width * 0.5, size.height * 0.52),
      Offset(size.width * 0.38, size.height * 0.64),
      Offset(size.width * 0.62, size.height * 0.68),
      Offset(size.width * 0.44, size.height * 0.76),
      Offset(size.width * 0.64, size.height * 0.78),
    ];

    for (var node in nodes) {
      canvas.drawCircle(node, 3.5, dotPaint);
      // رسم حلقة فاتحة حول النقطة
      canvas.drawCircle(node, 6, Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
