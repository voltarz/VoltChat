import '../models/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
  Future<List<Contact>> searchContacts(String query);
  Future<void> addContact(Contact contact);
  Future<Contact> getContactById(String id);
  /// Extension point for future native Android/iOS device contact import
  Future<List<Contact>> importDeviceContacts();
}
