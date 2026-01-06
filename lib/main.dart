import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PantryPalApp());
}

class PantryPalApp extends StatelessWidget {
  const PantryPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
