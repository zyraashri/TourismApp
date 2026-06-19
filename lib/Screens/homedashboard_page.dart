import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourismapp/screens/home_page.dart';
import '../providers/homedashboard_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'home_page.dart';
import 'hidden_gems/hidden_gems_page.dart';
import 'discover_malaysia.dart';
import 'companion_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import '../profile/profile_settings_screen.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<HomeDashboardProvider>().loadDashboard();
    });
  }

  void goToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeDashboardProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(home.currentLatitude, home.currentLongitude),
        ),
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(home),
              const SizedBox(height: 16),
              Text(
                "Welcome, ${home.username}!",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(offset: Offset(0.4, 0), color: Colors.black),
                  ],
                  color: Colors.black,
                ),
              ),
              const Text(
                "Let's continue your journey",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  ClipRect(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 176,
                        height: 125,
                        child: Stack(
                          children: [
                            GoogleMap(
                              onMapCreated: (controller) {
                                _mapController = controller;
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  home.currentLatitude,
                                  home.currentLongitude,
                                ),
                                zoom: 15,
                              ),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              compassEnabled: false,
                              scrollGesturesEnabled: true,
                              zoomGesturesEnabled: true,
                              rotateGesturesEnabled: true,
                              tiltGesturesEnabled: true,
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                              markers: {
                                Marker(
                                  markerId: const MarkerId('currentLocation'),
                                  position: LatLng(
                                    home.currentLatitude,
                                    home.currentLongitude,
                                  ),
                                  infoWindow: const InfoWindow(
                                    title: "Current Location",
                                  ),
                                ),
                              },
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Column(
                                children: [
                                  _mapZoomButton(
                                    icon: Icons.add,
                                    onTap: () {
                                      _mapController?.animateCamera(
                                        CameraUpdate.zoomIn(),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 5),
                                  _mapZoomButton(
                                    icon: Icons.remove,
                                    onTap: () {
                                      _mapController?.animateCamera(
                                        CameraUpdate.zoomOut(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, 15),
                      child: Transform.scale(
                        scale: 1.3,
                        child: Image.asset(
                          'assets/images/traveller.png',
                          height: 135,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _travelOverview(home),
              const SizedBox(height: 16),
              _upcomingAdventure(context, home),
              const SizedBox(height: 16),
              _continueQuest(context, home),
              const SizedBox(height: 16),
              _recommendedDestination(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNavBar(context),
    );
  }

  Widget _mapZoomButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(icon, size: 17, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _topBar(HomeDashboardProvider home) {
    return Row(
      children: [
        Image.asset('assets/images/logo.png', height: 32),
        const SizedBox(width: 8),
        const Text(
          "QuestMY",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        const Icon(Icons.notifications_none, size: 28),
        const SizedBox(width: 12),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
            );
          },
          child: CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFFBFD8E7),
            backgroundImage: home.profileImageUrl.isNotEmpty
                ? NetworkImage(home.profileImageUrl)
                : null,
            child: home.profileImageUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _travelOverview(HomeDashboardProvider home) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF304241),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 12),
            child: Text(
              "Travel Overview",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _overviewItem(
                'assets/images/airport.png',
                "Trips Planned",
                home.tripsPlanned.toString(),
              ),
              _overviewItem(
                'assets/images/visiting.png',
                "Places Visited",
                home.placesVisited.toString(),
              ),
              _overviewItem(
                'assets/images/badges.png',
                "Badges Earned",
                home.badgesEarned.toString(),
              ),
              _overviewItem(
                'assets/images/reviews.png',
                "Reviews Shared",
                home.reviewsShared.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewItem(String imagePath, String title, String value) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: Color(0xFFF6E7A6),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _upcomingAdventure(BuildContext context, HomeDashboardProvider home) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Upcoming Adventure"),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 95,
                height: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/afamosa.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -2),
                  child: Container(
                    height: 110,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          home.upcomingTripTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          home.upcomingTripDateDisplay,
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          home.upcomingTripDestination,
                          style: const TextStyle(fontSize: 11),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => goToPage(context, const HomePage()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF6E7A6),
                            foregroundColor: Colors.black,
                            minimumSize: const Size(95, 24),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "View Itinerary",
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _continueQuest(BuildContext context, HomeDashboardProvider home) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Continue Your Quest"),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 95,
                height: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/stadthuysmelaka.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -2),
                  child: Container(
                    height: 110,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          home.currentQuestTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text("Progress", style: TextStyle(fontSize: 11)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: const LinearProgressIndicator(
                                  value: 0.67,
                                  minHeight: 8,
                                  backgroundColor: Color(0xFFE5E5E5),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF5B9BD5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              home.currentQuestProgress,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () =>
                              goToPage(context, const DiscoverMalaysiaPage()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF6E7A6),
                            foregroundColor: Colors.black,
                            minimumSize: const Size(95, 24),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Continue Quest",
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recommendedDestination(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Recommended Destination"),
          const SizedBox(height: 10),
          SizedBox(
            height: 115,
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/market.jpg',
                    width: double.infinity,
                    height: 115,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 115,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Various Night Market Food",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Complete nearby quests, try local delicacies,\nand discover community-recommended spots.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () {
                            goToPage(context, const HiddenGemsPage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Text(
                            "Explore Now",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavBar(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem('assets/images/home.png', "Home", true, () {}),

          _navItem(
            'assets/images/planner.png',
            "Planner",
            false,
            () => goToPage(context, const HomePage()),
          ),

          _navItem(
            'assets/images/hiddengems.png',
            "Hidden Gems",
            false,
            () => goToPage(context, const HiddenGemsPage()),
          ),

          _navItem(
            'assets/images/quest.png',
            "Quests",
            false,
            () => goToPage(context, const DiscoverMalaysiaPage()),
          ),

          _navItem(
            'assets/images/companion.png',
            "Companion",
            false,
            () => goToPage(context, const CompanionPage()),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    String imagePath,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFB7C0BD) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Image.asset(imagePath, width: 25, height: 25, fit: BoxFit.contain),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 8)),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    );
  }
}
