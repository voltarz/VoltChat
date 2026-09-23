import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltchat/core/router/app_router.dart';
import 'package:voltchat/core/di/locator.dart';
import 'package:voltchat/domain/repositories/auth_repository.dart';
import 'package:voltchat/presentation/screens/splash/splash_screen.dart';
import 'package:voltchat/domain/models/auth_session.dart';
import 'package:voltchat/domain/models/user.dart';

class MockAuthRepository implements AuthRepository {
  bool isValid = false;

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<AuthSession?> getSession() async => null;

  @override
  Future<bool> hasValidSession() async => isValid;

  @override
  Future<User> login(String username, String password) async => User(id: '1', username: username, displayName: 'Test');

  @override
  Future<void> logout() async {}

  @override
  Future<User> register(String username, String password) async => User(id: '1', username: username, displayName: 'Test');
}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    locator.authRepository = mockRepo;
  });

  Widget createTestWidget() {
    return MaterialApp(
      onGenerateRoute: AppRouter.generateRoute,
      home: const SplashScreen(),
    );
  }

  testWidgets('routes to login when no valid session exists', (tester) async {
    mockRepo.isValid = false;
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget); // Login Screen
  });

  testWidgets('routes to home when valid session exists', (tester) async {
    mockRepo.isValid = true;
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('VoltChat'), findsOneWidget); // Home Screen
    expect(find.text('Broadcasts'), findsOneWidget);
  });
}
