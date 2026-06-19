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

      const currentUserId = "demoUser";

      final dashboardDoc = await FirebaseFirestore.instance
          .collection('dashboard')
          .doc('home')
          .get();

      if (dashboardDoc.exists) {
        final data = dashboardDoc.data()!;

        username = data['username'] ?? username;
        profileImageUrl = data['profileImageUrl'] ?? profileImageUrl;
        upcomingTripTitle = data['upcomingTripTitle'] ?? upcomingTripTitle;

        final tripDateData = data['upcomingTripDate'];

        if (tripDateData is Timestamp) {
          upcomingTripDate = tripDateData.toDate();
        } else if (tripDateData is String) {
          upcomingTripDate =
              DateTime.tryParse(tripDateData) ?? upcomingTripDate;
        }

        upcomingTripDestination =
            data['upcomingTripDestination'] ?? upcomingTripDestination;

        currentQuestTitle = data['currentQuestTitle'] ?? currentQuestTitle;
        currentQuestProgress =
            data['currentQuestProgress'] ?? currentQuestProgress;
      }

      final userTripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('userId', isEqualTo: currentUserId)
          .get();

      final latestTripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .limit(1)
          .get();

      if (latestTripsSnapshot.docs.isNotEmpty) {
        final doc = latestTripsSnapshot.docs.first;
        final data = doc.data();

        debugPrint("Trip document ID: ${doc.id}");
        debugPrint("Trip data: $data");

        final destination = data['destination']?.toString() ?? "Melaka";

        if (destination.isNotEmpty) {
          upcomingTripTitle =
              "${destination[0].toUpperCase()}${destination.substring(1)} Trip";
        }

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
          upcomingTripDate =
              DateTime.tryParse(startDateData) ?? upcomingTripDate;
        }
      } else {
        debugPrint("No trips document found in Firestore.");
      }

      final placesVisitedSnapshot = await FirebaseFirestore.instance
          .collection('quest_checkins')
          .where('userId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'completed')
          .get();

      final badgesSnapshot = await FirebaseFirestore.instance
          .collection('user_badges')
          .where('userId', isEqualTo: currentUserId)
          .get();

      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('userId', isEqualTo: currentUserId)
          .get();

      final hiddenGemsSnapshot = await FirebaseFirestore.instance
          .collection('hidden_gems')
          .get();

      tripsPlanned = userTripsSnapshot.docs.isNotEmpty
          ? userTripsSnapshot.docs.length
          : latestTripsSnapshot.docs.length;

      placesVisited = placesVisitedSnapshot.docs.length;
      badgesEarned = badgesSnapshot.docs.length;

      reviewsShared = reviewsSnapshot.docs.isNotEmpty
          ? reviewsSnapshot.docs.length
          : hiddenGemsSnapshot.docs.length;

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
