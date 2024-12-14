import 'package:flutter/material.dart';

class LawsOverviewPage extends StatelessWidget {
  final Map<String, dynamic> detailHukum; // Data detail hukum

  const LawsOverviewPage({Key? key, required this.detailHukum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Detail Hukum',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nama Pasal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Judul:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        detailHukum['NamaPasal'] ?? 'Tidak tersedia',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Colors.grey),
            Expanded(
              child: ListView(
                children: [
                  DetailItem(title: 'Nomor', value: detailHukum['Nomor']),
                  DetailItem(title: 'Jenis', value: detailHukum['Jenis']),
                  DetailItem(
                      title: 'Singkatan Jenis',
                      value: detailHukum['SingkatanJenis']),
                  DetailItem(
                      title: 'Tanggal Ditetapkan',
                      value: detailHukum['TanggalDitetapkan']),
                  DetailItem(
                      title: 'T.E.U Badan', value: detailHukum['TEUBadan']),
                  DetailItem(
                      title: 'Tempat Penetapan',
                      value: detailHukum['TempatPenetapan']),
                  DetailItem(
                      title: 'Bidang Hukum', value: detailHukum['BidangHukum']),
                  DetailItem(title: 'Status', value: detailHukum['Status']),
                  DetailItem(title: 'Subjek', value: detailHukum['Subjek']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String title;
  final String? value;

  const DetailItem({Key? key, required this.title, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          Text(
            value ?? 'Tidak tersedia',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
