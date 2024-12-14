import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../navigation/custom_nav_bar.dart';
import 'profile/myaccount.dart';
import 'profile/security.dart';
import 'profile/about.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(221, 10, 96, 128),
      ),
      body: const ProfilePage(),
      bottomNavigationBar: const CustomNavBar(currentIndex: 4),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    const baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
    final storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      _navigateToLogin(context);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/users/auth/sign-out'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await storage.delete(key: 'refreshToken');
        await storage.delete(key: 'accessToken');
        _navigateToLogin(context);
      } else {
        Future.microtask(() => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logout gagal. Coba lagi.')),
            ));
      }
    } catch (e) {
      Future.microtask(() => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan saat logout: $e')),
          ));
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/signin',
      (route) => false,
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar dari aplikasi'),
            content: const Text('Apakah kamu ingin keluar dari aplikasi ini?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Ya'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black12,
          child: const Icon(
            Icons.person,
            size: 60,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Lihat Profil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: [
              MenuTile(
                title: 'Akun Saya',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyAccount()),
                  );
                },
              ),
              MenuTile(
                title: 'Keamanan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PasswordChangeScreen()),
                  );
                },
              ),
              MenuTile(
                title: 'Tentang Kami',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                },
              ),
              MenuTile(
                title: 'Keluar',
                onTap: () async {
                  final shouldLogout = await _onBackPressed(context);
                  if (shouldLogout) {
                    await _logout(context);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MenuTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const MenuTile({Key? key, required this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
