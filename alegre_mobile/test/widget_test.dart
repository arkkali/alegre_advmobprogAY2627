import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:alegre_mobile/main.dart';

void main() {
  testWidgets('counter and theme toggle work', (WidgetTester tester) async {
    // Build the app with the same provider used in production.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: const MyApp(),
      ),
    );

    // Check that the main UI elements are visible at startup.
    expect(find.text('Counter App'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);

    final switchWidget = tester.widget<Switch>(find.byType(Switch));
    expect(switchWidget.value, isFalse);

    // Toggle the switch and confirm the state updates.
    await tester.tap(find.byType(Switch));
    await tester.pump();

    final updatedSwitch = tester.widget<Switch>(find.byType(Switch));
    expect(updatedSwitch.value, isTrue);

    // Confirm the counter increments when the button is pressed.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
