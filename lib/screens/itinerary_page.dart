import 'package:flutter/material.dart';
import '../models/trip_models.dart';
import '../services/firebase_service.dart';

class ItineraryPage extends StatefulWidget {
  final Trip trip;
  final String docId;

  const ItineraryPage({Key? key, required this.trip, required this.docId})
    : super(key: key);

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  int _selectedDay = 1;

  // SMART TIME FORMATTER: Converts "10" -> "10:00 AM", "14:30" -> "02:30 PM", "10.15 pm" -> "10:15 PM"
  String _formatToAmPm(String rawTime) {
    String clean = rawTime
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9.:]'), '')
        .trim();
    if (clean.isEmpty) return "12:00 PM";

    bool isPm = clean.contains('pm');
    bool isAm = clean.contains('am');
    clean = clean
        .replaceAll('am', '')
        .replaceAll('pm', '')
        .replaceAll('.', ':');

    int hour = 12;
    int minute = 0;

    List<String> parts = clean.split(':');

    if (parts.length == 1) {
      // Handles single numbers like "10" or "14"
      int? parsedHour = int.tryParse(parts[0]);
      if (parsedHour != null) hour = parsedHour;
    } else if (parts.length >= 2) {
      // Handles split elements like "10:30"
      hour = int.tryParse(parts[0]) ?? 12;
      minute = int.tryParse(parts[1]) ?? 0;
    }

    // Adjust 24-hour clock formats automatically
    if (hour >= 24) hour = 0;
    if (hour >= 12 && !isAm && !isPm) {
      if (hour > 12) {
        hour -= 12;
      }
      isPm = true;
    } else if (hour == 0) {
      hour = 12;
      isAm = true;
    } else if (hour > 12) {
      hour -= 12;
      isPm = true;
    }

    // Default fallback assignment if indicators aren't explicit
    if (!isAm && !isPm) isAm = true;

    String hourStr = hour.toString().padLeft(2, '0');
    String minuteStr = minute.toString().padLeft(2, '0');
    String period = isPm ? 'PM' : 'AM';

    return "$hourStr:$minuteStr $period";
  }

  Future<void> _syncItineraryToFirebase() async {
    List<Map<String, dynamic>> itineraryData = widget.trip.itinerary
        .map(
          (i) => {
            'dayNumber': i.dayNumber,
            'time': i.time,
            'description': i.description,
          },
        )
        .toList();

    await _firebaseService.updateTripData(widget.docId, {
      'itinerary': itineraryData,
    });
  }

  Future<void> _saveItineraryItem() async {
    if (_timeController.text.isNotEmpty && _descController.text.isNotEmpty) {
      // Convert user input into beautiful AM/PM format before saving
      String amPmTime = _formatToAmPm(_timeController.text);

      final newItem = ItineraryItem(
        dayNumber: _selectedDay,
        time: amPmTime,
        description: _descController.text,
      );

      setState(() {
        widget.trip.itinerary.add(newItem);
      });

      await _syncItineraryToFirebase();

      _timeController.clear();
      _descController.clear();
      Navigator.pop(context);
    }
  }

  void _showEditActivityDialog(ItineraryItem item, int globalIndex) {
    final TextEditingController editTimeController = TextEditingController(
      text: item.time,
    );
    final TextEditingController editDescController = TextEditingController(
      text: item.description,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Activity Plan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3D39),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editTimeController,
              decoration: InputDecoration(
                hintText: 'Time (e.g., 10:00 AM)',
                prefixIcon: const Icon(Icons.access_time, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editDescController,
              decoration: InputDecoration(
                hintText: 'Description',
                prefixIcon: const Icon(Icons.explore_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (editTimeController.text.isNotEmpty &&
                  editDescController.text.isNotEmpty) {
                setState(() {
                  widget.trip.itinerary[globalIndex] = ItineraryItem(
                    dayNumber: item.dayNumber,
                    time: _formatToAmPm(editTimeController.text),
                    description: editDescController.text,
                  );
                });
                await _syncItineraryToFirebase();
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Save Changes',
              style: TextStyle(
                color: Color(0xFF2E3D39),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteActivity(int globalIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Activity?'),
        content: const Text(
          'Are you sure you want to delete this plan from your timeline?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                widget.trip.itinerary.removeAt(globalIndex);
              });
              await _syncItineraryToFirebase();
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddActivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'New Activity Plan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3D39),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                hintText: 'Time (e.g., 10, 14:30, or 9.45 pm)',
                prefixIcon: const Icon(Icons.access_time, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                hintText: 'What are you doing? (e.g., Makan)',
                prefixIcon: const Icon(Icons.explore_outlined, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: _saveItineraryItem,
            child: const Text(
              'Add to Timeline',
              style: TextStyle(
                color: Color(0xFF2E3D39),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalDays =
        widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;
    if (totalDays <= 0) totalDays = 1;

    List<ItineraryItem> currentDayItems = widget.trip.itinerary
        .where((i) => i.dayNumber == _selectedDay)
        .toList();

    // Sort items chronologically by time so earlier plans always stay at the top!
    currentDayItems.sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        title: const Text(
          'Itinerary For Your Trip',
          style: TextStyle(
            color: Color(0xFF2E3D39),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2E3D39)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalDays,
              itemBuilder: (context, index) {
                int dayNum = index + 1;
                bool isSelected = _selectedDay == dayNum;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = dayNum),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2E3D39)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        'Day $dayNum',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF2E3D39),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: currentDayItems.isEmpty
                ? Center(
                    child: Text(
                      'No activities listed for Day $_selectedDay.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: currentDayItems.length,
                    itemBuilder: (context, index) {
                      final item = currentDayItems[index];
                      int globalIndex = widget.trip.itinerary.indexOf(item);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E3D39),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (index != currentDayItems.length - 1)
                                Container(
                                  width: 2,
                                  height: 80,
                                  color: const Color(
                                    0xFF2E3D39,
                                  ).withOpacity(0.2),
                                ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // NEW DISPLAY BADGE COMPONENT FOR FORMATTED AM/PM TIME
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3EFF7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            item.time,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF504A59),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.description,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w400,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onSelected: (value) {
                                      if (value == 'edit')
                                        _showEditActivityDialog(
                                          item,
                                          globalIndex,
                                        );
                                      if (value == 'delete')
                                        _deleteActivity(globalIndex);
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Color(0xFF2E3D39),
                                            ),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E3D39),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
        onPressed: _showAddActivityDialog,
      ),
    );
  }
}
