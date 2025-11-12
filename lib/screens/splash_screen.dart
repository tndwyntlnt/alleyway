import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_screen.dart';
import 'login_screen.dart'; // Kita akan buat file ini

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Tunggu sebentar (untuk efek splash screen)
    await Future.delayed(const Duration(seconds: 1));

    // Coba baca token
    String? token = await _storage.read(key: 'auth_token');

    if (!mounted) return; // Cek jika widget masih ada

    // Putuskan ke mana harus pergi
    if (token != null) {
      // Jika ada token, pergi ke Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Jika tidak ada token, pergi ke Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan loading sederhana
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}