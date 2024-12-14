import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../navigation/custom_nav_bar.dart';
import '../pages/lawyer/lawyer_detail.dart';

class Lawyer extends StatelessWidget {
  const Lawyer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konsultasi Pengacara"),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: const LawyerPage(),
      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }
}

class LawyerPage extends StatefulWidget {
  const LawyerPage({Key? key}) : super(key: key);

  @override
  State<LawyerPage> createState() => _LawyerPageState();
}

class _LawyerPageState extends State<LawyerPage> {
  final String baseUrl = "https://test-z77zvpmgsa-uc.a.run.app";
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late Future<List<dynamic>> _lawyers; // Future untuk menyimpan daftar lawyer

  @override
  void initState() {
    super.initState();
    _lawyers = _fetchLawyers(); // Memuat daftar pengacara saat halaman di-load
  }

  Future<Map<String, String>> _getHeaders() async {
    final refreshToken = await storage.read(key: 'refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception("Refresh token tidak ditemukan");
    }
    return {
      'Authorization': 'Bearer $refreshToken',
      'Content-Type': 'application/json',
    };
  }

  Future<List<dynamic>> _fetchLawyers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/v1/users/profile/lawyer/all?limit=15'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Mengembalikan daftar pengacara
      } else {
        throw Exception(
            "Gagal memuat daftar pengacara. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat memuat pengacara: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<dynamic>>(
        future: _lawyers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Gagal memuat daftar pengacara: ${snapshot.error}"),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada pengacara tersedia."));
          }

          final lawyers = snapshot.data!;
          return ListView.builder(
            itemCount: lawyers.length,
            itemBuilder: (context, index) {
              final lawyer = lawyers[index];
              return LawyerCard(
                name: "${lawyer['firstName']} ${lawyer['lastName']}",
                specialization: lawyer['description']?.isNotEmpty == true
                    ? lawyer['description']
                    : "Pengacara",
                profilePic: lawyer['profilePic'],
                lawyerId: lawyer['id'], // Pastikan lawyerId ditambahkan di sini
                onConsultPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LawyerDetailPage(lawyerId: lawyer['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class LawyerCard extends StatelessWidget {
  final String name;
  final String specialization;
  final String? profilePic;
  final String lawyerId; // Tambahkan ID pengacara
  final VoidCallback onConsultPressed;

  const LawyerCard({
    Key? key,
    required this.name,
    required this.specialization,
    required this.profilePic,
    required this.lawyerId, // Tambahkan ID pengacara
    required this.onConsultPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Gambar profil pengacara (dari API atau ikon default)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: profilePic != null && profilePic!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      profilePic!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ); // Default jika gagal memuat gambar
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey,
                  ), // Default jika profilePic null
          ),
          const SizedBox(width: 16),
          // Detail pengacara
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialization,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Tombol Konsultasi
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LawyerDetailPage(
                    lawyerId: lawyerId,
                  ), // Kirim lawyerId ke halaman detail
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Konsultasi",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
