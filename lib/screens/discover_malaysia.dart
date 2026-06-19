import 'package:flutter/material.dart';
import '../global_widgets.dart';
import 'quest_detail_page.dart';

class DiscoverMalaysiaPage extends StatefulWidget {
  const DiscoverMalaysiaPage({super.key});

  @override
  State<DiscoverMalaysiaPage> createState() => _DiscoverMalaysiaPageState();
}

class _DiscoverMalaysiaPageState extends State<DiscoverMalaysiaPage> {
  // Destination Tracking Parameters
  bool _isMelakaCompleted = false;
  int _melakaChecks = 0;

  bool _isPenangCompleted = false;
  int _penangChecks = 0;

  bool _isSabahCompleted = false;
  int _sabahChecks = 0;

  // --- REGION 1 DATA: MELAKA ---
  final List<Map<String, String>> _melakaLocations = [
    {'title': 'Visit A Famosa', 'subtitle': 'Jalan Kota, Melaka'},
    {'title': 'Visit Stadthuys', 'subtitle': 'Dutch Square, Melaka'},
    {'title': 'Visit Christ Church Melaka', 'subtitle': 'Red Square, Melaka'},
  ];
  final List<Map<String, dynamic>> _melakaQuiz = [
    {'question': 'When was A Famosa fortress built?', 'options': ['1411', '1511', '1611', '1711'], 'correctIndex': 1},
    {'question': 'Which colonial power built the Stadthuys?', 'options': ['Portuguese', 'Dutch', 'British', 'Spanish'], 'correctIndex': 1},
    {'question': 'What color is Christ Church Melaka famous for?', 'options': ['White', 'Blue', 'Red', 'Golden Yellow'], 'correctIndex': 2},
  ];

  // --- REGION 2 DATA: PENANG ---
  final List<Map<String, String>> _penangLocations = [
    {'title': 'Visit Fort Cornwallis', 'subtitle': 'Jalan Tun Syed Sheh Barakbah'},
    {'title': 'Visit Pinang Peranakan Mansion', 'subtitle': 'Church Street, George Town'},
    {'title': 'Visit Cheong Fatt Tze Mansion', 'subtitle': 'Leith Street, George Town'},
  ];
  final List<Map<String, dynamic>> _penangQuiz = [
    {'question': 'Who founded George Town in 1786?', 'options': ['Francis Light', 'Stamford Raffles', 'Alfonso de Albuquerque', 'William Light'], 'correctIndex': 0},
    {'question': 'Cheong Fatt Tze Mansion is famous for what color?', 'options': ['Indigo Blue', 'Ruby Red', 'Emerald Green', 'Mustard Yellow'], 'correctIndex': 0},
    {'question': 'What clan jetty is the most famous tourist spot?', 'options': ['Lim Jetty', 'Chew Jetty', 'Tan Jetty', 'Yeoh Jetty'], 'correctIndex': 1},
  ];

  // --- REGION 3 DATA: SABAH ---
  final List<Map<String, String>> _sabahLocations = [
    {'title': 'Visit Desa Dairy Farm', 'subtitle': 'Kundasang, Sabah'},
    {'title': 'Visit Kinabalu Park Orchid Garden', 'subtitle': 'Ranau, Sabah'},
    {'title': 'Visit Kundasang War Memorial', 'subtitle': 'Kundasang Town, Sabah'},
  ];
  final List<Map<String, dynamic>> _sabahQuiz = [
    {'question': 'Kundasang sits near the base of which mountain?', 'options': ['Mount Jerai', 'Mount Kinabalu', 'Mount Tahan', 'Mount Ledang'], 'correctIndex': 1},
    {'question': 'Desa Dairy Farm is often compared to the pastures of which country?', 'options': ['New Zealand', 'Switzerland', 'Netherlands', 'Scotland'], 'correctIndex': 0},
    {'question': 'The Kundasang War Memorial honors soldiers from which two nations?', 'options': ['Malaysia & UK', 'Australia & UK', 'New Zealand & Japan', 'Australia & Malaysia'], 'correctIndex': 1},
  ];

  @override
  Widget build(BuildContext context) {
    // Dynamic calculations recalculate dashboard data on the fly
    int totalPoints = 0;
    int badgesCount = 0;
    int placesVisited = 0;

    if (_isMelakaCompleted) { totalPoints += 300; badgesCount++; placesVisited++; }
    if (_isPenangCompleted) { totalPoints += 300; badgesCount++; placesVisited++; }
    if (_isSabahCompleted)  { totalPoints += 300; badgesCount++; placesVisited++; }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Dashboard
            Container(
              color: const Color(0xFF2D464C),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CULTURAL QUEST CHALLENGE',
                    style: TextStyle(color: Color(0xFFE5C158), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Discover Malaysia',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatCard('⚡', '$totalPoints', 'points'),
                      const SizedBox(width: 10),
                      // Updated badges to be out of 3 dynamically
                      _buildStatCard('🛡️', '$badgesCount/3', 'badges'),
                      const SizedBox(width: 10),
                      _buildStatCard('🏢', '$placesVisited', 'places visited'),
                    ],
                  ),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Choose a destination to begin your quest', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ),

            // Destination Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // CARD 1: MELAKA
                  _buildDestinationCard(
                    context,
                    icon: '🏰',
                    iconBg: const Color(0xFFFFF3CD),
                    title: 'Bandaraya Melaka, Melaka',
                    progress: _melakaChecks / 3,
                    checkIns: '$_melakaChecks/3 check-ins',
                    percentage: '${((_melakaChecks / 3) * 100).toInt()}%',
                    hasBadge: _isMelakaCompleted,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestDetailPage(
                            title: 'Bandaraya Melaka',
                            icon: '🏰',
                            region: 'Melaka',
                            locationsData: _melakaLocations,
                            quizQuestions: _melakaQuiz,
                            initialCheckedLocations: List.generate(3, (i) => i < _melakaChecks),
                          ),
                        ),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _isMelakaCompleted = result['isQuestCompleted'] ?? false;
                          _melakaChecks = result['checkInCount'] ?? 0;
                        });
                      }
                    },
                  ),

                  // CARD 2: PENANG
                  _buildDestinationCard(
                    context,
                    icon: '🌴',
                    iconBg: const Color(0xFFD1ECF1),
                    title: 'Georgetown, Penang',
                    progress: _penangChecks / 3,
                    checkIns: '$_penangChecks/3 check-ins',
                    percentage: '${((_penangChecks / 3) * 100).toInt()}%',
                    hasBadge: _isPenangCompleted,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestDetailPage(
                            title: 'Georgetown, Penang',
                            icon: '🌴',
                            region: 'Penang',
                            locationsData: _penangLocations,
                            quizQuestions: _penangQuiz,
                            initialCheckedLocations: List.generate(3, (i) => i < _penangChecks),
                          ),
                        ),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _isPenangCompleted = result['isQuestCompleted'] ?? false;
                          _penangChecks = result['checkInCount'] ?? 0;
                        });
                      }
                    },
                  ),

                  // CARD 3: SABAH
                  _buildDestinationCard(
                    context,
                    icon: '🏔️',
                    iconBg: const Color(0xFFD4EDDA),
                    title: 'Kundasang, Sabah',
                    progress: _sabahChecks / 3,
                    checkIns: '$_sabahChecks/3 check-ins',
                    percentage: '${((_sabahChecks / 3) * 100).toInt()}%',
                    hasBadge: _isSabahCompleted,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestDetailPage(
                            title: 'Kundasang, Sabah',
                            icon: '🏔️',
                            region: 'Sabah',
                            locationsData: _sabahLocations,
                            quizQuestions: _sabahQuiz,
                            initialCheckedLocations: List.generate(3, (i) => i < _sabahChecks),
                          ),
                        ),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _isSabahCompleted = result['isQuestCompleted'] ?? false;
                          _sabahChecks = result['checkInCount'] ?? 0;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(activeQuestIndex: true),
    );
  }

  Widget _buildStatCard(String icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF4A656D), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context, {
    required String icon,
    required Color iconBg,
    required String title,
    required double progress,
    required String checkIns,
    required String percentage,
    bool hasBadge = false,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        if (hasBadge) const Text('🏅', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF5D7A82),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(checkIns, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(percentage, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
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
}