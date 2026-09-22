import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voltchat/core/router/app_router.dart';
import 'package:voltchat/data/services/mock_broadcast_service.dart';
import 'package:voltchat/presentation/screens/conversations/conversations_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    MockBroadcastService().clearStateForTest();
  });

  Widget createTestWidget() {
    return MaterialApp(
      onGenerateRoute: AppRouter.generateRoute,
      home: const ConversationsScreen(),
    );
  }

  testWidgets('ConversationsScreen displays normal conversations', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // The MockMessagingService has 'u1' and 'u2' by default.
    expect(find.text('u1'), findsOneWidget);
    expect(find.text('u2'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsWidgets);
  });

  testWidgets('ConversationsScreen displays broadcast lists that have messages', (WidgetTester tester) async {
    final broadcastService = MockBroadcastService();
    final list = await broadcastService.createBroadcastList('My Broadcast List', ['u1', 'u2']);

    // Send a broadcast to make it appear in conversations
    await broadcastService.sendBroadcast(list.id, 'Hello everyone');

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // The list name should now be visible
    expect(find.text('My Broadcast List'), findsOneWidget);
    expect(find.byIcon(Icons.campaign), findsOneWidget);
  });

  testWidgets('ConversationsScreen search filters conversations', (WidgetTester tester) async {
    final broadcastService = MockBroadcastService();
    final list = await broadcastService.createBroadcastList('Important Announcement', ['u1']);
    await broadcastService.sendBroadcast(list.id, 'Read this');

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('u1'), findsOneWidget);
    expect(find.text('u2'), findsOneWidget);
    expect(find.text('Important Announcement'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'Important');
    await tester.pumpAndSettle();

    // Only 'Important Announcement' should remain
    expect(find.text('Important Announcement'), findsOneWidget);
    expect(find.text('u1'), findsNothing);
    expect(find.text('u2'), findsNothing);
  });
}
