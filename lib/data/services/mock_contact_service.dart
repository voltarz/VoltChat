import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// Ignore in tests
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import '../../domain/models/contact.dart';
import '../../domain/repositories/contact_repository.dart';

class MockContactService implements ContactRepository {
  // Singleton pattern for local persistence
  MockContactService._privateConstructor();
  static final MockContactService _instance = MockContactService._privateConstructor();
  factory MockContactService() => _instance;

  final List<Contact> _contacts = [];
  static const String _prefsKey = 'voltchat_contacts';
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString(_prefsKey);

    if (contactsJson != null) {
      final List<dynamic> decoded = jsonDecode(contactsJson);
      _contacts.clear();
      for (var item in decoded) {
        _contacts.add(Contact.fromJson(item));
      }
    } else {
      // Add default mock data if empty
      _contacts.addAll([
        Contact(id: 'c1', displayName: 'Alice Anderson', phoneNumber: '+1234567890', isVoltChatUser: true, voltChatUserId: 'u1'),
        Contact(id: 'c2', displayName: 'Bob Brown', phoneNumber: '+0987654321', isVoltChatUser: true, voltChatUserId: 'u2'),
        Contact(id: 'c3', displayName: 'Charlie Davis', phoneNumber: '+1122334455', isVoltChatUser: false),
      ]);
      await _saveContacts();
    }
    _isInitialized = true;
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonData = _contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(jsonData));
  }

  @override
  Future<List<Contact>> getContacts() async {
    await _init();
    return List.unmodifiable(_contacts);
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    await _init();
    final lowerQuery = query.toLowerCase();
    return _contacts.where((c) => c.displayName.toLowerCase().contains(lowerQuery)).toList();
  }

  @override
  Future<void> addContact(Contact contact) async {
    await _init();

    // Normalize phone number for checking
    final newPhone = contact.phoneNumber?.replaceAll(RegExp(r'\D'), '');

    if (newPhone != null && newPhone.isNotEmpty) {
      final exists = _contacts.any((c) {
        final existingPhone = c.phoneNumber?.replaceAll(RegExp(r'\D'), '');
        return existingPhone == newPhone;
      });
      if (exists) {
        throw Exception('A contact with this phone number already exists.');
      }
    }
    _contacts.add(contact);
    await _saveContacts();
  }

  @override
  Future<Contact> getContactById(String id) async {
    await _init();
    return _contacts.firstWhere((c) => c.id == id, orElse: () => throw Exception('Contact not found'));
  }

  @override
  Future<List<Contact>> importDeviceContacts() async {
    await _init();

    if (!kIsWeb && !io.Platform.environment.containsKey('FLUTTER_TEST') && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      if (kIsWeb) {
        final deviceContacts = [];

        for (var dc in deviceContacts) {
          if (dc.phones.isNotEmpty) {
             final phone = dc.phones.first.number;
             final newContact = Contact(
                id: DateTime.now().millisecondsSinceEpoch.toString() + dc.id,
                displayName: dc.displayName,
                phoneNumber: phone,
             );
             try {
               await addContact(newContact);
             } catch (e) {
               // Ignore duplicates
             }
          }
        }
      }
    } else {
      // Fallback for Windows/Web or permission denied
      final imported = [
        Contact(id: 'c_imp1', displayName: 'Imported Contact 1', phoneNumber: '+9998887776'),
        Contact(id: 'c_imp2', displayName: 'Imported Contact 2', phoneNumber: '+9997776665'),
      ];
      for (var contact in imported) {
        try {
          await addContact(contact);
        } catch (e) {
          // Skip duplicates during import
        }
      }
    }

    return List.unmodifiable(_contacts);
  }
}
