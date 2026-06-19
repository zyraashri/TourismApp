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
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = "All";
  String searchQuery = "";

  static const Color backgroundColor = Color(0xFFFCF8EF);
  static const Color headerColor = Color(0xFFF7EAB6);
  static const Color primaryColor = Color(0xFF3F646C);
  static const Color darkColor = Color(0xFF384345);
  static const Color textGrey = Color(0xFF7A7A7A);

  final List<Map<String, dynamic>> staticGems = [
    {
      "gemId": "kopi_hutan_cafe",
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
      "isCommunitySubmission": false,
    },
    {
      "gemId": "tasik_timah_tasoh",
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
      "isCommunitySubmission": false,
    },
    {
      "gemId": "the_daily_fix_cafe",
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
      "isCommunitySubmission": false,
    },
  ];

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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

  List<String> getDefaultGalleryByCategory(String category) {
    if (category == "Nature") {
      return [
        "assets/images/tasiktimah.jpg",
        "assets/images/tasiktimah2.jpg",
        "assets/images/tasiktimah3.jpg",
      ];
    } else if (category == "Food & Beverages") {
      return [
        "assets/images/kopihutan.jpg",
        "assets/images/kopihutan2.jpg",
        "assets/images/kopihutan3.jpg",
      ];
    } else if (category == "Culture") {
      return [
        "assets/images/dailyfix.jpg",
        "assets/images/dailyfix2.jpg",
        "assets/images/dailyfix3.jpg",
      ];
    } else if (category == "Scenic Views") {
      return [
        "assets/images/tasiktimah.jpg",
        "assets/images/tasiktimah2.jpg",
        "assets/images/tasiktimah3.jpg",
      ];
    } else {
      return [
        "assets/images/dailyfix.jpg",
        "assets/images/dailyfix2.jpg",
        "assets/images/dailyfix3.jpg",
      ];
    }
  }

  bool shouldShowCategory(String category) {
    if (selectedCategory == "All") {
      return true;
    }

    return category == selectedCategory;
  }

  bool shouldShowSearch(Map<String, dynamic> gem) {
    if (searchQuery.isEmpty) {
      return true;
    }

    final String title = gem["title"].toString().toLowerCase();
    final String location = gem["location"].toString().toLowerCase();
    final String category = gem["category"].toString().toLowerCase();
    final String description = gem["description"].toString().toLowerCase();

    return title.contains(searchQuery) ||
        location.contains(searchQuery) ||
        category.contains(searchQuery) ||
        description.contains(searchQuery);
  }

  double getRating(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  List<Map<String, dynamic>> getFilteredGems(List<Map<String, dynamic>> gems) {
    return gems.where((gem) {
      final String category = gem["category"] ?? "Uncategorized";
      return shouldShowCategory(category) && shouldShowSearch(gem);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("hidden_gems")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final List<Map<String, dynamic>> communityGems = [];

                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;

                    final String category =
                        data["category"] ?? "Uncategorized";

                    final List<String> galleryImages =
                        getDefaultGalleryByCategory(category);

                    communityGems.add({
                      "gemId": doc.id,
                      "title": data["placeName"] ?? "Untitled Hidden Gem",
                      "location": data["destination"] ?? "Malaysia",
                      "category": category,
                      "description":
                          data["description"] ?? "No description provided yet.",
                      "rating": getRating(data["rating"]),
                      "imagePath": galleryImages.first,
                      "galleryImages": galleryImages,
                      "isCommunitySubmission": true,
                    });
                  }
                }

                final List<Map<String, dynamic>> filteredStaticGems =
                    getFilteredGems(staticGems);

                final List<Map<String, dynamic>> filteredCommunityGems =
                    getFilteredGems(communityGems);

                final bool hasNoResults =
                    filteredStaticGems.isEmpty && filteredCommunityGems.isEmpty;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    if (hasNoResults)
                      _buildEmptyState()
                    else ...[
                      if (filteredStaticGems.isNotEmpty) ...[
                        _buildSectionTitle(
                          title: "Featured Hidden Gems",
                          subtitle: "${filteredStaticGems.length} places",
                        ),

                        const SizedBox(height: 12),

                        ...filteredStaticGems.map((gem) {
                          return _buildGemCard(gem);
                        }),
                      ],

                      if (filteredCommunityGems.isNotEmpty) ...[
                        const SizedBox(height: 8),

                        _buildSectionTitle(
                          title: "Community Discoveries",
                          subtitle: "${filteredCommunityGems.length} shared",
                        ),

                        const SizedBox(height: 12),

                        ...filteredCommunityGems.map((gem) {
                          return _buildGemCard(gem);
                        }),
                      ],
                    ],
                  ],
                );
              },
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 159, 153, 131),
            headerColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [


                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hidden Gems",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: darkColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Discover local places worth exploring",
                          style: TextStyle(
                            fontSize: 13,
                            color: darkColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddHiddenGemPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: darkColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search by place, state or category...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: primaryColor,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: textGrey,
                            ),
                            onPressed: () {
                              searchController.clear();
                            },
                          )
                        : null,
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
              ),

              const SizedBox(height: 18),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip("All", Icons.explore_outlined),
                    _buildCategoryChip("Nature", Icons.park_outlined),
                    _buildCategoryChip(
                      "Food & Beverages",
                      Icons.restaurant_outlined,
                    ),
                    _buildCategoryChip("Culture", Icons.museum_outlined),
                    _buildCategoryChip("Scenic Views", Icons.landscape_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, IconData icon) {
    final bool isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : darkColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGemCard(Map<String, dynamic> gem) {
    return GemCard(
      gemId: gem["gemId"],
      title: gem["title"],
      location: gem["location"],
      category: gem["category"],
      description: gem["description"],
      rating: getRating(gem["rating"]),
      imagePath: gem["imagePath"],
      galleryImages: List<String>.from(gem["galleryImages"]),
      isCommunitySubmission: gem["isCommunitySubmission"] == true,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_outlined,
              color: primaryColor,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No hidden gems found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try another keyword or category.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textGrey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Unable to load hidden gems: $error",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}