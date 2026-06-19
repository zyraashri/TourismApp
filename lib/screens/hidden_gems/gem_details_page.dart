import 'package:flutter/material.dart';

class GemDetailsPage extends StatefulWidget {
  final String title;
  final String location;
  final String description;
  final double rating;
  final String imagePath;
  final List<String> galleryImages;

  const GemDetailsPage({
    super.key,
    required this.title,
    required this.location,
    required this.description,
    required this.rating,
    required this.imagePath,
    this.galleryImages = const [],
  });

  @override
  State<GemDetailsPage> createState() => _GemDetailsPageState();
}

class _GemDetailsPageState extends State<GemDetailsPage> {
  int currentImageIndex = 0;

  static const Color backgroundColor = Color(0xFFFCF8EF);
  static const Color primaryColor = Color(0xFF3F646C);
  static const Color darkColor = Color(0xFF384345);
  static const Color locationTextColor = Color(0xFF354343);

  List<String> get images {
    if (widget.galleryImages.isNotEmpty) {
      return widget.galleryImages;
    }
    return [widget.imagePath];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 330,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: images.length,
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
                      );
                    },
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
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

                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentImageIndex == index ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentImageIndex == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Food & Beverages",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.location,
                        style: const TextStyle(
                          color: locationTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.star,
                        size: 15,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${widget.rating} (47)",
                        style: const TextStyle(
                          color: darkColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.description,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      const Text(
                        "Reviews",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const Spacer(),

                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.edit,
                          size: 15,
                          color: primaryColor,
                        ),
                        label: const Text(
                          "Write a review",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

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
                    time: "1 weeks ago",
                  ),

                  const SizedBox(height: 20),
                ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0EA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFBFE3F0),
            child: Icon(
              Icons.person,
              color: Color(0xFF384345),
            ),
          ),

          const SizedBox(width: 12),

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
                      size: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  review,
                  style: const TextStyle(
                    color: Color(0xFF7A7A7A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF7A7A7A),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}