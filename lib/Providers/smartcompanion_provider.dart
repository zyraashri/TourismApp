import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class SmartCompanionProvider extends ChangeNotifier {
  bool isLoading = false;

  final Set<String> savedPlaceTitles = {};

  bool isSaved(CompanionPlace place) {
    return savedPlaceTitles.contains(place.title);
  }

  double currentLatitude = 2.1896;
  double currentLongitude = 102.2501;

  String currentLocationName = "Jonker Street, Melaka";
  String temperature = "31°C";
  String weatherCondition = "Sunny";

  String companionMessage =
      "You're near A Famosa. A cultural performance starts in 30 minutes. Would you like to explore nearby attractions or events?";

  String selectedRestaurantFilter = "All";
  String selectedEventFilter = "All";

  List<CompanionPlace> nearbyAttractions = [
    CompanionPlace(
      title: "A Famosa",
      subtitle: "4.6 (324)",
      distance: "500m",
      imagePath: "assets/images/afamosa.jpg",
      latitude: 2.1916,
      longitude: 102.2501,
    ),
    CompanionPlace(
      title: "Stadthuys",
      subtitle: "4.5 (114)",
      distance: "700m",
      imagePath: "assets/images/stadthuysmelaka.jpg",
      latitude: 2.1944,
      longitude: 102.2490,
    ),
    CompanionPlace(
      title: "Melaka River Walk",
      subtitle: "4.7 (180)",
      distance: "900m",
      imagePath: "assets/images/market.jpg",
      latitude: 2.1950,
      longitude: 102.2482,
    ),
    CompanionPlace(
      title: "Baba & Nyonya Museum",
      subtitle: "4.5 (464)",
      distance: "220m",
      imagePath: "assets/images/babanyonya.jpg",
      latitude: 2.1965,
      longitude: 102.2477,
    ),
  ];

  List<CompanionPlace> nearbyRestaurants = [
    CompanionPlace(
      title: "Atlantic Nyonya HQ",
      subtitle: "700m • 4.6 (324)",
      imagePath: "assets/images/atlanticnyonya.jpg",
      tags: ["Halal"],
    ),
    CompanionPlace(
      title: "The Daily Fix",
      subtitle: "50m • 4.6 (324)",
      imagePath: "assets/images/thedailyfix.jpg",
      tags: ["Cafe"],
    ),
    CompanionPlace(
      title: "Jonker Kitchen",
      subtitle: "250m • 4.6 (324)",
      imagePath: "assets/images/jonkerkitchen.jpg",
      tags: ["Halal"],
    ),
  ];

  List<CompanionPlace> nearbyEvents = [
    CompanionPlace(
      title: "Jonker Walk Night Market",
      subtitle: "0m • 7:00 PM",
      imagePath: "assets/images/market.jpg",
      tags: ["Free", "Today"],
    ),
    CompanionPlace(
      title: "Street Busker Performance",
      subtitle: "100m • 8:00 PM",
      imagePath: "assets/images/busker.jpg",
      tags: ["Free", "Today"],
    ),
    CompanionPlace(
      title: "Cultural Dance Performance",
      subtitle: "350m • 8:30 PM",
      imagePath: "assets/images/dance.jpg",
      tags: ["Today"],
    ),
  ];

  List<TravelAlert> travelAlerts = [
    TravelAlert(
      title: "Heavy rain expected after 4:00 PM",
      subtitle: "Carry an umbrella",
      imagePath: "assets/images/weather.png",
    ),
    TravelAlert(
      title: "Road closure on Jalan Kota",
      subtitle: "Use alternative route",
      imagePath: "assets/images/traffic.png",
    ),
  ];

  List<CompanionPlace> get filteredRestaurants {
    if (selectedRestaurantFilter == "All") return nearbyRestaurants;
    return nearbyRestaurants
        .where((item) => item.tags.contains(selectedRestaurantFilter))
        .toList();
  }

  List<CompanionPlace> get filteredEvents {
    if (selectedEventFilter == "All") return nearbyEvents;
    return nearbyEvents
        .where((item) => item.tags.contains(selectedEventFilter))
        .toList();
  }

  void updateRestaurantFilter(String filter) {
    selectedRestaurantFilter = filter;
    notifyListeners();
  }

  void updateEventFilter(String filter) {
    selectedEventFilter = filter;
    notifyListeners();
  }

  Future<void> loadCompanionData() async {
    isLoading = true;
    notifyListeners();

    await getCurrentLocation();
    await loadWeather();

    debugPrint("Before calling Gemini recommendations");
    await loadGeminiGeneratedContent();
    debugPrint("After calling Gemini recommendations");

    await updateGeneratedImages();

    isLoading = false;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLatitude = position.latitude;
      currentLongitude = position.longitude;

      final placemarks = await placemarkFromCoordinates(
        currentLatitude,
        currentLongitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final street = place.street ?? "";
        final locality = place.locality ?? "";
        final state = place.administrativeArea ?? "";

        currentLocationName = street.isNotEmpty
            ? "$street, $state"
            : "$locality, $state";
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<void> loadWeather() async {
    try {
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return;

      final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather"
        "?lat=$currentLatitude"
        "&lon=$currentLongitude"
        "&appid=$apiKey"
        "&units=metric",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        temperature = "${data['main']['temp'].round()}°C";
        weatherCondition = data['weather'][0]['main'];
      }
    } catch (e) {
      debugPrint("Weather error: $e");
    }
  }

  Future<void> loadGeminiGeneratedContent() async {
    debugPrint("loadGeminiGeneratedContent started");

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return;

      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
      );

      final prompt =
          """
Generate smart tourism suggestions for a travel app.

Current location: $currentLocationName
Latitude: $currentLatitude
Longitude: $currentLongitude
Weather: $temperature, $weatherCondition

Return ONLY valid JSON:
{
  "message": "short message under 35 words",
  "attractions": [
    {"title":"", "subtitle":"", "distance":"", "tags":[]}
  ],
  "restaurants": [
    {"title":"", "subtitle":"", "distance":"", "tags":["Halal"]}
  ],
  "events": [
    {"title":"", "subtitle":"", "distance":"", "tags":["Free","Today"]}
  ],
  "alerts": [
    {"title":"", "subtitle":"", "type":"weather"}
  ]
}
""";

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      debugPrint("Gemini recommendation API called");
      debugPrint("Gemini Status: ${response.statusCode}");
      debugPrint("Gemini Body: ${response.body}");

      debugPrint("LIVE LOCATION USED: $currentLocationName");
      debugPrint("LAT LNG USED: $currentLatitude, $currentLongitude");
      debugPrint("WEATHER USED: $temperature, $weatherCondition");
      debugPrint("GEMINI STATUS: ${response.statusCode}");
      debugPrint("GEMINI BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (text != null) {
          debugPrint("GEMINI GENERATED TEXT:");
          debugPrint(text.toString());

          _applyGeminiJson(text.toString());
        }
      }
    } catch (e) {
      debugPrint("Gemini error: $e");
    }
  }

  void _applyGeminiJson(String rawText) {
    try {
      final cleanText = rawText
          .replaceAll("```json", "")
          .replaceAll("```", "")
          .trim();

      final data = jsonDecode(cleanText);

      companionMessage = data['message'] ?? companionMessage;

      final generatedAttractions = data['attractions'] as List?;
      final generatedRestaurants = data['restaurants'] as List?;
      final generatedEvents = data['events'] as List?;
      final generatedAlerts = data['alerts'] as List?;

      if (generatedAttractions != null && generatedAttractions.isNotEmpty) {
        nearbyAttractions = generatedAttractions.take(4).map((item) {
          return CompanionPlace(
            title: item['title'] ?? "Nearby Attraction",
            subtitle: item['subtitle'] ?? "Recommended place",
            distance: item['distance'] ?? "Nearby",
            imagePath: "assets/images/afamosa.jpg",
            tags: List<String>.from(item['tags'] ?? []),
          );
        }).toList();
      }

      if (generatedRestaurants != null && generatedRestaurants.isNotEmpty) {
        nearbyRestaurants = generatedRestaurants.take(3).map((item) {
          return CompanionPlace(
            title: item['title'] ?? "Nearby Restaurant",
            subtitle: item['subtitle'] ?? "Recommended restaurant",
            distance: item['distance'] ?? "Nearby",
            imagePath: "assets/images/atlanticnyonya.jpg",
            tags: List<String>.from(item['tags'] ?? ["Halal"]),
          );
        }).toList();
      }

      if (generatedEvents != null && generatedEvents.isNotEmpty) {
        nearbyEvents = generatedEvents.take(3).map((item) {
          return CompanionPlace(
            title: item['title'] ?? "Nearby Event",
            subtitle: item['subtitle'] ?? "Happening today",
            distance: item['distance'] ?? "Nearby",
            imagePath: "assets/images/market.jpg",
            tags: List<String>.from(item['tags'] ?? ["Today"]),
          );
        }).toList();
      }

      if (generatedAlerts != null && generatedAlerts.isNotEmpty) {
        travelAlerts = generatedAlerts.take(2).map((item) {
          final type = item['type'] ?? "weather";

          return TravelAlert(
            title: item['title'] ?? "Travel Alert",
            subtitle: item['subtitle'] ?? "Stay aware",
            imagePath: type == "road"
                ? "assets/images/traffic.png"
                : "assets/images/weather.png",
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Gemini JSON parse error: $e");
    }
  }

  Future<void> updateGeneratedImages() async {
    for (int i = 0; i < nearbyAttractions.length; i++) {
      final imageUrl = await getPlaceImageUrl(nearbyAttractions[i].title);
      nearbyAttractions[i] = nearbyAttractions[i].copyWith(imageUrl: imageUrl);
    }

    for (int i = 0; i < nearbyRestaurants.length; i++) {
      final imageUrl = await getPlaceImageUrl(nearbyRestaurants[i].title);
      nearbyRestaurants[i] = nearbyRestaurants[i].copyWith(imageUrl: imageUrl);
    }

    for (int i = 0; i < nearbyEvents.length; i++) {
      final imageUrl = await getPlaceImageUrl(nearbyEvents[i].title);
      nearbyEvents[i] = nearbyEvents[i].copyWith(imageUrl: imageUrl);
    }

    notifyListeners();
  }

  Future<String?> getPlaceImageUrl(String placeName) async {
    try {
      final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return null;

      final searchUrl = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json"
        "?query=${Uri.encodeComponent(placeName)}"
        "&location=$currentLatitude,$currentLongitude"
        "&radius=5000"
        "&key=$apiKey",
      );

      final searchResponse = await http.get(searchUrl);
      if (searchResponse.statusCode != 200) return null;

      final searchData = jsonDecode(searchResponse.body);

      if (searchData['results'] == null || searchData['results'].isEmpty) {
        return null;
      }

      final photos = searchData['results'][0]['photos'];

      if (photos == null || photos.isEmpty) return null;

      final photoReference = photos[0]['photo_reference'];

      return "https://maps.googleapis.com/maps/api/place/photo"
          "?maxwidth=600"
          "&photo_reference=$photoReference"
          "&key=$apiKey";
    } catch (e) {
      debugPrint("Place image error: $e");
      return null;
    }
  }

  Future<String> generatePlaceDetails(CompanionPlace place) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        return "Gemini API key is missing. Please add GEMINI_API_KEY in your .env file.";
      }

      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey",
      );

      final prompt =
          """
You are a smart travel companion for a tourism app.

User current location:
$currentLocationName

Selected place:
${place.title}

Place detail:
${place.subtitle}

Distance:
${place.distance ?? "Nearby"}

Generate a short travel guide with:
1. Overview
2. Why Visit
3. Best Time to Visit
4. Things To Do
5. Travel Tips

Make it simple, friendly, and useful for tourists.
""";

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (text != null) {
          return text.toString().trim();
        }
      }

      if (response.statusCode == 429) {
        return """
Overview
${place.title} is recommended based on your current location at $currentLocationName.

Why Visit
It is a nearby attraction that may match your travel interest and current area.

Best Time to Visit
Morning or late afternoon is usually more comfortable.

Things To Do
• Explore the area
• Take photos
• Check nearby food spots
• Visit other attractions nearby

Travel Tips
Check weather before going and use the in-app map direction for navigation.
""";
      }

      debugPrint("Gemini status: ${response.statusCode}");
      debugPrint("Gemini body: ${response.body}");

      return "Unable to generate travel guide right now.";
    } catch (e) {
      debugPrint("Generate place details error: $e");
      return "Unable to load AI travel guide.";
    }
  }

  Future<void> saveSuggestion(CompanionPlace place, String category) async {
    if (savedPlaceTitles.contains(place.title)) {
      savedPlaceTitles.remove(place.title);
      notifyListeners();
      return;
    }

    savedPlaceTitles.add(place.title);
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('saved_companion_places')
          .add({
            'userId': 'demoUser',
            'title': place.title,
            'subtitle': place.subtitle,
            'category': category,
            'imagePath': place.imagePath,
            'imageUrl': place.imageUrl,
            'distance': place.distance,
            'tags': place.tags,
            'savedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }
}

class CompanionPlace {
  final String title;
  final String subtitle;
  final String imagePath;
  final String? imageUrl;
  final String? distance;
  final List<String> tags;
  final double? latitude;
  final double? longitude;

  CompanionPlace({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.imageUrl,
    this.distance,
    this.tags = const [],
    this.latitude,
    this.longitude,
  });

  CompanionPlace copyWith({
    String? title,
    String? subtitle,
    String? imagePath,
    String? imageUrl,
    String? distance,
    List<String>? tags,
    double? latitude,
    double? longitude,
  }) {
    return CompanionPlace(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      distance: distance ?? this.distance,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class TravelAlert {
  final String title;
  final String subtitle;
  final String imagePath;

  TravelAlert({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}
