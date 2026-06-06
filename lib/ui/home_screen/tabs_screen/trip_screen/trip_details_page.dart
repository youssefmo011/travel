import 'package:flutter/material.dart';
import 'trip_screen.dart';

class TripDetailsPage extends StatelessWidget {
  final TripDetails trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(trip.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              trip.imagePath,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(height: 250, color: Colors.grey[300], child: const Icon(Icons.image, size: 100)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${trip.date} • ${trip.time}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF769372).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(trip.mood, style: const TextStyle(color: Color(0xFF769372), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(trip.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF769372), size: 18),
                      const SizedBox(width: 5),
                      Text(trip.location, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text("About this journey", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(trip.description, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF769372),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back to Timeline", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}