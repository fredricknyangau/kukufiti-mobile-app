import 'package:flutter/material.dart';

class BatchDetailsScreen extends StatelessWidget {
  final String batchId;
  const BatchDetailsScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch #$batchId'),
      ),
      body: Center(
        child: Text('Batch Details Screen Stub\nBatch ID: $batchId'),
      ),
    );
  }
}
