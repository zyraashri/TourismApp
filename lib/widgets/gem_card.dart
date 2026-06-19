import 'package:flutter/material.dart';

import '../screens/hidden_gems/gem_details_page.dart';

class GemCard extends StatelessWidget {
  final String gemId;
  final String title;
  final String location;
  final String category;
  final String description;
  final double rating;
  final String imagePath;
  final List<String> galleryImages;
  final bool isCommunitySubmission;

  const GemCard({
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

  static const Color primaryColor = Color(0xFF3F646C);
  static const Color darkColor = Color(0xFF384345);
  static const Color textGrey = Color(0xFF7A7A7A);

  String get ratingText {
    if (rating <= 0) {
      return "New";
    }

    if (isCommunitySubmission) {
      return "${rating.toStringAsFixed(0)} (1)";
    }

    return rating.toStringAsFixed(1);
  }

  IconData get categoryIcon {
    if (category == "Nature") {
      return Icons.park_outlined;
    } else if (category == "Food & Beverages") {
      return Icons.restaurant_outlined;
    } else if (category == "Culture") {
      return Icons.museum_outlined;
    } else if (category == "Scenic Views") {
      return Icons.landscape_outlined;
    } else {
      return Icons.place_outlined;
    }
  }

  void openDetailsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GemDetailsPage(
          gemId: gemId,
          title: title,
          location: location,
          category: category,
          description: description,
          rating: rating,
          imagePath: imagePath,
          galleryImages: galleryImages.isEmpty ? [imagePath] : galleryImages,
          isCommunitySubmission: isCommunitySubmission,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openDetailsPage(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 185,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 185,
                        width: double.infinity,
                        color: const Color(0xFFD9D9D9),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: textGrey,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(26),
                        topRight: Radius.circular(26),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          categoryIcon,
                          size: 14,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          category,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ratingText,
                          style: const TextStyle(
                            color: darkColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            color: darkColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      if (isCommunitySubmission)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7EAB6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            "Community",
                            style: TextStyle(
                              color: darkColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE8E4D8),
                        ),
                      ),

                      const SizedBox(width: 12),

                      GestureDetector(
                        onTap: () {
                          openDetailsPage(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: darkColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "View Details",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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