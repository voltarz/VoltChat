import 'package:flutter/material.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/registration_screen.dart';
import '../../presentation/screens/broadcasts/broadcasts_screen.dart';
import '../../presentation/screens/broadcasts/create_broadcast_list_screen.dart';
import '../../presentation/screens/broadcasts/broadcast_composer_screen.dart';
import '../../presentation/screens/broadcasts/broadcast_list_details_screen.dart';
import '../../presentation/screens/contacts/add_contact_screen.dart';
import '../../presentation/screens/contacts/contact_details_screen.dart';
import '../../presentation/screens/contacts/contacts_screen.dart';
import '../../presentation/screens/conversations/chat_screen.dart';
import '../../presentation/screens/conversations/conversations_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/linked_devices_screen.dart';
import '../../presentation/screens/settings/qr_scanner_screen.dart';
import '../../presentation/screens/auth/qr_link_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String broadcasts = '/broadcasts';
  static const String createBroadcastList = '/create-broadcast-list';
  static const String broadcastComposer = '/broadcast-composer';
  static const String broadcastListDetails = '/broadcast-list-details';
  static const String conversations = '/conversations';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String contacts = '/contacts';
  static const String contactDetails = '/contact-details';
  static const String addContact = '/add-contact';
  static const String chat = '/chat';
  static const String linkedDevices = '/linked-devices';
  static const String qrScanner = '/qr-scanner';
  static const String qrLink = '/qr-link';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case broadcasts:
        return MaterialPageRoute(builder: (_) => const BroadcastsScreen());
      case createBroadcastList:
        return MaterialPageRoute(builder: (_) => const CreateBroadcastListScreen());
      case broadcastComposer:
        final listId = routeSettings.arguments as String;
        return MaterialPageRoute(builder: (_) => BroadcastComposerScreen(listId: listId));
      case broadcastListDetails:
        final listId = routeSettings.arguments as String;
        return MaterialPageRoute(builder: (_) => BroadcastListDetailsScreen(listId: listId));
      case conversations:
        return MaterialPageRoute(builder: (_) => const ConversationsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case contacts:
        return MaterialPageRoute(builder: (_) => const ContactsScreen());
      case contactDetails:
        final contactId = routeSettings.arguments as String;
        return MaterialPageRoute(builder: (_) => ContactDetailsScreen(contactId: contactId));
      case addContact:
        return MaterialPageRoute(builder: (_) => const AddContactScreen());
      case chat:
        final conversationId = routeSettings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => ChatScreen(conversationId: conversationId),
            settings: routeSettings);
      case linkedDevices:
        return MaterialPageRoute(builder: (_) => const LinkedDevicesScreen(), settings: routeSettings);
      case qrScanner:
        return MaterialPageRoute(builder: (_) => const QrScannerScreen(), settings: routeSettings);
      case qrLink:
        return MaterialPageRoute(builder: (_) => const QrLinkScreen(), settings: routeSettings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
