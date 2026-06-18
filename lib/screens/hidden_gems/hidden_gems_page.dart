import 'package:flutter/material.dart';
import '../../widgets/gem_card.dart';

class HiddenGemsPage extends StatefulWidget {
  const HiddenGemsPage({super.key});

  @override
  State<HiddenGemsPage> createState() =>
      _HiddenGemsPageState();
}

class _HiddenGemsPageState
    extends State<HiddenGemsPage> {

  String selectedCategory = "Nature";

  static const Color backgroundColor = Color(0xFFFCF8EF);
  static const Color headerColor = Color(0xFFF7EAB6);
  static const Color primaryColor = Color(0xFF3F646C);
  static const Color darkColor = Color(0xFF384345);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              20,
              50,
              20,
              20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(
                    255,
                    159,
                    153,
                    131,
                  ),
                  Color(0xFFF7EAB6),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Hidden Gems",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight:
                              FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add,
                        size: 30,
                        color: darkColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon:
                        const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.zero,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(
                        Icons.park,
                        "Nature",
                      ),

                      _buildCategoryChip(
                        Icons.restaurant,
                        "Food & Beverages",
                      ),

                      _buildCategoryChip(
                        Icons.museum,
                        "Culture",
                      ),

                      _buildCategoryChip(
                        Icons.landscape,
                        "Scenic Views",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: const [
                GemCard(
                  title:
                      "Tasik Timah Tasoh",
                  location: "Perlis",
                  description:
                      "Beautiful hidden place that offers breathtaking scenery.",
                  rating: 4.7,
                  imagePath:
                      "assets/images/tasiktimah.jpg",
                ),

                GemCard(
                  title:
                      "Kopi Hutan Cafe",
                  location: "Penang",
                  description:
                      "A hidden gem café surrounded by nature and great coffee.",
                  rating: 5.0,
                  imagePath:
                      "assets/images/kopihutan.jpg",
                ),

                GemCard(
                  title:
                      "The Daily Fix",
                  location: "Melaka",
                  description:
                      "One of the most unique cafés hidden behind a souvenir shop.",
                  rating: 4.9,
                  imagePath:
                      "assets/images/dailyfix.jpg",
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar:
          BottomNavigationBar(
        selectedItemColor:
            primaryColor,
        unselectedItemColor:
            Colors.grey,
        currentIndex: 2,
        type:
            BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon:
                Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.event_note),
            label: "Planner",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.diamond_outlined,
            ),
            label: "Hidden Gems",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.emoji_events_outlined,
            ),
            label: "Quests",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.support_agent_outlined,
            ),
            label: "Companion",
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    IconData icon,
    String label,
  ) {
    bool isSelected =
        selectedCategory == label;

    return Padding(
      padding:
          const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = label;
          });
        },
        child: Chip(
          backgroundColor: isSelected
              ? primaryColor
              : Colors.white,

          side: BorderSide(
            color: isSelected
                ? primaryColor
                : Colors.grey.shade300,
          ),

          label: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : darkColor,
              ),

              const SizedBox(width: 4),

              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : darkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}