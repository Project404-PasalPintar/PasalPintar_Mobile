import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyAccount());
}

class MyAccount extends StatelessWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile User',
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Akun Saya",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: const ProfileUserPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({Key? key}) : super(key: key);

  @override
  State<ProfileUserPage> createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  final storage = const FlutterSecureStorage();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    const baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
    final token = await storage.read(key: 'refreshToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token tidak ditemukan.")),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];

        setState(() {
          firstNameController.text = data['firstName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          emailController.text = data['email'] ?? '';
          descriptionController.text = data['description'] ?? '';
          isLoading = false;
        });
      } else {
        throw Exception(
            'Gagal memuat data profil. Status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> saveProfileData() async {
    const baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
    final token = await storage.read(key: 'refreshToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token tidak ditemukan.")),
      );
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/v1/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "description": descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil disimpan.")),
        );

        // Direct kembali ke halaman /profile
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        throw Exception(
            'Gagal menyimpan data profil. Status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                InputField(
                  label: 'Nama Depan',
                  controller: firstNameController,
                ),
                const SizedBox(height: 10),
                InputField(
                  label: 'Nama Belakang',
                  controller: lastNameController,
                ),
                const SizedBox(height: 10),
                InputField(
                  label: 'Email',
                  controller: emailController,
                  isEnabled: false, // Email tidak bisa diedit
                ),
                const SizedBox(height: 10),
                InputField(
                  label: 'Deskripsi',
                  controller: descriptionController,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveProfileData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

// Widget custom for input field
class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEnabled;

  const InputField({
    Key? key,
    required this.label,
    required this.controller,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: isEnabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      ],
    );
  }
}
