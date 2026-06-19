import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tourismapp/providers/auth_provider.dart';
import 'package:tourismapp/screens/auth/login_page.dart';
import 'package:tourismapp/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
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
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuestMY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFCF8EF),
        primaryColor: const Color(0xFF2E3D39),
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),

      // Keep LoginPage as first page
      home: const LoginPage(),

      // HomePage is imported so Smart Journey page can still be used later
      // after login/navigation.
    );
  }
}
