import 'package:flutter/material.dart';
import 'screens/hidden_gems/hidden_gems_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuestMY',
      home: const HiddenGemsPage(),
    );
  }
}