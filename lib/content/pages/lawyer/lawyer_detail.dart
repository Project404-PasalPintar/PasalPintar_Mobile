import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import library JWT Decoder
import "../chat/chat_lawyer_page.dart";
import 'dart:convert';

class LawyerDetailPage extends StatefulWidget {
  final String lawyerId; // ID pengacara diterima dari Home Page

  const LawyerDetailPage({Key? key, required this.lawyerId}) : super(key: key);

  @override
  State<LawyerDetailPage> createState() => _LawyerDetailPageState();
}

class _LawyerDetailPageState extends State<LawyerDetailPage> {
  Map<String, dynamic>? lawyerData; // Data detail pengacara
  bool isLoading = true; // State untuk loading
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? userId; // User ID untuk membuat chat room ID

  @override
  void initState() {
    super.initState();
    fetchUserIdFromToken(); // Ambil userId dari token JWT
    fetchLawyerDetails(); // Panggil API ketika halaman dibuka
  }

  Future<void> fetchUserIdFromToken() async {
    try {
      // Ambil refreshToken dari Secure Storage
      final refreshToken = await storage.read(key: 'refreshToken');
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Refresh token tidak ditemukan.');
      }

      // Decode token JWT untuk mengambil userId
      Map<String, dynamic> decodedToken = JwtDecoder.decode(refreshToken);
      setState(() {
        userId = decodedToken[
            'userID']; // Pastikan nama kunci sesuai dengan payload JWT
      });

      print("User ID berhasil diambil dari token: $userId");
    } catch (e) {
      print("Error saat mengambil user ID dari token: $e");
    }
  }

  Future<void> fetchLawyerDetails() async {
    const baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
    final refreshToken = await storage.read(key: 'refreshToken');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/users/profile/lawyer/${widget.lawyerId}'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Menggunakan json.decode setelah mengimpor `dart:convert`
        final data = json.decode(response.body);
        setState(() {
          lawyerData = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load lawyer details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Pengacara"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading spinner
          : lawyerData == null
              ? const Center(child: Text("Gagal memuat detail pengacara"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar dan Detail Pengacara
                      Row(
                        children: [
                          // Gambar Pengacara
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: lawyerData!['profilePic'] != null &&
                                    lawyerData!['profilePic'].isNotEmpty
                                ? Image.network(
                                    lawyerData!['profilePic'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.grey,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // Nama dan Role Pengacara
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${lawyerData!['firstName']} ${lawyerData!['lastName']}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Pengacara",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Tentang Pengacara
                      Text(
                        "Tentang ${lawyerData!['firstName']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lawyerData!['description']?.isNotEmpty == true
                              ? lawyerData!['description']
                              : "Deskripsi tidak tersedia",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Spacer(),
                      // Tombol Start Consult
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: userId == null
                              ? null
                              : () {
                                  final chatRoomId =
                                      "chat_${userId}_${widget.lawyerId}";
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        chatRoomId: chatRoomId,
                                        lawyerName:
                                            "${lawyerData!['firstName']} ${lawyerData!['lastName']}",
                                        lawyerId: widget
                                            .lawyerId, // Pastikan lawyerId disediakan di sini
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                userId == null ? Colors.grey : Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Start Consult",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
