import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/models/contact.dart';
import '../../../domain/models/user.dart';
import '../../../data/services/mock_contact_service.dart';
import '../../../data/services/mock_user_service.dart';

class ContactDetailsScreen extends StatefulWidget {
  final String contactId;
  const ContactDetailsScreen({super.key, required this.contactId});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  final _contactService = MockContactService();
  final _userService = MockUserService();

  Contact? _contact;
  User? _registeredUser;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final contact = await _contactService.getContactById(widget.contactId);
      User? registeredUser;

      if (contact.phoneNumber != null && contact.phoneNumber!.isNotEmpty) {
        registeredUser = await _userService.getUserByPhoneNumber(contact.phoneNumber!);
      }

      if (mounted) {
        setState(() {
          _contact = contact;
          _registeredUser = registeredUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading contact: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Profile')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null || _contact == null
          ? Center(child: Text(_error ?? 'Error loading contact'))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    child: Text(_contact!.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _contact!.displayName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  if (_contact!.phoneNumber != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _contact!.phoneNumber!,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (_registeredUser != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat),
                        label: const Text('Start Chat'),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.chat,
                            arguments: 'conv_${_registeredUser!.id}',
                          );
                        },
                      ),
                    )
                  else
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'This contact is not on VoltChat yet. Invite them to start messaging!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
