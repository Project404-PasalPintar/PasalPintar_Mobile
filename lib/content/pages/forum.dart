import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../navigation/custom_nav_bar.dart';
import './forum/comment_page.dart';

class Forum extends StatelessWidget {
  const Forum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forum"),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: const ForumPage(),
      bottomNavigationBar: const CustomNavBar(currentIndex: 3), // Navigation
    );
  }
}

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late Future<List<dynamic>> _forumThreads;

  // Base URL
  final String baseUrl = "https://test-z77zvpmgsa-uc.a.run.app";

  @override
  void initState() {
    super.initState();
    _forumThreads = _fetchForumThreads(); // Fetch threads on page load
  }

  Future<Map<String, String>> _getHeaders() async {
    final refreshToken = await storage.read(key: 'refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token tidak ditemukan');
    }
    return {
      'Authorization': 'Bearer $refreshToken',
      'Content-Type': 'application/json',
    };
  }

  Future<List<dynamic>> _fetchForumThreads() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/v1/communitas/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Return list of threads
      } else {
        throw Exception(
            'Gagal memuat data forum. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat data forum: $e');
    }
  }

  void _submitQuestion() async {
    final title = titleController.text.trim();
    final question = questionController.text.trim();

    if (title.isEmpty || question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Judul dan pertanyaan tidak boleh kosong.")),
      );
      return;
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/v1/communitas/'),
        headers: headers,
        body: jsonEncode({
          "title": title,
          "question": question,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pertanyaan berhasil dikirim!")),
        );

        // Refresh halaman tanpa reload manual oleh user
        setState(() {
          _forumThreads = _fetchForumThreads();
        });

        // Clear input fields
        titleController.clear();
        questionController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal mengirim pertanyaan. Status code: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form untuk pertanyaan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tanyakan sesuatu",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Tulis judul pertanyaan",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: questionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Tulis pertanyaanmu disini",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align button to the right
                  children: [
                    ElevatedButton(
                      onPressed: _submitQuestion,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "kirim",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Diskusi Terbaru",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<dynamic>>(
            future: _forumThreads,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Gagal memuat data forum: ${snapshot.error}"),
                );
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return const Center(child: Text("Belum ada diskusi."));
              }

              final threads = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: threads.length,
                itemBuilder: (context, index) {
                  final thread = threads[index];
                  return ForumThreadCard(
                    title: thread['title'],
                    author: thread['firstName'] ?? "Anonim",
                    comments: thread['totalComments'] ?? 0,
                    description: thread['question'],
                    threadId: thread['id'], // Tambahkan threadId di sini
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ForumThreadCard extends StatelessWidget {
  final String title;
  final String author;
  final int comments;
  final String description;
  final String threadId; // Tambahkan thread ID untuk navigasi

  const ForumThreadCard({
    Key? key,
    required this.title,
    required this.author,
    required this.comments,
    required this.description,
    required this.threadId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail komentar dengan ID diskusi
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentsPage(diskusiID: threadId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "$author · $comments komentar",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
