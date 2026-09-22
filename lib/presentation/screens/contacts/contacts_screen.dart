import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/models/contact.dart';
import '../../../data/services/mock_contact_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final MockContactService _contactService = MockContactService();
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await _contactService.getContacts();
    if (mounted) {
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchContacts(String query) async {
    if (query.isEmpty) {
      _loadContacts();
      return;
    }
    setState(() => _isLoading = true);
    final results = await _contactService.searchContacts(query);
    if (mounted) {
      setState(() {
        _contacts = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Import Contacts',
            onPressed: () async {
              setState(() => _isLoading = true);
              final imported = await _contactService.importDeviceContacts();
              if (!context.mounted) return;
              setState(() {
                _contacts = imported;
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contacts imported')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Contact',
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed(AppRouter.addContact);
              if (result == true) {
                _loadContacts();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchContacts,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(contact.displayName[0].toUpperCase()),
                        ),
                        title: Text(contact.displayName),
                        subtitle: Text(contact.phoneNumber ?? ''),
                        trailing: contact.isVoltChatUser
                            ? const Icon(Icons.bolt, color: Colors.blue)
                            : null,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.contactDetails,
                            arguments: contact.id,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
