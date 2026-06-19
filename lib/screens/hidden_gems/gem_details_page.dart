import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'write_review_page.dart';

class GemDetailsPage extends StatefulWidget {
  final String gemId;
  final String title;
  final String location;
  final String category;
  final String description;
  final double rating;
  final String imagePath;
  final List<String> galleryImages;
  final bool isCommunitySubmission;

  const GemDetailsPage({
    super.key,
    required this.gemId,
    required this.title,
    required this.location,
    required this.category,
    required this.description,
    required this.rating,
    required this.imagePath,
    this.galleryImages = const [],
    this.isCommunitySubmission = false,
  });

  @override
  State<GemDetailsPage> createState() => _GemDetailsPageState();
}

class _GemDetailsPageState extends State<GemDetailsPage> {
  int currentImageIndex = 0;
  final PageController imagePageController = PageController();

  static const Color backgroundColor = Color(0xFFFCF8EF);
  static const Color primaryColor = Color(0xFF3F646C);
  static const Color darkColor = Color(0xFF384345);
  static const Color textGrey = Color(0xFF7A7A7A);
  static const Color softYellow = Color(0xFFF7EAB6);

  List<String> get images {
    if (widget.galleryImages.isNotEmpty) {
      return widget.galleryImages;
    }
    return [widget.imagePath];
  }

  @override
void dispose() {
  imagePageController.dispose();
  super.dispose();
}

  String get ratingText {
    if (widget.isCommunitySubmission) {
      return "${widget.rating.toStringAsFixed(0)} (1)";
    }

    return "${widget.rating.toStringAsFixed(1)} (47)";
  }

  String get reviewSectionTitle {
    if (widget.isCommunitySubmission) {
      return "Your Rating";
    }

    return "Reviews";
  }

  IconData get categoryIcon {
    if (widget.category == "Nature") {
      return Icons.park_outlined;
    } else if (widget.category == "Food & Beverages") {
      return Icons.restaurant_outlined;
    } else if (widget.category == "Culture") {
      return Icons.museum_outlined;
    } else if (widget.category == "Scenic Views") {
      return Icons.landscape_outlined;
    } else {
      return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageHeader(),

            Transform.translate(
              offset: const Offset(0, -34),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    _buildMainInfoCard(),

                    const SizedBox(height: 18),

                    _buildDescriptionCard(),

                    const SizedBox(height: 22),

                    _buildReviewsSection(),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildImageHeader() {
    return Stack(
      children: [
        SizedBox(
          height: 355,
          width: double.infinity,
          child: PageView.builder(
  controller: imagePageController,
  itemCount: images.length,
  physics: const PageScrollPhysics(),
  onPageChanged: (index) {
    setState(() {
      currentImageIndex = index;
    });
  },
            itemBuilder: (context, index) {
              return Image.asset(
                images[index],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFD9D9D9),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: textGrey,
                      size: 45,
                    ),
                  );
                },
              );
            },
          ),
        ),

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.20),
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 45,
          left: 18,
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.92),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: darkColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),

if (images.length > 1)
  Positioned(
    left: 16,
    top: 165,
    child: CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.chevron_left,
          color: darkColor,
          size: 30,
        ),
        onPressed: () {
          if (currentImageIndex > 0) {
            imagePageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
      ),
    ),
  ),

if (images.length > 1)
  Positioned(
    right: 16,
    top: 165,
    child: CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.chevron_right,
          color: darkColor,
          size: 30,
        ),
        onPressed: () {
          if (currentImageIndex < images.length - 1) {
            imagePageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
      ),
    ),
  ),

        Positioned(
          top: 48,
          right: 18,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Text(
                  ratingText,
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          left: 22,
          right: 22,
          bottom: 62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.redAccent,
                    size: 19,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 18,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentImageIndex == index ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentImageIndex == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  categoryIcon,
                  color: primaryColor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.isCommunitySubmission
                          ? "Community submitted gem"
                          : "Featured hidden gem",
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: softYellow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ratingText,
                      style: const TextStyle(
                        color: darkColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            height: 1,
            color: const Color(0xFFE8E4D8),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _buildInfoPill(
                icon: Icons.explore_outlined,
                label: "Local Pick",
              ),
              const SizedBox(width: 10),
              _buildInfoPill(
                icon: Icons.camera_alt_outlined,
                label: "Photo Spot",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8E4D8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 17,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: darkColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.20),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notes_outlined,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "About this place",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            widget.description,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              reviewSectionTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),

            const Spacer(),

            if (!widget.isCommunitySubmission)
              TextButton.icon(
                onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => WriteReviewPage(
        gemId: widget.gemId,
        gemTitle: widget.title,
      ),
    ),
  );
},
                icon: const Icon(
                  Icons.edit,
                  size: 16,
                  color: primaryColor,
                ),
                label: const Text(
                  "Write a review",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (widget.isCommunitySubmission)
          ReviewCard(
            rating: widget.rating.round(),
            review: "Rated by You",
            time: "New submission",
          )
        else ...[
  const ReviewCard(
    rating: 5,
    review: "Amazing place",
    time: "7 hours ago",
  ),
  const ReviewCard(
    rating: 4,
    review: "Good coffee but limited parking",
    time: "2 days ago",
  ),
  const ReviewCard(
    rating: 5,
    review: "Great environment",
    time: "1 week ago",
  ),

  StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("hidden_gem_reviews")
        .where("gemId", isEqualTo: widget.gemId)
        .orderBy("createdAt", descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const SizedBox();
      }

      if (!snapshot.hasData) {
        return const SizedBox();
      }

      final reviews = snapshot.data!.docs;

      return Column(
        children: reviews.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return ReviewCard(
            rating: data["rating"] ?? 0,
            review: data["review"] ?? "",
            time: "By ${data["reviewerName"] ?? "You"}",
          );
        }).toList(),
      );
    },
  ),
],
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final int rating;
  final String review;
  final String time;

  const ReviewCard({
    super.key,
    required this.rating,
    required this.review,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3F646C);
    const Color darkColor = Color(0xFF384345);
    const Color textGrey = Color(0xFF7A7A7A);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8E4D8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: darkColor,
              size: 28,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  review,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            time,
            style: const TextStyle(
              color: textGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}