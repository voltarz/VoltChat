import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/locator.dart';
import 'data/services/local_media_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  locator.setup();

  // Initialize LocalMediaStorageService to cache app directory path synchronously
  await LocalMediaStorageService().init();

  runApp(const VoltChatApp());
}

class VoltChatApp extends StatelessWidget {
  const VoltChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoltChat',
      theme: AppTheme.darkTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
