import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../navigation/custom_nav_bar.dart';
import '../pages/lawyer/lawyer_detail.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PasalPintar"),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildTanyaBangKimSection(),
            const SizedBox(height: 20),
            const Text(
              "Fitur PasalPintar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFeatureCards(),
            const SizedBox(height: 20),
            const Text(
              "Top Pengacara",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTopPengacara(),
            const SizedBox(height: 20),
            const Text(
              "Berita Hukum Terbaru",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBeritaHukum(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari hukum, pengacara ...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTanyaBangKimSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Punya Pertanyaan Hukum?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ceritakan masalahmu kami akan berikan pasal yang berhubungan",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Ceritakan masalahmu',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    // Logika Tanya Dong Bang Kim
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _FeatureCard(
          title: "Klasifikasi Hukum",
          iconPath: "assets/icons/icons8-lawyer-50.png",
        ),
        _FeatureCard(
          title: "Coming soon",
          iconPath: "assets/icons/icons8-forum-50.png",
        ),
      ],
    );
  }

  Widget _buildTopPengacara() {
    return FutureBuilder<List<dynamic>>(
      future: fetchTopLawyers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada data pengacara.'));
        }

        final lawyers = snapshot.data!;
        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lawyers.length,
            itemBuilder: (context, index) {
              final lawyer = lawyers[index];
              final name = '${lawyer['firstName']}';
              final profilePic = lawyer['profilePic'];
              final id = lawyer['id']; // Pastikan ID diterima dengan benar

              return _LawyerCard(
                name: name,
                profilePic: profilePic,
                id: id, // Kirimkan ID ke _LawyerCard
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBeritaHukum() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          "Berita Hukum Placeholder",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchTopLawyers() async {
    const baseUrl = 'https://test-z77zvpmgsa-uc.a.run.app';
    final storage = FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refreshToken');

    final response = await http.get(
      Uri.parse('$baseUrl/v1/users/profile/lawyer/all?limit=4'),
      headers: {
        'Authorization': 'Bearer $refreshToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal memuat data pengacara');
    }
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String iconPath;

  const _FeatureCard({required this.title, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Image.asset(
              iconPath,
              width: 50,
              height: 50,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class _LawyerCard extends StatelessWidget {
  final String name;
  final String? profilePic;
  final String id; // Tambahkan ID

  const _LawyerCard({
    required this.name,
    required this.profilePic,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail pengacara dengan ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LawyerDetailPage(
              lawyerId: id, // Kirim ID ke halaman detail
            ),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50), // Circular avatar
              child: profilePic != null && profilePic!.isNotEmpty
                  ? Image.network(
                      profilePic!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person,
                            size: 50, color: Colors.grey);
                      },
                    )
                  : const Icon(Icons.person,
                      size: 50, color: Colors.grey), // Default icon
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
