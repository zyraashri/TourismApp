import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/smartcompanion_provider.dart';

class CompanionPage extends StatefulWidget {
  const CompanionPage({super.key});

  @override
  State<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SmartCompanionProvider>().loadCompanionData();
    });
  }

  void goToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget placeImage(
    CompanionPlace item, {
    required double width,
    required double height,
  }) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return Image.network(
        item.imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            item.imagePath,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported),
              );
            },
          );
        },
      );
    }

    return Image.asset(
      item.imagePath,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: const Icon(Icons.image_not_supported),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final companion = Provider.of<SmartCompanionProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topSection(companion),
              const SizedBox(height: 0),
              _nearbyAttractions(companion),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _restaurantCard(companion)),
                    const SizedBox(width: 12),
                    Expanded(child: _eventCard(companion)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _travelAlerts(companion),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const QuestBottomNavBar(activePage: 'companion'),
    );
  }

  Widget _topSection(SmartCompanionProvider companion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/standing.png',
          width: 90,
          height: 300,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Current Spot !",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _infoPill(
                        icon: Icons.location_on,
                        text: companion.currentLocationName,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _weatherPill(companion),
                  ],
                ),
                const SizedBox(height: 14),
                _smartCompanionCard(companion),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoPill({required IconData icon, required String text}) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E7A6),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: const Color(0xFF304241)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherPill(SmartCompanionProvider companion) {
    return Container(
      height: 36,
      width: 72,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E7A6),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, color: Colors.orange, size: 18),
          const SizedBox(width: 4),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                companion.temperature,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                companion.weatherCondition,
                style: const TextStyle(fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smartCompanionCard(SmartCompanionProvider companion) {
    final firstPlace = companion.nearbyAttractions.first;
    final saved = companion.isSaved(firstPlace);

    return _card(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy, size: 15),
              SizedBox(width: 6),
              Text(
                "Smart Travel Companion",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 88,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF46676A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    companion.companionMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: placeImage(firstPlace, width: 104, height: 88),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _smallYellowButton(
                  text: "Explore Now",
                  iconPath: "assets/images/arrow.png",
                  iconOnRight: true,
                  onTap: () {
                    goToPage(context, CompanionDetailsPage(place: firstPlace));
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _smallYellowButton(
                  text: saved ? "Saved" : "Save Suggestion",
                  iconPath: "assets/images/bookmark.png",
                  backgroundColor: saved
                      ? Colors.red.shade100
                      : const Color(0xFFF6E7A6),
                  textColor: saved
                      ? const Color.fromARGB(255, 177, 12, 0)
                      : Colors.black,
                  onTap: () {
                    companion.saveSuggestion(firstPlace, "AI Suggestion");
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nearbyAttractions(SmartCompanionProvider companion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          "Nearby Attractions",
          "assets/images/tourist.png",
          "See All >",
          () {
            goToPage(
              context,
              CompanionListPage(
                title: "Nearby Attractions",
                places: companion.nearbyAttractions,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: companion.nearbyAttractions.take(4).map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _attractionItem(item),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _attractionItem(CompanionPlace item) {
    return GestureDetector(
      onTap: () {
        goToPage(context, CompanionDetailsPage(place: item));
      },
      child: Container(
        height: 135,
        padding: const EdgeInsets.all(5),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: placeImage(item, width: double.infinity, height: 70),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF46676A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.distance ?? "Nearby",
                      style: const TextStyle(color: Colors.white, fontSize: 6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
            ),
            Text("⭐ ${item.subtitle}", style: const TextStyle(fontSize: 7)),
          ],
        ),
      ),
    );
  }

  Widget _restaurantCard(SmartCompanionProvider companion) {
    return _listCard(
      title: "Nearby Restaurants",
      items: companion.filteredRestaurants,
      category: "Restaurant",
      provider: companion,
    );
  }

  Widget _eventCard(SmartCompanionProvider companion) {
    return _listCard(
      title: "Nearby Events",
      items: companion.filteredEvents,
      category: "Event",
      provider: companion,
    );
  }

  Widget _listCard({
    required String title,
    required List<CompanionPlace> items,
    required String category,
    required SmartCompanionProvider provider,
  }) {
    return _card(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowTitle(
            title,
            category == "Event"
                ? "assets/images/event.png"
                : "assets/images/cutlery.png",
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _clickableFilterChip("All", category, provider),
              _clickableFilterChip(
                category == "Event" ? "Free" : "Halal",
                category,
                provider,
              ),
              _clickableFilterChip(
                category == "Event" ? "Today" : "Cafe",
                category,
                provider,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text("No result found", style: TextStyle(fontSize: 9)),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _smallListItem(item, provider, category),
              ),
            ),
        ],
      ),
    );
  }

  Widget _clickableFilterChip(
    String text,
    String category,
    SmartCompanionProvider provider,
  ) {
    final selected = category == "Event"
        ? provider.selectedEventFilter == text
        : provider.selectedRestaurantFilter == text;

    return GestureDetector(
      onTap: () {
        if (category == "Event") {
          provider.updateEventFilter(text);
        } else {
          provider.updateRestaurantFilter(text);
        }
      },
      child: _filterChip(text, selected),
    );
  }

  Widget _smallListItem(
    CompanionPlace item,
    SmartCompanionProvider provider,
    String category,
  ) {
    final saved = provider.isSaved(item);

    return GestureDetector(
      onTap: () {
        goToPage(context, CompanionDetailsPage(place: item));
      },
      child: SizedBox(
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 58,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  item.imagePath,
                  width: 58,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, size: 18),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: SizedBox(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    Text(item.subtitle, style: const TextStyle(fontSize: 7)),

                    GestureDetector(
                      onTap: () => provider.saveSuggestion(item, category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6E7A6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              saved ? Icons.favorite : Icons.favorite_border,
                              size: 9,
                              color: saved ? Colors.red : Colors.black,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              saved ? "Saved" : "Save",
                              style: TextStyle(
                                fontSize: 7,
                                color: saved ? Colors.red : Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _travelAlerts(SmartCompanionProvider companion) {
    return _card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset("assets/images/traffic.png", width: 18, height: 18),
              const SizedBox(width: 6),
              const Text(
                "Travel Alerts",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: companion.travelAlerts.take(2).map((alert) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _alertBox(alert),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _alertBox(TravelAlert alert) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E7A6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  alert.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 7),
                ),
              ],
            ),
          ),
          Image.asset(alert.imagePath, width: 34, height: 34),
        ],
      ),
    );
  }

  Widget _rowTitle(String title, String iconPath) {
    return Row(
      children: [
        Image.asset(iconPath, width: 16, height: 16),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(
    String title,
    String iconPath,
    String action,
    VoidCallback onTap,
  ) {
    return Row(
      children: [
        Image.asset(iconPath, width: 18, height: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String text, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF304241) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 7,
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _smallYellowButton({
    required String text,
    required String iconPath,
    required VoidCallback onTap,
    bool iconOnRight = false,
    Color backgroundColor = const Color(0xFFF6E7A6),
    Color textColor = Colors.black,
  }) {
    Widget buttonIcon() {
      if (iconPath.contains("bookmark")) {
        return Icon(Icons.bookmark_border, size: 10, color: textColor);
      }

      if (iconPath.contains("arrow")) {
        return Icon(Icons.arrow_forward_ios, size: 10, color: textColor);
      }

      return Image.asset(
        iconPath,
        width: 10,
        height: 10,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.arrow_forward_ios, size: 10, color: textColor);
        },
      );
    }

    return SizedBox(
      height: 28,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!iconOnRight) ...[buttonIcon(), const SizedBox(width: 3)],
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              if (iconOnRight) ...[const SizedBox(width: 3), buttonIcon()],
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: _boxDecoration(),
      child: child,
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.16),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class CompanionDetailsPage extends StatefulWidget {
  final CompanionPlace place;

  const CompanionDetailsPage({super.key, required this.place});

  @override
  State<CompanionDetailsPage> createState() => _CompanionDetailsPageState();
}

class CompanionListPage extends StatelessWidget {
  final String title;
  final List<CompanionPlace> places;

  const CompanionListPage({
    super.key,
    required this.title,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4EC),
        title: Text(title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: place.imageUrl != null && place.imageUrl!.isNotEmpty
                  ? Image.network(place.imageUrl!, width: 60, fit: BoxFit.cover)
                  : Image.asset(place.imagePath, width: 60, fit: BoxFit.cover),
              title: Text(place.title),
              subtitle: Text(place.subtitle),
              trailing: Text(place.distance ?? ""),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompanionDetailsPage(place: place),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CompanionDetailsPageState extends State<CompanionDetailsPage> {
  bool isLoading = true;
  String aiContent = "";

  @override
  void initState() {
    super.initState();
    _loadAIContent();
  }

  Future<void> _loadAIContent() async {
    final provider = context.read<SmartCompanionProvider>();

    final result = await provider.generatePlaceDetails(widget.place);

    if (!mounted) return;

    setState(() {
      aiContent = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4EC),
        elevation: 0,
        centerTitle: true,
        title: Text(
          place.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: place.imageUrl != null && place.imageUrl!.isNotEmpty
                  ? Image.network(
                      place.imageUrl!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          place.imagePath,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      place.imagePath,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(height: 18),

            Text(
              place.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 6),

            Text(place.subtitle, style: const TextStyle(fontSize: 13)),

            if (place.distance != null) ...[
              const SizedBox(height: 6),

              Text(
                "📍 ${place.distance}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF46676A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.smart_toy, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "AI Travel Guide",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Text(
                      aiContent,
                      style: const TextStyle(fontSize: 13, height: 1.6),
                    ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
