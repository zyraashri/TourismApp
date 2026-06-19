import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip_models.dart';
import '../services/firebase_service.dart';
import 'itinerary_page.dart';
import 'budgeting_page.dart';

class TripDashboardPage extends StatefulWidget {
  final Trip trip;
  final String docId; // Receives the unique Cloud Firestore Tracking Document ID hash

  const TripDashboardPage({Key? key, required this.trip, required this.docId}) : super(key: key);

  @override
  State<TripDashboardPage> createState() => _TripDashboardPageState();
}

class _TripDashboardPageState extends State<TripDashboardPage> {
  final FirebaseService _firebaseService = FirebaseService();

  // Updates custom array lists directly in your shared cloud database instantly
  Future<void> _addListItemToFirebase(String keyName, String textInput, List<String> targetList) async {
    setState(() {
      targetList.add(textInput);
    });
    
    // Push the clean string array update straight to the cloud console
    await _firebaseService.updateTripData(widget.docId, {
      keyName: targetList,
    });
  }

  void _addListItemDialog(String title, String firestoreKey, List<String> targetList) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add New $title'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Enter name or spot location...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                await _addListItemToFirebase(firestoreKey, textController.text, targetList);
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF2E3D39), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.trip.imageBytes != null
                          ? MemoryImage(widget.trip.imageBytes!) as ImageProvider
                          : const NetworkImage('https://images.unsplash.com/photo-1590001155093-a3c66ab0c3ff?w=600'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.4)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3D39)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Trip to ${widget.trip.destination}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2E3D39))),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('d MMM').format(widget.trip.startDate)} - ${DateFormat('d MMM').format(widget.trip.endDate)}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.trip.isHistory ? Colors.grey : const Color(0xFF2E3D39),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.trip.isHistory ? 'Past' : 'Active',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Core Planners', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E3D39))),
                  const SizedBox(height: 12),
                  
                  // LIVE CONNECTED ITINERARY BUTTON
                  _buildMenuTile(
                    title: 'Travel Calendar & Itinerary',
                    subtitle: '${widget.trip.itinerary.length} activities scheduled',
                    icon: Icons.calendar_month_outlined,
                    onTap: () async {
                      // Forwarding tracking document context keys safely down to the action sheet
                      await Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => ItineraryPage(trip: widget.trip, docId: widget.docId),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // LIVE CONNECTED BUDGET TRACKER BUTTON
                  _buildMenuTile(
                    title: 'Budget & Estimated Expenses',
                    subtitle: 'Spent RM ${widget.trip.totalSpent.toStringAsFixed(2)} / RM ${widget.trip.budgetLimit.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () async {
                      // Forwarding tracking document context keys safely down to the budgeting module
                      await Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => BudgetingPage(trip: widget.trip, docId: widget.docId),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // LIVE CONNECTED ATTRACTIONS LIST
                  _buildDynamicListSection(
                    title: 'Destinations & Attractions',
                    items: widget.trip.attractions,
                    icon: Icons.place_outlined,
                    onAddPressed: () => _addListItemDialog('Attraction', 'attractions', widget.trip.attractions),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // LIVE CONNECTED FAVORITES LIST
                  _buildDynamicListSection(
                    title: 'Saved Favourite Locations',
                    items: widget.trip.favoriteLocations,
                    icon: Icons.favorite_border,
                    onAddPressed: () => _addListItemDialog('Favourite Location', 'favoriteLocations', widget.trip.favoriteLocations),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.15))),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2E3D39), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2E3D39))),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicListSection({required String title, required List<String> items, required IconData icon, required VoidCallback onAddPressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E3D39))),
            IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2E3D39), size: 22), onPressed: onAddPressed),
          ],
        ),
        const SizedBox(height: 8),
        items.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                child: Text('None added yet. Click the + button to start listing.', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) => Chip(
                  avatar: Icon(icon, size: 14, color: const Color(0xFF2E3D39)),
                  label: Text(item, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                )).toList(),
              ),
      ],
    );
  }
}