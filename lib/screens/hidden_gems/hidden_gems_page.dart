import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
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

  Future<void> seedDummyReviews() async {
    final reviews = [
      {
        "docId": "kopi_review_1",
        "gemId": "kopi_hutan_cafe",
        "gemTitle": "Kopi Hutan Cafe",
        "rating": 5,
        "review":
            "The coffee was great and the forest view made it feel relaxing.",
        "reviewerName": "Aina Rahman",
      },
      {
        "docId": "kopi_review_2",
        "gemId": "kopi_hutan_cafe",
        "gemTitle": "Kopi Hutan Cafe",
        "rating": 4,
        "review":
            "Nice hidden cafe, but it can get a bit crowded during weekends.",
        "reviewerName": "Daniel Lee",
      },
      {
        "docId": "tasik_review_1",
        "gemId": "tasik_timah_tasoh",
        "gemTitle": "Tasik Timah Tasoh",
        "rating": 5,
        "review":
            "Beautiful lake view and a calm place to take photos during sunset.",
        "reviewerName": "Nur Iman",
      },
      {
        "docId": "tasik_review_2",
        "gemId": "tasik_timah_tasoh",
        "gemTitle": "Tasik Timah Tasoh",
        "rating": 4,
        "review":
            "The scenery is lovely and suitable for a short relaxing trip.",
        "reviewerName": "Amir Hakim",
      },
      {
        "docId": "dailyfix_review_1",
        "gemId": "the_daily_fix_cafe",
        "gemTitle": "The Daily Fix Cafe",
        "rating": 5,
        "review":
            "The cafe has a cozy heritage vibe and the food was really nice.",
        "reviewerName": "Mei Ling",
      },
      {
        "docId": "dailyfix_review_2",
        "gemId": "the_daily_fix_cafe",
        "gemTitle": "The Daily Fix Cafe",
        "rating": 4,
        "review":
            "Aesthetic place with good desserts, but the waiting time was quite long.",
        "reviewerName": "Sofia Zain",
      },
    ];

    for (final review in reviews) {
      await FirebaseFirestore.instance
          .collection("hidden_gem_reviews")
          .doc(review["docId"].toString())
          .set({
            "gemId": review["gemId"],
            "gemTitle": review["gemTitle"],
            "rating": review["rating"],
            "review": review["review"],
            "reviewerName": review["reviewerName"],
            "createdAt": FieldValue.serverTimestamp(),
          });
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dummy reviews added successfully!")),
    );
  }

  Future<void> seedSampleHiddenGems() async {
    final sampleGems = [
      {
        "docId": "sample_rumahpenghulu",
        "placeName": "Rumah Penghulu Abu Seman",
        "destination": "Kuala Lumpur",
        "category": "Culture",
        "description":
            "A traditional Malay heritage house that showcases classic architecture, cultural history, and a peaceful learning experience in the middle of the city.",
        "rating": 5.0,
        "imagePath": "assets/images/rumahpenghulu.jpg",
        "galleryImages": [
          "assets/images/rumahpenghulu.jpg",
          "assets/images/rumahpenghulu2.jpg",
          "assets/images/rumahpenghulu3.jpg",
        ],
        "photoNames": [
          "rumahpenghulu.jpg",
          "rumahpenghulu2.jpg",
          "rumahpenghulu3.jpg",
        ],
      },
      {
        "docId": "sample_kampungmorten",
        "placeName": "Kampung Morten",
        "destination": "Melaka",
        "category": "Culture",
        "description":
            "A charming traditional village surrounded by heritage homes, local stories, and beautiful night views along the Melaka River.",
        "rating": 4.0,
        "imagePath": "assets/images/kampungmorten.jpg",
        "galleryImages": [
          "assets/images/kampungmorten.jpg",
          "assets/images/kampungmorten2.jpg",
          "assets/images/kampungmorten3.jpg",
        ],
        "photoNames": [
          "kampungmorten.jpg",
          "kampungmorten2.jpg",
          "kampungmorten3.jpg",
        ],
      },
      {
        "docId": "sample_panorama",
        "placeName": "Bukit Panorama",
        "destination": "Pahang",
        "category": "Scenic Views",
        "description":
            "A peaceful hiking spot with wide sunrise views, fresh morning air, and a beautiful landscape that is perfect for photography lovers.",
        "rating": 5.0,
        "imagePath": "assets/images/panorama.jpg",
        "galleryImages": [
          "assets/images/panorama.jpg",
          "assets/images/panorama2.jpg",
          "assets/images/panorama3.jpg",
        ],
        "photoNames": ["panorama.jpg", "panorama2.jpg", "panorama3.jpg"],
      },
      {
        "docId": "sample_pantaiklebang",
        "placeName": "Pantai Klebang",
        "destination": "Melaka",
        "category": "Scenic Views",
        "description":
            "A unique sandy landscape near the coast, popular for sunset photos, open scenery, and a relaxing outdoor experience.",
        "rating": 4.0,
        "imagePath": "assets/images/pantaiklebang.jpg",
        "galleryImages": [
          "assets/images/pantaiklebang.jpg",
          "assets/images/pantaiklebang2.jpg",
          "assets/images/pantaiklebang3.jpg",
        ],
        "photoNames": [
          "pantaiklebang.jpg",
          "pantaiklebang2.jpg",
          "pantaiklebang3.jpg",
        ],
      },
      {
        "docId": "sample_lata",
        "placeName": "Lata Iskandar Waterfall",
        "destination": "Perak",
        "category": "Nature",
        "description":
            "A refreshing waterfall surrounded by greenery, perfect for a short nature stop, peaceful views, and relaxing sounds of flowing water.",
        "rating": 5.0,
        "imagePath": "assets/images/lata.jpg",
        "galleryImages": [
          "assets/images/lata.jpg",
          "assets/images/lata2.jpg",
          "assets/images/lata3.jpg",
        ],
        "photoNames": ["lata.jpg", "lata2.jpg", "lata3.jpg"],
      },
    ];

    for (final gem in sampleGems) {
      await FirebaseFirestore.instance
          .collection("hidden_gems")
          .doc(gem["docId"].toString())
          .set({
            "placeName": gem["placeName"],
            "destination": gem["destination"],
            "category": gem["category"],
            "description": gem["description"],
            "rating": gem["rating"],
            "imagePath": gem["imagePath"],
            "galleryImages": gem["galleryImages"],
            "reviewCount": 1,
            "status": "approved",
            "hasPhoto": true,
            "photoCount": 3,
            "photoNames": gem["photoNames"],
            "photoStatus": "sample",
            "createdAt": FieldValue.serverTimestamp(),
          });
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sample hidden gems added successfully!")),
    );
  }

  Future<void> seedSampleGemReviews() async {
    final reviews = [
      {
        "docId": "rumahpenghulu_review_1",
        "gemId": "sample_rumahpenghulu",
        "gemTitle": "Rumah Penghulu Abu Seman",
        "rating": 5,
        "review":
            "A beautiful traditional house with strong cultural value and peaceful surroundings.",
        "reviewerName": "Aina Rahman",
      },
      {
        "docId": "rumahpenghulu_review_2",
        "gemId": "sample_rumahpenghulu",
        "gemTitle": "Rumah Penghulu Abu Seman",
        "rating": 4,
        "review":
            "Interesting place to learn about Malay architecture and heritage.",
        "reviewerName": "Hakim Zain",
      },
      {
        "docId": "kampungmorten_review_1",
        "gemId": "sample_kampungmorten",
        "gemTitle": "Kampung Morten",
        "rating": 4,
        "review":
            "The village has a charming heritage atmosphere, especially in the evening.",
        "reviewerName": "Sofia Amir",
      },
      {
        "docId": "kampungmorten_review_2",
        "gemId": "sample_kampungmorten",
        "gemTitle": "Kampung Morten",
        "rating": 5,
        "review":
            "A lovely cultural stop with traditional houses and beautiful river views.",
        "reviewerName": "Daniel Lee",
      },
      {
        "docId": "panorama_review_1",
        "gemId": "sample_panorama",
        "gemTitle": "Bukit Panorama",
        "rating": 5,
        "review":
            "The sunrise view was amazing and worth the early morning hike.",
        "reviewerName": "Nur Iman",
      },
      {
        "docId": "panorama_review_2",
        "gemId": "sample_panorama",
        "gemTitle": "Bukit Panorama",
        "rating": 5,
        "review":
            "Perfect place for nature lovers and photography. The scenery is stunning.",
        "reviewerName": "Amir Hakim",
      },
      {
        "docId": "pantaiklebang_review_1",
        "gemId": "sample_pantaiklebang",
        "gemTitle": "Pantai Klebang Sand Dunes",
        "rating": 4,
        "review": "Unique sandy landscape and a nice place for sunset photos.",
        "reviewerName": "Mei Ling",
      },
      {
        "docId": "pantaiklebang_review_2",
        "gemId": "sample_pantaiklebang",
        "gemTitle": "Pantai Klebang Sand Dunes",
        "rating": 5,
        "review":
            "The view is beautiful and different from usual beach spots in Melaka.",
        "reviewerName": "Farah Nabila",
      },
      {
        "docId": "lata_review_1",
        "gemId": "sample_lata",
        "gemTitle": "Lata Iskandar Waterfall",
        "rating": 5,
        "review":
            "Refreshing waterfall with peaceful nature sounds and cool air.",
        "reviewerName": "Adam Danish",
      },
      {
        "docId": "lata_review_2",
        "gemId": "sample_lata",
        "gemTitle": "Lata Iskandar Waterfall",
        "rating": 4,
        "review":
            "Nice place for a short nature stop. The waterfall view is relaxing.",
        "reviewerName": "Irdina Maisarah",
      },
    ];

    for (final review in reviews) {
      await FirebaseFirestore.instance
          .collection("hidden_gem_reviews")
          .doc(review["docId"].toString())
          .set({
            "gemId": review["gemId"],
            "gemTitle": review["gemTitle"],
            "rating": review["rating"],
            "review": review["review"],
            "reviewerName": review["reviewerName"],
            "createdAt": FieldValue.serverTimestamp(),
          });
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sample hidden gem reviews added successfully!"),
      ),
    );
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
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final List<Map<String, dynamic>> communityGems = [];

                if (snapshot.hasData) {
                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;

                    final String category = data["category"] ?? "Uncategorized";

                    List<String> galleryImages = getDefaultGalleryByCategory(
                      category,
                    );

                    if (data["galleryImages"] is List &&
                        (data["galleryImages"] as List).isNotEmpty) {
                      galleryImages = List<String>.from(data["galleryImages"]);
                    }

                    final String imagePath =
                        data["imagePath"]?.toString() ?? galleryImages.first;

                    final String submissionType =
                        data["submissionType"]?.toString() ?? "";

                    final bool isSampleGem =
                        submissionType == "sample" ||
                        data["photoStatus"] == "sample" ||
                        doc.id.startsWith("sample_");

                    final bool isUserSubmission =
                        submissionType == "user" ||
                        data["photoStatus"] == "selected" ||
                        (!isSampleGem && !doc.id.startsWith("sample_"));

                    communityGems.add({
                      "gemId": doc.id,
                      "title": data["placeName"] ?? "Untitled Hidden Gem",
                      "location": data["destination"] ?? "Malaysia",
                      "category": category,
                      "description":
                          data["description"] ?? "No description provided yet.",
                      "rating": getRating(data["rating"]),
                      "imagePath": imagePath,
                      "galleryImages": galleryImages,
                      "isCommunitySubmission": true,
                      "isUserSubmission": isUserSubmission,
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

      bottomNavigationBar: const QuestBottomNavBar(activePage: 'hiddenGems'),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromARGB(255, 159, 153, 131), headerColor],
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
                          style: TextStyle(fontSize: 13, color: darkColor),
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
                    prefixIcon: const Icon(Icons.search, color: primaryColor),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: textGrey),
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
                    _buildCategoryChip(
                      "Scenic Views",
                      Icons.landscape_outlined,
                    ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildSectionTitle({required String title, required String subtitle}) {
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      isUserSubmission: gem["isUserSubmission"] == true,
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
            style: TextStyle(color: textGrey, fontSize: 13),
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
          style: const TextStyle(color: Colors.red, fontSize: 13),
        ),
      ),
    );
  }
}
