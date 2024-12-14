import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasalpintar_mobile/content/pages/home.dart';

void main() {
  runApp(LawNews());
}

class LawNews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>>
      _newsData; // Variabel untuk menyimpan data berita

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _newsData = loadNewsData(); // Memanggil fungsi untuk memuat data berita
  }

  // Fungsi untuk memuat data dari file JSON
  Future<Map<String, dynamic>> loadNewsData() async {
    final String response = await rootBundle.loadString('lib/data/news.json');
    final data = json.decode(response); // Mengonversi JSON menjadi Map
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Ganti fungsionalitas arrow_back dengan navigasi ke halaman baru
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Home(), // Ganti dengan halaman yang diinginkan
              ),
            );
          },
        ),
        title: const Text(
          'Berita Hukum',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Perdata'),
            Tab(text: 'Pidana'),
            Tab(text: 'Bisnis'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _newsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          // Mengambil data dari snapshot
          final newsData = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: [
              ArticleListView(newsData['perdata']),
              ArticleListView(newsData['pidana']),
              ArticleListView(newsData['bisnis']),
            ],
          );
        },
      ),
    );
  }
}

class ArticleListView extends StatelessWidget {
  final List<dynamic> articles;

  ArticleListView(this.articles);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              child: Image.asset(
                article['image'], // Path gambar diambil dari JSON
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image);
                },
              ),
            ),
            title: Text(article['title']),
            subtitle: Text(article['deskripsiberita']),
          ),
        );
      },
    );
  }
}
