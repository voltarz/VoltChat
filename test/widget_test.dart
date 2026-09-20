import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voltchat/main.dart';
import 'package:voltchat/presentation/screens/splash/splash_screen.dart';

void main() {
  testWidgets('VoltChat App Initialization Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VoltChatApp());

    // Verify that the splash screen is initially displayed
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('VoltChat'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
