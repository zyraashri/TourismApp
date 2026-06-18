import 'package:flutter/material.dart';

Widget buildBottomNavBar({bool activeQuestIndex = true}) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF2D464C),
    unselectedItemColor: Colors.grey,
    currentIndex: activeQuestIndex ? 3 : 0, // Defaults to Quests (Index 3) now
    selectedFontSize: 10,
    unselectedFontSize: 10,
    items: [
      BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: 'Home'),
      BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_outlined), label: 'Planner'),
      BottomNavigationBarItem(icon: const Icon(Icons.diamond_outlined), label: 'Hidden Gems'),
      BottomNavigationBarItem(icon: const Icon(Icons.map), label: 'Quests'),
      BottomNavigationBarItem(icon: const Icon(Icons.smart_toy_outlined), label: 'Companion'),
    ],
  );
}