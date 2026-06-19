import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class HomeDashboardProvider extends ChangeNotifier {
  String username = "Adli";
  String profileImageUrl = '';

  double currentLatitude = 3.1390;
  double currentLongitude = 101.6869;

  int tripsPlanned = 4;
  int placesVisited = 2;
  int badgesEarned = 1;
  int reviewsShared = 8;

  String upcomingTripTitle = "Melaka Exploration Trip";
  DateTime upcomingTripDate = DateTime(2026, 6, 26);
  String upcomingTripDestination = "5 Destinations Planned";

  String currentQuestTitle = "Bandaraya Melaka";
  String currentQuestProgress = "2/3";

  Future<void> loadDashboard() async {
    try {
      await getCurrentLocation();

      final hiddenGemsSnapshot = await FirebaseFirestore.instance
          .collection('hidden_gems')
          .get();

      reviewsShared = hiddenGemsSnapshot.docs.length;

      final tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .limit(1)
          .get();

      debugPrint("Trips docs count: ${tripsSnapshot.docs.length}");

      if (tripsSnapshot.docs.isNotEmpty) {
        final doc = tripsSnapshot.docs.first;
        final data = doc.data();

        debugPrint("Trip document ID: ${doc.id}");
        debugPrint("Trip data: $data");

        final destination = data['destination']?.toString() ?? "Melaka";

        upcomingTripTitle =
            "${destination[0].toUpperCase()}${destination.substring(1)} Trip";

        if (data['attractions'] is List) {
          final attractions = data['attractions'] as List;
          upcomingTripDestination =
              "${attractions.length} Destinations Planned";
        } else {
          upcomingTripDestination = "$destination Destination";
        }

        final startDateData = data['startDate'];

        if (startDateData is Timestamp) {
          upcomingTripDate = startDateData.toDate();
        } else if (startDateData is String) {
          upcomingTripDate = DateTime.parse(startDateData);
        }

        tripsPlanned = tripsSnapshot.docs.length;
      } else {
        debugPrint("No trips document found in Firestore.");
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Dashboard data not loaded: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint("Location service is disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        debugPrint("Location permission denied.");
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("Location permission denied forever.");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLatitude = position.latitude;
      currentLongitude = position.longitude;

      debugPrint("HOME LIVE LOCATION:");
      debugPrint("Lat: $currentLatitude");
      debugPrint("Lng: $currentLongitude");

      notifyListeners();
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  String get upcomingTripDateDisplay {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final trip = DateTime(
      upcomingTripDate.year,
      upcomingTripDate.month,
      upcomingTripDate.day,
    );

    final difference = trip.difference(today).inDays;

    final dateText =
        "${upcomingTripDate.day} ${_monthName(upcomingTripDate.month)} ${upcomingTripDate.year}";

    if (difference == 0) return "Today • $dateText";
    if (difference == 1) return "Tomorrow • $dateText";
    if (difference > 1) return "$difference Days Left • $dateText";

    return "Past Trip • $dateText";
  }

  String _monthName(int month) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return months[month];
  }
}
