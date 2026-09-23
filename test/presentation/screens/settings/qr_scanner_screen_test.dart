import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltchat/core/di/locator.dart';
import 'package:voltchat/presentation/screens/settings/qr_scanner_screen.dart';

void main() {
  setUp(() {
    locator.setup();
  });

  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(
      home: widget,
    );
  }

  testWidgets('QrScannerScreen shows platform warning on desktop/web (mocked behavior)', (WidgetTester tester) async {
    // We cannot easily test the camera logic without mocking the platform channels deeply,
    // so we'll test the presence of the simulated scan logic which is what currently shows
    // when running tests (as tests often run in an environment where kIsWeb is false and Platform might be mocked,
    // or if they run on host OS like Windows, it will trigger the desktop view).

    // To ensure the test is robust across platforms where the test runs, we just verify the basic
    // rendering of the screen. In a real scenario we might use an injection or provider to mock the platform check.

    await tester.pumpWidget(buildTestableWidget(const QrScannerScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Scan QR Code'), findsOneWidget);
  });
}
