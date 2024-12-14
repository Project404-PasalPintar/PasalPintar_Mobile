import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatAIPage extends StatefulWidget {
  final String initialMessage;

  const ChatAIPage({Key? key, required this.initialMessage}) : super(key: key);

  @override
  State<ChatAIPage> createState() => _ChatAIPageState();
}

class _ChatAIPageState extends State<ChatAIPage> {
  final List<Map<String, String>> _messages = []; // List untuk menyimpan chat
  final TextEditingController _messageController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _sendMessage(widget.initialMessage); // Kirim pesan awal
  }

  Future<void> _loadChatHistory() async {
    final history = await _storage.read(key: 'chatHistory');
    if (history != null) {
      setState(() {
        _messages.addAll(List<Map<String, String>>.from(jsonDecode(history)));
      });
    }
  }

  Future<void> _saveChatHistory() async {
    await _storage.write(key: 'chatHistory', value: jsonEncode(_messages));
  }

  Future<void> _sendMessage(String prompt) async {
    setState(() {
      _messages.add({'sender': 'user', 'message': prompt});
    });
    _messageController.clear();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.116.84:8080/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({'sender': 'ai', 'message': data['response']});
        });
        await _saveChatHistory(); // Simpan riwayat chat setelah mendapat balasan
      } else {
        setState(() {
          _messages.add({
            'sender': 'ai',
            'message': 'Gagal mendapatkan balasan dari AI.'
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'ai', 'message': 'Terjadi kesalahan: $e'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat PasalPintarBot"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
