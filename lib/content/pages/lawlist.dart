import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../navigation/custom_nav_bar.dart';
import '../pages/lawlist/laws.dart';

class Lawlist extends StatelessWidget {
  const Lawlist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Hukum',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LawListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LawListPage extends StatelessWidget {
  const LawListPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _loadLawData() async {
    final String response = await rootBundle.loadString('lib/data/data.json');
    final List<dynamic> data = json.decode(response);
    return data.map((law) => law as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Hukum'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Tambahkan fungsi pencarian jika diperlukan
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadLawData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data tidak tersedia.'));
          }

          final List<Map<String, dynamic>> lawList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lawList.length,
            itemBuilder: (context, index) {
              final law = lawList[index];
              return LawItem(
                title: law['NamaHukum'] ?? 'Hukum Tidak Ditemukan',
                description: law['Deskripsi'] ?? 'Deskripsi tidak tersedia.',
                imageUrl:
                    'assets/image/image1.png', // Pastikan path gambar benar
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LawsPage(
                        namaHukum: law['NamaHukum'] ?? 'Hukum Tidak Ditemukan',
                        pasalList: law['Pasal'] ?? [],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 1),
    );
  }
}

class LawItem extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;

  const LawItem({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
