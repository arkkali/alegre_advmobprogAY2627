import 'package:alegre_mobile/main.dart';
import 'package:alegre_mobile/screens/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:alegre_mobile/providers/theme_provider.dart';

void main() {
  testWidgets('app builds and shows the splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const AlegreAdvMobProg(),
      ),
    );

    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
  });
}
