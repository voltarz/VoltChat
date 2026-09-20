import 'package:flutter/material.dart';

class BroadcastsScreen extends StatelessWidget {
  const BroadcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Broadcasts')),
      body: const Center(
        child: Text('Broadcasts placeholder'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
