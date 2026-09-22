import 'package:flutter/material.dart';
import '../../../data/services/mock_broadcast_service.dart';
import '../../../data/services/mock_contact_service.dart';
import '../../../domain/models/broadcast_list.dart';
import '../../../domain/models/contact.dart';

class BroadcastListDetailsScreen extends StatefulWidget {
  final String listId;

  const BroadcastListDetailsScreen({super.key, required this.listId});

  @override
  State<BroadcastListDetailsScreen> createState() => _BroadcastListDetailsScreenState();
}

class _BroadcastListDetailsScreenState extends State<BroadcastListDetailsScreen> {
  final _broadcastService = MockBroadcastService();
  final _contactService = MockContactService();

  BroadcastList? _list;
  List<Contact> _allContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final list = await _broadcastService.getBroadcastListById(widget.listId);
      final contacts = await _contactService.getContacts();
      if (!mounted) return;
      setState(() {
        _list = list;
        _allContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading details: $e')),
      );
    }
  }

  Future<void> _renameList() async {
    if (_list == null) return;

    final controller = TextEditingController(text: _list!.name);

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

    if (newName != null && newName.isNotEmpty && newName != _list!.name) {
      try {
        await _broadcastService.updateBroadcastList(widget.listId, newName, _list!.recipientIds);
        await _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error renaming list: $e')),
          );
        }
      }
    }
  }

  Future<void> _editRecipients() async {
    if (_list == null) return;

    final selectedIds = Set<String>.from(_list!.recipientIds);

    final updatedIds = await showDialog<Set<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Recipients'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _allContacts[index];
                    final isSelected = selectedIds.contains(contact.id);
                    return CheckboxListTile(
                      title: Text(contact.displayName),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedIds.add(contact.id);
                          } else {
                            selectedIds.remove(contact.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selectedIds),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updatedIds != null) {
      try {
        await _broadcastService.updateBroadcastList(widget.listId, _list!.name, updatedIds.toList());
        await _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating recipients: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteList() async {
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
        await _broadcastService.deleteBroadcastList(widget.listId);
        if (mounted) {
          // Pop back to broadcast lists screen
          Navigator.of(context).popUntil((route) => route.settings.name == '/broadcasts');
        }
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_list == null) {
      return const Scaffold(body: Center(child: Text('List not found')));
    }

    // Filter all contacts to get the recipient objects
    final recipients = _allContacts.where((c) => _list!.recipientIds.contains(c.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('List Info'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.campaign, size: 40),
            title: Text(_list!.name, style: Theme.of(context).textTheme.headlineSmall),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _renameList,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recipients (${recipients.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Edit'),
                  onPressed: _editRecipients,
                ),
              ],
            ),
          ),
          ...recipients.map((contact) => ListTile(
            leading: CircleAvatar(
              child: Text(contact.displayName[0].toUpperCase()),
            ),
            title: Text(contact.displayName),
            subtitle: Text(contact.phoneNumber ?? ''),
          )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Broadcast List', style: TextStyle(color: Colors.red)),
            onTap: _deleteList,
          ),
        ],
      ),
    );
  }
}
