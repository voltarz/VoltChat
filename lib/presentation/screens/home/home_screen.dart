import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoltChat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.profile),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.campaign),
              label: const Text('Broadcasts'),
              onPressed: () => Navigator.of(context).pushNamed(AppRouter.broadcasts),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Conversations'),
              onPressed: () => Navigator.of(context).pushNamed(AppRouter.conversations),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.contacts),
              label: const Text('Contacts'),
              onPressed: () => Navigator.of(context).pushNamed(AppRouter.contacts),
            ),
          ],
        ),
      ),
    );
  }
}
