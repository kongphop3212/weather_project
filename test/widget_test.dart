

import 'package:flutter_test/flutter_test.dart';
import 'package:weather/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that the 'Weather App' title is displayed.
    expect(find.text('Weather App'), findsOneWidget);

    // Verify that one of the cities is displayed.
    expect(find.text('Bangkok'), findsOneWidget);

    // You could add more interactions and verifications here as needed.
  });
}
