import '../../domain/models/contact.dart';
import '../../domain/repositories/contact_repository.dart';

class MockContactService implements ContactRepository {
  final List<Contact> _contacts = [
    Contact(id: 'c1', displayName: 'Alice Anderson', phoneNumber: '+1234567890', isVoltChatUser: true, voltChatUserId: 'u1'),
    Contact(id: 'c2', displayName: 'Bob Brown', phoneNumber: '+0987654321', isVoltChatUser: true, voltChatUserId: 'u2'),
    Contact(id: 'c3', displayName: 'Charlie Davis', phoneNumber: '+1122334455', isVoltChatUser: false),
  ];

  @override
  Future<List<Contact>> getContacts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _contacts;
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowerQuery = query.toLowerCase();
    return _contacts.where((c) => c.displayName.toLowerCase().contains(lowerQuery)).toList();
  }

  @override
  Future<void> addContact(Contact contact) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _contacts.add(contact);
  }

  @override
  Future<Contact> getContactById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _contacts.firstWhere((c) => c.id == id, orElse: () => throw Exception('Contact not found'));
  }

  @override
  Future<List<Contact>> importDeviceContacts() async {
    await Future.delayed(const Duration(seconds: 1));
    return _contacts; // Mocking device import by returning existing mock data
  }
}
