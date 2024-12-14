import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pasalpintar_mobile/content/root/landing.dart';
import 'package:pasalpintar_mobile/content/pages/signin.dart';
import 'package:pasalpintar_mobile/content/pages/signup.dart';
import 'package:pasalpintar_mobile/content/pages/home.dart';
import 'package:pasalpintar_mobile/content/pages/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "PasalPintar",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        '/landing': (context) => const LandingPage(),
        '/signin': (context) => SignIn(),
        '/signup': (context) => SignUp(),
        '/home': (context) => Home(),
        '/profile': (context) => Profile(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    print('RefreshToken ditemukan: $refreshToken');

    Timer(const Duration(seconds: 2), () {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.black12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  "assets/logo/pasalpintar.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "PasalPintar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
