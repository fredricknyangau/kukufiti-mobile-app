import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Found', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text('Not Found Content'),
      ),
    );
  }
}
