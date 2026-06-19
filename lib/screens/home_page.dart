import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_models.dart';
import 'create_trip_page.dart';
import 'trip_dashboard.dart';
import '../services/firebase_service.dart';
import '../profile/profile_settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1; // Defaulted directly to the Planner Tab
  String _activeFilter = 'Active'; // Tracks 'Active' plans vs 'History'
  
  final FirebaseService _firebaseService = FirebaseService();

  void _editTripDialog(BuildContext context, String docId, String currentDestination) {
    final TextEditingController editController = TextEditingController(text: currentDestination);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Destination'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: 'Enter new destination'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              if (editController.text.isNotEmpty) {
                await _firebaseService.updateTripData(docId, {'destination': editController.text});
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF2E3D39), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _deleteTripDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Trip Profile?'),
        content: const Text('This will permanently clear this profile from the cloud.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await _firebaseService.deleteTrip(docId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildHomeTabView() {
    return const Center(child: Text('Main Feed / Dashboard View', style: TextStyle(fontSize: 18, color: Color(0xFF2E3D39))));
  }

  // Live Firebase Connected Planner View Layout
  Widget _buildPlannerTabView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Smart Journey Planner',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2E3D39), letterSpacing: -0.5),
          ),
          Text(
            'Coordinate details, routes, and personal budgets effortlessly.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          
          // Navigation Filter Toggle Elements
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _activeFilter = 'Active'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _activeFilter == 'Active' ? const Color(0xFF2E3D39) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _activeFilter == 'Active' ? Colors.transparent : Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Active Plans',
                    style: TextStyle(color: _activeFilter == 'Active' ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _activeFilter = 'History'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _activeFilter == 'History' ? const Color(0xFF2E3D39) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _activeFilter == 'History' ? Colors.transparent : Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Travel History',
                    style: TextStyle(color: _activeFilter == 'History' ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Bulletproof Live Firebase Stream Reader Engine
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firebaseService.getTripsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF2E3D39)));
                }
                
                List<Trip> mappedTrips = [];
                List<String> docIds = [];

                if (snapshot.hasData) {
                  for (var rawData in snapshot.data!) {
                    String dest = rawData['destination'] ?? 'Unknown Location';
                    String startStr = rawData['startDate'] ?? DateTime.now().toIso8601String();
                    String endStr = rawData['endDate'] ?? DateTime.now().toIso8601String();

                    DateTime end = DateTime.parse(endStr);
                    bool isHistoryTrip = end.isBefore(DateTime.now());
                    
                    if ((_activeFilter == 'History' && isHistoryTrip) || (_activeFilter == 'Active' && !isHistoryTrip)) {
                      docIds.add(rawData['id']);
                      mappedTrips.add(Trip(
                        destination: dest,
                        startDate: DateTime.parse(startStr),
                        endDate: end,
                        budgetLimit: (rawData['budgetLimit'] as num?)?.toDouble() ?? 0.0,
                        attractions: List<String>.from(rawData['attractions'] ?? []),
                        favoriteLocations: List<String>.from(rawData['favoriteLocations'] ?? []),
                        expenses: (rawData['expenses'] as List?)?.map((e) => ExpenseItem(
                          title: e['title'] ?? 'Expense', 
                          amount: (e['amount'] as num?)?.toDouble() ?? 0.0
                        )).toList() ?? [],
                        itinerary: (rawData['itinerary'] as List?)?.map((i) => ItineraryItem(
                          dayNumber: i['dayNumber'] ?? 1, 
                          time: i['time'] ?? '00:00', 
                          description: i['description'] ?? ''
                        )).toList() ?? [],
                        imageBytes: rawData['imageBytesString'] != null ? base64Decode(rawData['imageBytesString']) : null,
                      ));
                    }
                  }
                }

                return ListView.builder(
                  itemCount: mappedTrips.length + 1,
                  itemBuilder: (context, index) {
                    if (index < mappedTrips.length) {
                      final trip = mappedTrips[index];
                      final currentDocId = docIds[index];

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => TripDashboardPage(
                                trip: trip, 
                                docId: currentDocId,
                              ),
                            ),
                          );
                          setState(() {}); 
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E3D39),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))
                            ],
                            image: DecorationImage(
                              image: trip.imageBytes != null
                                  ? MemoryImage(trip.imageBytes!) as ImageProvider
                                  : const NetworkImage('https://images.unsplash.com/photo-1596422846543-75c6fc18a52b?w=600'),
                              fit: BoxFit.cover,
                              opacity: 0.45,
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Trip to ${trip.destination}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                      child: Text(
                                        '${DateFormat('d MMM').format(trip.startDate)} - ${DateFormat('d MMM').format(trip.endDate)}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_horiz, color: Colors.white, size: 28),
                                  onSelected: (value) {
                                    if (value == 'edit') _editTripDialog(context, currentDocId, trip.destination);
                                    if (value == 'delete') _deleteTripDialog(context, currentDocId);
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () async {
                          final newTrip = await Navigator.push<Trip>(context, MaterialPageRoute(builder: (context) => const CreateTripPage()));
                          if (newTrip != null) {
                            await _firebaseService.createNewTrip(newTrip);
                          }
                        },
                        child: Container(
                          height: 75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2E3D39).withOpacity(0.15), width: 1.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, color: Color(0xFF2E3D39), size: 22),
                              SizedBox(width: 10),
                              Text('Plan a new trip', style: TextStyle(color: Color(0xFF2E3D39), fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderView(String title) {
    return Center(child: Text('$title Screen Placeholder', style: const TextStyle(fontSize: 18, color: Colors.grey)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTabView(),
            _buildPlannerTabView(),
            _buildPlaceholderView('Hidden Gems'),
            _buildPlaceholderView('Quests'),
             ProfileSettingsScreen(), // ✅ Swapped your 'Companion' placeholder with your new screen layout!
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomBar(),
    );
  }

  Widget _buildCustomBottomBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(index: 0, label: 'Home', icon: Icons.home_outlined),
              _buildTabItem(index: 1, label: 'Planner', icon: Icons.assignment_outlined),
              _buildTabItem(index: 2, label: 'Hidden Gems', icon: Icons.diamond_outlined),
              _buildTabItem(index: 3, label: 'Quests', icon: Icons.map_outlined),
              _buildTabItem(index: 4, label: 'Profile', icon: Icons.person_outline), // ✅ Changed label and icon to match Profile
            ],
          ),
        ),
        Container(
          color: const Color(0xFFE5E2DA),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                onPressed: () {},
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem({required int index, required String label, required IconData icon}) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() { _currentIndex = index; });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9FA8A6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF2E3D39) : Colors.black, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E3D39) : Colors.black,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}