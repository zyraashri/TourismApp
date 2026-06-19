import 'package:flutter/material.dart';

import '../screens/homedashboard_page.dart';
import '../screens/home_page.dart';
import '../screens/hidden_gems/hidden_gems_page.dart';
import '../screens/discover_malaysia.dart';
import '../screens/companion_page.dart';

class QuestBottomNavBar extends StatelessWidget {
  final String activePage;

  const QuestBottomNavBar({super.key, required this.activePage});

  void goToPage(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            'assets/images/home.png',
            'Home',
            'home',
            const HomeDashboardPage(),
          ),
          _navItem(
            context,
            'assets/images/planner.png',
            'Planner',
            'planner',
            const HomePage(),
          ),
          _navItem(
            context,
            'assets/images/hiddengems.png',
            'Hidden Gems',
            'hiddenGems',
            const HiddenGemsPage(),
          ),
          _navItem(
            context,
            'assets/images/quest.png',
            'Quests',
            'quests',
            const DiscoverMalaysiaPage(),
          ),
          _navItem(
            context,
            'assets/images/companion.png',
            'Companion',
            'companion',
            const CompanionPage(),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String imagePath,
    String label,
    String pageKey,
    Widget page,
  ) {
    final selected = activePage == pageKey;

    return InkWell(
      onTap: selected ? null : () => goToPage(context, page),
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
}
