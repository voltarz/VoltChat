import 'package:flutter/material.dart';
import '../../../data/services/mock_contact_service.dart';
import '../../../data/services/mock_broadcast_service.dart';
import '../../../domain/models/contact.dart';

class CreateBroadcastListScreen extends StatefulWidget {
  const CreateBroadcastListScreen({super.key});

  @override
  State<CreateBroadcastListScreen> createState() => _CreateBroadcastListScreenState();
}

class _CreateBroadcastListScreenState extends State<CreateBroadcastListScreen> {
  final _contactService = MockContactService();
  final _broadcastService = MockBroadcastService();
  final _nameController = TextEditingController();

  List<Contact> _contacts = [];
  final Set<String> _selectedContactIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _contactService.getContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contacts: $e')),
      );
    }
  }

  void _toggleContactSelection(String id) {
    setState(() {
      if (_selectedContactIds.contains(id)) {
        _selectedContactIds.remove(id);
      } else {
        _selectedContactIds.add(id);
      }
    });
  }

  Future<void> _createList() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a list name')),
      );
      return;
    }

    if (_selectedContactIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one recipient')),
      );
      return;
    }

    try {
      await _broadcastService.createBroadcastList(name, _selectedContactIds.toList());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating list: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Broadcast List'),
        actions: [
          TextButton(
            onPressed: _createList,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Recipients (${_selectedContactIds.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                    ? const Center(child: Text('No contacts available.'))
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          final isSelected = _selectedContactIds.contains(contact.id);
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(contact.displayName[0].toUpperCase()),
                            ),
                            title: Text(contact.displayName),
                            subtitle: Text(contact.phoneNumber ?? ''),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleContactSelection(contact.id),
                            ),
                            onTap: () => _toggleContactSelection(contact.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
