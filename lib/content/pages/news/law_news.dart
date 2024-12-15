import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasalpintar_mobile/content/pages/home.dart';
import './details_new.dart';

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
  late Future<Map<String, dynamic>> _newsData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _newsData = loadNewsData();
  }

  Future<Map<String, dynamic>> loadNewsData() async {
    final String response = await rootBundle.loadString('lib/data/news.json');
    final data = json.decode(response);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
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
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailNewsPage(
                  title: article['title'],
                  imagePath: article['image'],
                  description: article['deskripsiberita'],
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    article['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.grey);
                    },
                  ),
                ),
              ),
              title: Text(
                article['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                article['deskripsiberita'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailNewsPage(
                      title: article['title'],
                      imagePath: article['image'],
                      description: article['deskripsiberita'],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
