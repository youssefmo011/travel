import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'adventure_summary_screen.dart';

class TreasureWalkScreen extends StatefulWidget {
  static const String routeName = 'treasure-walk';
  const TreasureWalkScreen({super.key});

  @override
  State<TreasureWalkScreen> createState() => _TreasureWalkScreenState();
}

class _TreasureWalkScreenState extends State<TreasureWalkScreen> {
  int currentStep = 1;
  bool hasCapturedImage = false;

  final List<Map<String, String>> stepsData = [
    {"title": "Walk of Cairo", "image": "assets/images/walk of cairo.jpg", "desc": "Find the entrance to start your journey."},
    {"title": "Coffee Culture", "image": "assets/images/koffee culture.jpg", "desc": "Locate the coffee shop to unlock the next clue."},
    {"title": "Lu Caffe", "image": "assets/images/lu caffe.jpg", "desc": "The final destination is waiting for you!"},
  ];

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) setState(() => hasCapturedImage = true);
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void _onButtonPressed() async {
    if (!hasCapturedImage) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please capture a photo first!"), backgroundColor: Colors.redAccent));
      return;
    }

    if (currentStep < 3) {
      setState(() {
        currentStep++;
        hasCapturedImage = false;
      });
    } else {
      final result = await Navigator.pushNamed(context, AdventureSummaryScreen.routeName);
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          _buildBackgroundMap(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildActiveCard(),
                const SizedBox(height: 15),
                const Icon(Icons.keyboard_double_arrow_down, color: Color(0xFF769372), size: 30),
                Expanded(child: _buildStepsList()),
                _buildBottomAction(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundMap() {
    return Positioned(
      top: 0, left: 0, right: 0, height: MediaQuery.of(context).size.height * 0.45,
      child: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/map plan 1.jpg"), fit: BoxFit.cover)),
        child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF769372).withValues(alpha: 0.4), Colors.transparent, const Color(0xFFF5F5F5)]))),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: const Row(children: [Icon(Icons.location_on, color: Color(0xFF769372), size: 16), SizedBox(width: 8), Text("Treasure Walk", style: TextStyle(fontWeight: FontWeight.w900))]),
          ),
          const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.lock_outline)),
        ],
      ),
    );
  }

  Widget _buildActiveCard() {
    var step = stepsData[currentStep - 1];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)]),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset(step['image']!, width: 100, height: 100, fit: BoxFit.cover)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("STEP $currentStep", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF769372))),
                Text(step['title']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(color: hasCapturedImage ? Colors.green : const Color(0xFF769372), borderRadius: BorderRadius.circular(15)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.camera_alt, color: Colors.white, size: 16), const SizedBox(width: 5), Text(hasCapturedImage ? "Verified" : "Capture", style: const TextStyle(color: Colors.white, fontSize: 12))]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45))),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
        itemCount: stepsData.length,
        itemBuilder: (context, index) {
          int stepNum = index + 1;
          bool isLocked = stepNum > currentStep;
          bool isCompleted = stepNum < currentStep;
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: isLocked ? Colors.grey[50] : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF769372).withValues(alpha: 0.1))),
            child: Row(
              children: [
                Text("STEP $stepNum - ${stepsData[index]['title']}", style: TextStyle(fontWeight: FontWeight.bold, color: isLocked ? Colors.grey : Colors.black, decoration: isCompleted ? TextDecoration.lineThrough : null)),
                const Spacer(),
                Icon(isLocked ? Icons.lock_outline : Icons.check_circle, color: isLocked ? Colors.grey : const Color(0xFF769372)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: hasCapturedImage ? const Color(0xFF769372) : Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          onPressed: _onButtonPressed,
          child: Text(currentStep == 3 ? "COMPLETE ADVENTURE" : "NEXT STEP", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}