import 'package:flutter/material.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/registration_screen.dart';
import '../../presentation/screens/broadcasts/broadcasts_screen.dart';
import '../../presentation/screens/conversations/conversations_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String broadcasts = '/broadcasts';
  static const String conversations = '/conversations';
  static const String profile = '/profile';
  static const String settings = '/settings';

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
      case conversations:
        return MaterialPageRoute(builder: (_) => const ConversationsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
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
