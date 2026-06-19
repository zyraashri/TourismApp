import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/gem_card.dart';
import 'add_hidden_gem_page.dart';

class HiddenGemsPage extends StatefulWidget {
  const HiddenGemsPage({super.key});

  @override
  State<HiddenGemsPage> createState() => _HiddenGemsPageState();
}

class _HiddenGemsPageState extends State<HiddenGemsPage> {
  String selectedCategory = "All";

  static const Color backgroundColor = Color(0xFFFCF8EF);
  static const Color headerColor = Color(0xFFF7EAB6);
  static const Color primaryColor = Color(0xFF3F646C);
  static const Color darkColor = Color(0xFF384345);

  final List<Map<String, dynamic>> staticGems = [
    {
      "title": "Kopi Hutan Cafe",
      "location": "Pulau Pinang",
      "category": "Food & Beverages",
      "description":
          "A peaceful cafe surrounded by greenery, perfect for coffee lovers who enjoy a calm hidden spot.",
      "rating": 4.9,
      "imagePath": "assets/images/kopihutan.jpg",
      "galleryImages": [
        "assets/images/kopihutan.jpg",
        "assets/images/kopihutan2.jpg",
        "assets/images/kopihutan3.jpg",
      ],
    },
    {
      "title": "Tasik Timah Tasoh",
      "location": "Perlis",
      "category": "Nature",
      "description":
          "A beautiful lakeside destination with scenic views, peaceful surroundings and relaxing nature vibes.",
      "rating": 4.8,
      "imagePath": "assets/images/tasiktimah.jpg",
      "galleryImages": [
        "assets/images/tasiktimah.jpg",
        "assets/images/tasiktimah2.jpg",
        "assets/images/tasiktimah3.jpg",
      ],
    },
    {
      "title": "The Daily Fix Cafe",
      "location": "Melaka",
      "category": "Food & Beverages",
      "description":
          "A charming hidden cafe located inside a heritage-style building, famous for its cozy atmosphere.",
      "rating": 4.7,
      "imagePath": "assets/images/dailyfix.jpg",
      "galleryImages": [
        "assets/images/dailyfix.jpg",
        "assets/images/dailyfix2.jpg",
        "assets/images/dailyfix3.jpg",
      ],
    },
  ];

  String getDefaultImageByCategory(String category) {
    if (category == "Nature") {
      return "assets/images/tasiktimah.jpg";
    } else if (category == "Food & Beverages") {
      return "assets/images/kopihutan.jpg";
    } else if (category == "Culture") {
      return "assets/images/dailyfix.jpg";
    } else if (category == "Scenic Views") {
      return "assets/images/tasiktimah.jpg";
    } else {
      return "assets/images/dailyfix.jpg";
    }
  }

  bool shouldShowCategory(String category) {
    if (selectedCategory == "All") {
      return true;
    }

    return category == selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 159, 153, 131),
                  headerColor,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Hidden Gems",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                    ),

                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddHiddenGemPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          color: darkColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Search hidden gems...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: primaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip("All"),
                      _buildCategoryChip("Nature"),
                      _buildCategoryChip("Food & Beverages"),
                      _buildCategoryChip("Culture"),
                      _buildCategoryChip("Scenic Views"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              children: [
                ...staticGems
                    .where((gem) => shouldShowCategory(gem["category"]))
                    .map(
                  (gem) {
                    return GemCard(
                      title: gem["title"],
                      location: gem["location"],
                      description: gem["description"],
                      rating: gem["rating"],
                      imagePath: gem["imagePath"],
                      galleryImages: List<String>.from(gem["galleryImages"]),
                    );
                  },
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("hidden_gems")
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Unable to load submitted gems: ${snapshot.error}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String category =
                          data["category"] ?? "Uncategorized";

                      return shouldShowCategory(category);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const SizedBox();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: 12,
                          ),
                          child: Text(
                            "Community Submissions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                        ),

                        ...filteredDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final String title =
                              data["placeName"] ?? "Untitled Hidden Gem";
                          final String location =
                              data["destination"] ?? "Malaysia";
                          final String category =
                              data["category"] ?? "Uncategorized";
                          final String description = data["description"] ??
                              "No description provided yet.";

                          final String imagePath =
                              getDefaultImageByCategory(category);

                          return GemCard(
                            title: title,
                            location: location,
                            description: description,
                            rating: 0.0,
                            imagePath: imagePath,
                            galleryImages: [imagePath],
                          );
                        }),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black,
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: "Planner",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond_outlined),
            label: "Hidden Gems",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: "Quests",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            label: "Companion",
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : darkColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}