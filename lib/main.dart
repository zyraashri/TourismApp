import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // 
import 'package:provider/provider.dart';
import 'package:tourismapp/providers/auth_provider.dart';
import 'package:tourismapp/screens/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    // 👈 This block configures Firebase Web so Chrome doesn't freeze!
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
    // This handles mobile setups seamlessly if you switch later
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFBF8F2),
      ),
      home: const LoginPage(),
    );
  }
}