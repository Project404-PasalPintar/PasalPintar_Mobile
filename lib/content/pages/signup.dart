import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pasalpintar_mobile/content/pages/signin.dart'; // Impor halaman SignIn

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String errorMessage = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Fungsi untuk menambah/menyembunyikan password
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  // Validasi email menggunakan regex
  bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  Future<void> signUp() async {
    // Validasi form sederhana
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = "Semua field harus diisi.";
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = "Password dan konfirmasi password tidak cocok.";
      });
      return;
    }

    if (!isValidEmail(emailController.text)) {
      setState(() {
        errorMessage = "Email tidak valid. Pastikan email mengandung '@'.";
      });
      return;
    }

    // Request ke API
    final response = await http.post(
      Uri.parse('https://test-z77zvpmgsa-uc.a.run.app/v1/users/auth/sign-up'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': emailController.text,
        'password': passwordController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
      }),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200 && responseBody['status'] == 'success') {
      // Jika berhasil, simpan data (misalnya token) menggunakan flutter_secure_storage
      await secureStorage.write(
          key: 'userID', value: responseBody['data']['userID']);
      await secureStorage.write(
          key: 'email', value: responseBody['data']['email']);

      // Pindah ke halaman SignIn setelah berhasil dengan menghapus stack navigasi
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignIn()),
        (Route<dynamic> route) => false, // Menghapus semua rute sebelumnya
      );
    } else {
      // Jika gagal, tampilkan pesan error
      setState(() {
        errorMessage = responseBody['message'] ?? 'Pendaftaran gagal.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 1)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Daftar Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daftar dan Dapatkan Jawaban Hukum.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Depan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Belakang',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _toggleConfirmPasswordVisibility,
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                    ),
                    const SizedBox(height: 50),
                    // Tampilkan pesan error jika ada
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Daftar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 230, 230, 230),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: Image.asset(
                        "assets/logo/google.png",
                        width: 25,
                        height: 25,
                      ),
                      label: Text(
                        'Masuk dengan Google',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Builder(
                        builder: (context) {
                          return RichText(
                            text: TextSpan(
                              text: 'Sudah punya akun? ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                              children: [
                                TextSpan(
                                  text: 'Masuk',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SignIn()),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
