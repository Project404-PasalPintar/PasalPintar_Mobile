import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final String lawyerName; // Nama pengacara untuk ditampilkan di AppBar

  const ChatPage({Key? key, required this.chatRoomId, required this.lawyerName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  List<dynamic> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMessages(); // Load messages ketika halaman dibuka
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

  Future<void> fetchMessages() async {
    const baseUrl = "https://test-z77zvpmgsa-uc.a.run.app";
    final url = "$baseUrl/v1/chat/${widget.chatRoomId}/messages";

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messages = data['data']; // Simpan pesan ke state
          isLoading = false;
        });
      } else {
        throw Exception(
            "Gagal memuat pesan. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saat memuat pesan: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage(String message) async {
    const baseUrl = "https://test-z77zvpmgsa-uc.a.run.app";
    final url = "$baseUrl/v1/chat/message";

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          "chatRoomId": widget.chatRoomId,
          "senderID": "userID123", // Ganti dengan ID user yang benar
          "receiverID": "lawyerID456", // Ganti dengan ID lawyer
          "message": message,
        }),
      );

      if (response.statusCode == 200) {
        final newMessage = jsonDecode(response.body)['data'];
        setState(() {
          messages.add(newMessage); // Tambahkan pesan baru ke daftar
        });
        messageController.clear(); // Bersihkan input setelah mengirim
      } else {
        throw Exception(
            "Gagal mengirim pesan. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saat mengirim pesan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat dengan ${widget.lawyerName}"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Daftar pesan
                Expanded(
                  child: ListView.builder(
                    // Ubah reverse menjadi false
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSentByUser = message['senderID'] ==
                          "userID123"; // Ubah sesuai ID user
                      return Align(
                        alignment: isSentByUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                isSentByUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(
                              color: isSentByUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Input pesan
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: "Tulis pesan...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final message = messageController.text.trim();
                          if (message.isNotEmpty) {
                            sendMessage(message); // Kirim pesan
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
