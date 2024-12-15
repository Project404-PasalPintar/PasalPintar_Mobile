import 'package:flutter/material.dart';

class DetailNewsPage extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;

  const DetailNewsPage({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> sentences = description.split('.');

    String firstPart = sentences.take(4).join('.') + '.';

    String secondPart = sentences.skip(4).join('.');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Detail Berita'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 100,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                firstPart.trim(),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              if (secondPart.trim().isNotEmpty)
                Text(
                  secondPart.trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
