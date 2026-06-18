import 'package:flutter/material.dart';

class HiddenGemsPage extends StatelessWidget {
  const HiddenGemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EE),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4EE),
        elevation: 0,
        title: const Text(
          "Hidden Gems",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: const Center(
        child: Text(
          "Hidden Gems Home Page",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}