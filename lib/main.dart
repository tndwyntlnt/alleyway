import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alleyway Membership',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1E392A), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1E392A),
          primary: Color(0xFF1E392A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(0xFFF4F6F5), // Warna background utama
        fontFamily: 'Poppins', // Anda bisa ganti font di pubspec.yaml
      ),
      home: const SplashScreen(), // Mulai dari HomeScreen
    );
  }
}