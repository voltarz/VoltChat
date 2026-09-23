import 'package:flutter_test/flutter_test.dart';

import 'package:voltchat/main.dart';
import 'package:voltchat/core/di/locator.dart';
import 'package:voltchat/domain/repositories/auth_repository.dart';
import 'package:voltchat/domain/models/user.dart';
import 'package:voltchat/domain/models/auth_session.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<AuthSession?> getSession() async => null;

  @override
  Future<bool> hasValidSession() async => false;

  @override
  Future<User> login(String username, String password) async => User(id: '1', username: username, displayName: 'Test');

  @override
  Future<void> logout() async {}

  @override
  Future<User> register(String username, String password) async => User(id: '1', username: username, displayName: 'Test');
}

void main() {
  setUpAll(() {
    locator.authRepository = MockAuthRepository();
  });

  testWidgets('VoltChat App Initialization Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VoltChatApp());

    // It will immediately check session and route to Login Screen since mock returns false
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
