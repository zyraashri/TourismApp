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

      final snapshot = await FirebaseFirestore.instance
          .collection('trips')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data.containsKey('title')) {
          upcomingTripTitle = data['title'];
        }

        if (data.containsKey('destination')) {
          upcomingTripDestination = data['destination'];
        }

        if (data.containsKey('startDate')) {
          final startDateData = data['startDate'];

          if (startDateData is Timestamp) {
            upcomingTripDate = startDateData.toDate();
          }
        }
      }

      tripsPlanned = 1;

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
