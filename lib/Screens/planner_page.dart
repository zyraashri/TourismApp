import 'package:flutter/material.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _page(context, "Planner Page");
  }

  Widget _page(BuildContext context, String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
