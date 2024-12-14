import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentsPage extends StatefulWidget {
  final String diskusiID;

  const CommentsPage({Key? key, required this.diskusiID}) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final TextEditingController commentController = TextEditingController();
  late Future<Map<String, dynamic>> _commentsData;

  // Base URL
  final String baseUrl = "https://test-z77zvpmgsa-uc.a.run.app";

  @override
  void initState() {
    super.initState();
    _commentsData = _fetchComments(); // Fetch comments on page load
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

  Future<Map<String, dynamic>> _fetchComments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/v1/communitas/${widget.diskusiID}/comments'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return data; // Return post details and comments
      } else {
        throw Exception(
            'Gagal memuat komentar. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat komentar: $e');
    }
  }

  void _submitComment() async {
    final comment = commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Komentar tidak boleh kosong.")),
      );
      return;
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/v1/communitas/${widget.diskusiID}/comment'),
        headers: headers,
        body: jsonEncode({
          "comment": comment,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Komentar berhasil ditambahkan!")),
        );

        // Refresh komentar terbaru
        setState(() {
          _commentsData = _fetchComments();
        });

        // Clear input field
        commentController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Gagal mengirim komentar. Status code: ${response.statusCode}")),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Diskusi"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _commentsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Gagal memuat komentar: ${snapshot.error}"),
            );
          }

          final post = snapshot.data!['post'];
          final comments = snapshot.data!['comments'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Details
                Text(
                  post['title'],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  post['question'],
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  "Ditulis oleh: ${post['firstName'] ?? "Anonim"} · ${post['totalComments']} Komentar",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Divider(height: 30, thickness: 1),

                // Comments List
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return CommentCard(
                        username: comment['username'] ?? "Anonim",
                        comment: comment['comment'],
                        createdAt: comment['createdAt'],
                      );
                    },
                  ),
                ),
                // Add Comment Section
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: "Tulis komentar",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _submitComment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final String username;
  final String comment;
  final String createdAt;

  const CommentCard({
    Key? key,
    required this.username,
    required this.comment,
    required this.createdAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            username,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            createdAt,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
