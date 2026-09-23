import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltchat/core/router/app_router.dart';
import 'package:voltchat/core/di/locator.dart';
import 'package:voltchat/domain/repositories/auth_repository.dart';
import 'package:voltchat/presentation/screens/auth/login_screen.dart';
import 'package:voltchat/domain/models/auth_session.dart';
import 'package:voltchat/domain/models/user.dart';

class MockAuthRepository implements AuthRepository {
  bool didLogin = false;

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<AuthSession?> getSession() async => null;

  @override
  Future<bool> hasValidSession() async => false;

  @override
  Future<User> login(String username, String password) async {
    didLogin = true;
    return User(id: '1', username: username, displayName: 'Test');
  }

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
      home: const LoginScreen(),
    );
  }

  testWidgets('shows validation error when fields are empty', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter username and password'), findsOneWidget);
    expect(mockRepo.didLogin, isFalse);
  });

  testWidgets('calls login and routes to home on success', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextField).first, 'testuser');
    await tester.enterText(find.byType(TextField).last, 'password');

    await tester.tap(find.text('Login'));
    await tester.pump(); // Start loading
    await tester.pumpAndSettle(); // Finish routing

    expect(mockRepo.didLogin, isTrue);
    expect(find.text('VoltChat'), findsOneWidget); // Home Screen
  });
}
