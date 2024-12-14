import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(PasswordChangeApp());
}

class PasswordChangeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PasswordChangeScreen(),
    );
  }
}

class PasswordChangeScreen extends StatefulWidget {
  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jika validasi gagal, tidak lanjut ke server
    }

    setState(() {
      _isLoading = true;
    });

    const baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
    final token = await _storage.read(key: 'refreshToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token tidak ditemukan.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/users/profile/password/change'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "currentPassword": _oldPasswordController.text,
          "newPassword": _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password berhasil diubah!")),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? "Terjadi kesalahan.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $message")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Keamanan",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInputSection(
                "Masukkan Password Lama",
                "password lama",
                _oldPasswordController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return "Password lama wajib diisi.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              buildInputSection(
                "Masukkan Password Baru",
                "password baru",
                _newPasswordController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return "Password baru wajib diisi.";
                  } else if (value.length < 8) {
                    return "Password baru minimal 8 karakter.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              buildInputSection(
                "Konfirmasi Password Baru",
                "konfirmasi password baru",
                _confirmPasswordController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return "Konfirmasi password wajib diisi.";
                  } else if (value != _newPasswordController.text) {
                    return "Password tidak cocok.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _changePassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Ganti Password",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputSection(String title, String hint,
      TextEditingController controller, String? Function(String?)? validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: true,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
