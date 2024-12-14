import 'package:flutter/material.dart';
import 'laws_overview.dart'; // Impor halaman LawsOverviewPage

class LawsPage extends StatelessWidget {
  final String namaHukum;
  final List<dynamic> pasalList;

  const LawsPage({
    Key? key,
    required this.namaHukum,
    required this.pasalList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pasal'),
        backgroundColor: Colors.blue,
      ),
      body: pasalList.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pasalList.length,
              itemBuilder: (context, index) {
                final pasal = pasalList[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // child: Image.asset(
                      //   'assets/image/image1.png', // Gambar placeholder
                      //   width: 50,
                      //   height: 50,
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    title: Text(
                      pasal['NamaPasal'] ?? 'Pasal Tidak Ditemukan',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      pasal['DeskripsiPasal'] ?? 'Deskripsi tidak tersedia.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigasi ke LawsOverviewPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LawsOverviewPage(
                            detailHukum: pasal, // Kirim data pasal
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'Tidak ada pasal untuk hukum ini.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
    );
  }
}
