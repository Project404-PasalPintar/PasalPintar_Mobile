import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key); // Tidak ada parameter firstName

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Home!'), // Teks default
      ),
      body: Center(
        child: Text(
          'Hello, User!', // Teks default
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
