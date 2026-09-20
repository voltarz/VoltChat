import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/models/contact.dart';
import '../../../data/services/mock_contact_service.dart';

class ContactDetailsScreen extends StatelessWidget {
  final String contactId;
  const ContactDetailsScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context) {
    final contactService = MockContactService();

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Profile')),
      body: FutureBuilder<Contact>(
        future: contactService.getContactById(contactId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading contact'));
          }

          final contact = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  child: Text(contact.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 24),
                Text(
                  contact.displayName,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                if (contact.phoneNumber != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    contact.phoneNumber!,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 32),
                if (contact.isVoltChatUser)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text('Start Chat'),
                      onPressed: () {
                        // Mock: we would normally create or fetch a conversation ID
                        Navigator.of(context).pushNamed(
                          AppRouter.chat,
                          arguments: 'conv1',
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
          );
        },
      ),
    );
  }
}
