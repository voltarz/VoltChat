import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/models/broadcast_list.dart';
import '../../../data/services/mock_broadcast_service.dart';

class BroadcastsScreen extends StatefulWidget {
  const BroadcastsScreen({super.key});

  @override
  State<BroadcastsScreen> createState() => _BroadcastsScreenState();
}

class _BroadcastsScreenState extends State<BroadcastsScreen> {
  final _broadcastService = MockBroadcastService();
  List<BroadcastList> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() => _isLoading = true);
    try {
      final lists = await _broadcastService.getBroadcastLists();
      if (!mounted) return;
      setState(() {
        _lists = lists;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading lists: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcasts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lists.isEmpty
              ? const Center(
                  child: Text(
                    'No broadcast lists yet.\nTap + to create one.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _lists.length,
                  itemBuilder: (context, index) {
                    final list = _lists[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.campaign),
                      ),
                      title: Text(list.name),
                      subtitle: Text('${list.recipientIds.length} recipients'),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.broadcastComposer,
                          arguments: list.id,
                        ).then((_) => _loadLists());
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .pushNamed(AppRouter.createBroadcastList)
              .then((_) => _loadLists());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
