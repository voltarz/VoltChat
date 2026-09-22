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

  Future<void> _renameList(BroadcastList list) async {
    final controller = TextEditingController(text: list.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New list name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != list.name) {
      try {
        await _broadcastService.updateBroadcastList(list.id, newName, list.recipientIds);
        await _loadLists();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error renaming list: $e')),
          );
        }
      }
    }
  }

  void _manageRecipients(BroadcastList list) {
    Navigator.of(context)
        .pushNamed(AppRouter.broadcastListDetails, arguments: list.id)
        .then((_) => _loadLists());
  }

  Future<void> _deleteList(BroadcastList list) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: const Text('Are you sure you want to delete this broadcast list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _broadcastService.deleteBroadcastList(list.id);
        await _loadLists();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting list: $e')),
          );
        }
      }
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
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'rename') {
                            _renameList(list);
                          } else if (value == 'manage') {
                            _manageRecipients(list);
                          } else if (value == 'delete') {
                            _deleteList(list);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Text('Rename / Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'manage',
                            child: Text('Manage Recipients'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
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
