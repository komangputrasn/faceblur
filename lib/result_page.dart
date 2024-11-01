import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final List<String> resultPaths;

  const ResultPage({super.key, required this.resultPaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: ListView.builder(
        itemCount: resultPaths.length,
        itemBuilder: (context, index) {
          final imageUrl =
              'https://pumped-kingfish-partly.ngrok-free.app/$resultPaths[index]';
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              imageUrl,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
