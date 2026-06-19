import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'screens/home_page.dart';

void main() async {
  // Ensure widget bindings are ready before initializing native background plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // Connect directly with your cloud console project environment configurations
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCEvvCvnA2IcAYrdCQjyub9NO-uNvfnCbM",
      authDomain: "questmy-56755.firebaseapp.com",
      projectId: "questmy-56755",
      storageBucket: "questmy-56755.firebasestorage.app",
      messagingSenderId: "116560328450",
      appId: "1:116560328450:web:3caca7c52b3dc380fd341b",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Travel Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E3D39),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}