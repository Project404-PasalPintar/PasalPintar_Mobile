import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LawyerDetailPage extends StatefulWidget {
  final String lawyerId; // ID pengacara diterima dari Home Page

  const LawyerDetailPage({Key? key, required this.lawyerId}) : super(key: key);

  @override
  State<LawyerDetailPage> createState() => _LawyerDetailPageState();
}

class _LawyerDetailPageState extends State<LawyerDetailPage> {
  Map<String, dynamic>? lawyerData; // Data detail pengacara
  bool isLoading = true; // State untuk loading

  @override
  void initState() {
    super.initState();
    fetchLawyerDetails(); // Panggil API ketika halaman dibuka
  }

  Future<void> fetchLawyerDetails() async {
    const baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
    final storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refreshToken');

    final url = '$baseUrl/v1/users/profile/lawyer/${widget.lawyerId}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $refreshToken', // Header untuk autentikasi
          'Content-Type': 'application/json',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          lawyerData = data['data']; // Simpan data pengacara
          isLoading = false; // Hentikan loading
        });
      } else {
        throw Exception('Failed to load lawyer details');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Hentikan loading meskipun ada error
      });
      print("Error: $e");
    }
  }

  String formatTimestamp(Map<String, dynamic> timestamp) {
    final seconds = timestamp['_seconds'] ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return '${date.day}-${date.month}-${date.year}';
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
                      // Created Date
                      Text(
                        "Dibuat pada: ${formatTimestamp(lawyerData!['createdAt'])}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      // Tombol Start Consult
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Tambahkan logika ketika tombol diklik
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
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
